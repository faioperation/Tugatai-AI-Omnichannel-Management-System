import { StatusCodes } from "http-status-codes";
import prisma from "../../../prisma/client.js";
import { extractLeadPayload } from "../../../utils/workflowHelpers.js";
import { getBookingModel, buildDetailsPayload, saveAdditionalDetails } from "../../../utils/bookingHelpers.js";
import { NotificationService } from "../../notification/notification.service.js";

export const handleVapiWebhook = async (req, res, next) => {
  try {
    const payload = req.body;
    const eventType = payload.message?.type || payload.type;
    const analysis = payload.message?.analysis || payload.analysis || payload.message?.call?.analysis || null;

    const agentId = payload.message?.call?.assistantId ||
      payload.message?.assistantId ||
      payload.assistantId ||
      payload.message?.call?.assistant?.id ||
      payload.message?.assistant?.id ||
      payload.agentId || null;

    const vapiCallId = payload.message?.call?.id || payload.call?.id || payload.message?.callId || payload.callId || null;
    const hasAnalysis = analysis && Object.keys(analysis).length > 0;
    const isToolCall = eventType === "tool-calls";
    const isEndOfCall = eventType === "end-of-call-report" || eventType === "end-of-call" || isToolCall;

    console.log(`🤖 [Vapi Webhook] Triggered | Event Type: ${eventType} | Agent ID: ${agentId}`);

    let responsePayload = { success: true, message: "Webhook processed successfully" };

    if (agentId && (isEndOfCall || hasAnalysis)) {
      try {
        const agent = await prisma.agent.findFirst({ where: { vapiId: agentId } });

        if (agent) {
          // Check for duplicate processing using vapiCallId
          if (vapiCallId) {
            const existingLead = await prisma.crmLead.findFirst({
              where: { conversationId: vapiCallId }
            });
            if (existingLead) {
              console.log(`ℹ️ [Vapi Webhook] CrmLead with conversationId ${vapiCallId} already exists. Skipping duplicate.`);
              if (isToolCall) {
                const toolCalls = payload.message?.toolCalls || payload.toolCalls || [];
                const toolCallId = toolCalls[0]?.id;
                return res.status(StatusCodes.OK).json({
                  results: [
                    {
                      toolCallId: toolCallId,
                      result: "Duplicate call detected. Processed previously."
                    }
                  ]
                });
              }
              return res.status(StatusCodes.OK).json({ success: true, message: "Duplicate webhook skipped" });
            }
          }

          let structuredData = analysis?.structuredData || {};
          let toolCallId = null;

          if (isToolCall) {
            const toolCalls = payload.message?.toolCalls || payload.toolCalls || [];
            const toolCall = toolCalls[0];
            toolCallId = toolCall?.id;
            let toolArguments = {};
            if (toolCall?.function?.arguments) {
              const args = toolCall.function.arguments;
              if (typeof args === "string") {
                try {
                  toolArguments = JSON.parse(args);
                } catch (e) {
                  console.error("Failed to parse tool arguments:", e);
                }
              } else if (typeof args === "object") {
                toolArguments = args;
              }
            }
            // Normalize toolArguments to match structuredData keys
            const normalizedArgs = {
              customerName: toolArguments.customer_name || toolArguments.customerName || toolArguments.name || "",
              customerNumber: toolArguments.customer_phone || toolArguments.customerNumber || toolArguments.phone || "",
              email: toolArguments.email || "",
              price: toolArguments.price || toolArguments.cost || "0",
              note: toolArguments.note || toolArguments.details || toolArguments.notes || "",
              booking_confirmation: toolArguments.booking_confirmation,
              bookingConfirmation: toolArguments.bookingConfirmation,
              ...toolArguments
            };
            structuredData = { ...structuredData, ...normalizedArgs };
          }

          const customerName = structuredData.customerName || structuredData.name ||
            payload.message?.customer?.name || "Vapi Customer";
          const customerNumber = structuredData.customerNumber || structuredData.phone ||
            payload.message?.customer?.number || "";
          const email = structuredData.email || "";
          const price = structuredData.price || structuredData.cost || "0";
          const note = structuredData.note || structuredData.notes || analysis?.summary || "";

          const bookingConfirmationVal = structuredData.booking_confirmation !== undefined
            ? structuredData.booking_confirmation
            : structuredData.bookingConfirmation;

          const isBookingConfirmed = bookingConfirmationVal === true ||
            bookingConfirmationVal === "true" ||
            bookingConfirmationVal === "True" ||
            bookingConfirmationVal === 1 ||
            bookingConfirmationVal === "1";

          console.log(`\n==================================================`);
          console.log(`📞 [Vapi Webhook] Processing Webhook Data`);
          console.log(`Customer: ${customerName} | Phone: ${customerNumber}`);
          console.log(`booking_confirmation field value:`, bookingConfirmationVal);
          console.log(`Is Booking Confirmed: ${isBookingConfirmed}`);
          console.log(`==================================================\n`);

          if (isBookingConfirmed) {
            // Resolve business type
            const business = await prisma.business.findUnique({
              where: { id: agent.businessId },
              select: { businessType: true }
            });
            const businessType = business?.businessType || "ORDER_BOOKING";
            const { model, detailsModel, detailsRelation } = getBookingModel(businessType);

            const bookingData = {
              businessId: agent.businessId,
              branchId: agent.branchId || null,
              customerName,
              customerNumber,
              email,
              price: String(price),
              note,
              conversationId: vapiCallId,
            };

            if (businessType !== "APPOINTMENT_BOOKING") {
              bookingData.productName = structuredData.productName || structuredData.product_name ||
                structuredData.packageName || structuredData.package_name ||
                structuredData["PACKAGE NAME"] || structuredData["PRODUCT NAME"] || null;
            }

            const booking = await model.create({
              data: bookingData
            });

            const detailsPayload = buildDetailsPayload(businessType, structuredData, booking.id, agent.businessId, agent.branchId);
            await detailsModel.create({ data: detailsPayload });

            // Save any non-standard additional fields
            await saveAdditionalDetails(prisma, agent.businessId, agent.branchId, booking.id, structuredData);

            console.log(`✅ [Vapi Booking Success] Created ${businessType} booking: ${booking.id}`);

            // Trigger notification for Voice Call Booking
            NotificationService.createAndSendNotification({
              title: `New ${businessType.replace('_', ' ')} (Voice Call)`,
              message: `Booking for ${customerName} (${customerNumber}) confirmed via Voice Call.`,
              type: "VOICE_CALL",
              businessId: agent.businessId,
              branchId: agent.branchId || null,
              bookingId: booking.id,
            }).catch(err => console.error("Error sending Voice Call booking notification:", err));
          } else {
            console.log(`ℹ️ [Vapi Booking Skipped] booking_confirmation is not true, skipping booking creation.`);
          }

          // Create CRM Lead (always, for every call)
          const cleanLead = await extractLeadPayload(agent.businessId, {
            branchId: agent.branchId,
            name: customerName,
            email,
            phone: customerNumber,
            note,
            conversationId: vapiCallId,
            metadata: structuredData,
          });
          const newLead = await prisma.crmLead.create({ data: cleanLead });
          console.log(`👥 [Vapi CRM Lead Success] Created CrmLead: ${newLead.id} for Customer: ${customerName}`);

          // Set response payload if it's a tool call
          if (isToolCall) {
            responsePayload = {
              results: [
                {
                  toolCallId: toolCallId,
                  result: isBookingConfirmed ? "Booking confirmed and saved successfully." : "Lead captured successfully."
                }
              ]
            };
          }

        } else {
          console.warn(`⚠️ [Vapi] No Agent found for ID: ${agentId}`);
        }
      } catch (dbError) {
        console.error("❌ [Vapi] DB Error:", dbError);
      }
    }

    res.status(StatusCodes.OK).json(responsePayload);
  } catch (error) {
    next(error);
  }
};
