import { StatusCodes } from "http-status-codes";
import prisma from "../../../prisma/client.js";
import { extractLeadPayload } from "../../../utils/workflowHelpers.js";
import { getBookingModel, buildDetailsPayload, saveAdditionalDetails, buildDetailsUpdatePayload, updateAdditionalDetails } from "../../../utils/bookingHelpers.js";
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
          // Check if CRM Lead already exists for this call to determine create vs update
          let existingLead = null;
          if (vapiCallId) {
            existingLead = await prisma.crmLead.findFirst({
              where: { conversationId: vapiCallId }
            });
          }

          let structuredData = analysis?.structuredData || {};
          let toolCallId = null;
          let toolCall = null;

          if (isToolCall) {
            const toolCalls = payload.message?.toolCalls || payload.toolCalls || [];
            toolCall = toolCalls[0];
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
            structuredData = { ...structuredData, ...toolArguments };
          }

          // Normalize keys for both tool-calls and end-of-call-report structuredData
          const normalizedArgs = {
            customerName: structuredData.customerName || structuredData.customer_name || structuredData.name || structuredData.sender_name || "",
            customerNumber: structuredData.customerNumber || structuredData.customer_phone || structuredData.phone || structuredData.sender_phone || structuredData.sender_phone_number || "",
            email: structuredData.email || "",
            price: structuredData.price || structuredData.cost || "0",
            note: structuredData.note || structuredData.notes || structuredData.call_summary || analysis?.summary || "",
            pickupAddress: structuredData.pickupAddress || structuredData.pickup_address || structuredData.address || "",
            deliveryAddress: structuredData.deliveryAddress || structuredData.delivery_address || structuredData.address || "",
            booking_confirmation: structuredData.booking_confirmation,
            bookingConfirmation: structuredData.bookingConfirmation,
            ...structuredData
          };
          structuredData = normalizedArgs;

          const customerName = structuredData.customerName ||
            payload.message?.customer?.name || "Vapi Customer";
          const customerNumber = structuredData.customerNumber ||
            payload.message?.customer?.number || "";
          const email = structuredData.email || "";
          const price = structuredData.price || "0";
          const note = structuredData.note || "";

          const isConfirmBookingTool = isToolCall &&
            (toolCall?.function?.name === "confirm_booking" || toolCall?.name === "confirm_booking");

          const bookingConfirmationVal = structuredData.booking_confirmation !== undefined
            ? structuredData.booking_confirmation
            : structuredData.bookingConfirmation;

          const isBookingConfirmed = isConfirmBookingTool ||
            bookingConfirmationVal === true ||
            bookingConfirmationVal === "true" ||
            bookingConfirmationVal === "True" ||
            bookingConfirmationVal === 1 ||
            bookingConfirmationVal === "1";

          console.log(`\n==================================================`);
          console.log(`📞 [Vapi Webhook] Processing Webhook Data`);
          console.log(`Customer: ${customerName} | Phone: ${customerNumber}`);
          console.log(`booking_confirmation field value:`, bookingConfirmationVal);
          console.log(`Is Booking Confirmed: ${isBookingConfirmed}`);
          console.log(`Analysis / Structured Data:`, JSON.stringify(structuredData, null, 2));
          console.log(`==================================================\n`);

          // Resolve business type
          const business = await prisma.business.findUnique({
            where: { id: agent.businessId },
            select: { businessType: true }
          });
          const businessType = business?.businessType || "ORDER_BOOKING";
          const { model, detailsModel, detailsKey, detailsRelation } = getBookingModel(businessType);

          if (isBookingConfirmed) {
            // Check if booking already exists for this call
            let existingBooking = null;
            if (vapiCallId) {
              existingBooking = await model.findFirst({
                where: { conversationId: vapiCallId }
              });
            }

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

            if (existingBooking) {
              // UPDATE existing booking
              await model.update({
                where: { id: existingBooking.id },
                data: bookingData
              });

              const detailsUpdatePayload = buildDetailsUpdatePayload(businessType, structuredData);
              if (Object.keys(detailsUpdatePayload).length > 0) {
                await detailsModel.updateMany({
                  where: { [detailsKey]: existingBooking.id },
                  data: detailsUpdatePayload
                });
              }

              // Update additional fields
              await updateAdditionalDetails(prisma, agent.businessId, agent.branchId, existingBooking.id, structuredData);
              console.log(`✅ [Vapi Booking Update] Updated existing ${businessType} booking: ${existingBooking.id}`);
            } else {
              // CREATE new booking
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
            }
          } else {
            console.log(`ℹ️ [Vapi Booking Skipped] booking_confirmation is not true, skipping booking creation/update.`);
          }

          // Create or Update CRM Lead (always, for every call)
          const cleanLead = await extractLeadPayload(agent.businessId, {
            branchId: agent.branchId,
            name: customerName,
            email,
            phone: customerNumber,
            note,
            conversationId: vapiCallId,
            metadata: structuredData,
          });

          if (existingLead) {
            // UPDATE existing lead
            delete cleanLead.businessId;
            delete cleanLead.conversationId;
            cleanLead.metadata = {
              ...(existingLead.metadata && typeof existingLead.metadata === "object" ? existingLead.metadata : {}),
              ...structuredData
            };

            const updatedLead = await prisma.crmLead.update({
              where: { id: existingLead.id },
              data: cleanLead
            });
            console.log(`👥 [Vapi CRM Lead Update] Updated CrmLead: ${updatedLead.id} for Customer: ${customerName}`);
          } else {
            // CREATE new lead
            const newLead = await prisma.crmLead.create({ data: cleanLead });
            console.log(`👥 [Vapi CRM Lead Success] Created CrmLead: ${newLead.id} for Customer: ${customerName}`);
          }

          // Set response payload if it's a tool call
          if (isToolCall) {
            responsePayload = {
              results: [
                {
                  toolCallId: toolCallId,
                  result: isBookingConfirmed ? "Booking processed successfully." : "Lead captured successfully."
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
