import { StatusCodes } from "http-status-codes";
import prisma from "../../../prisma/client.js";
import { extractLeadPayload } from "../../../utils/workflowHelpers.js";
import { getBookingModel, buildDetailsPayload, saveAdditionalDetails, buildDetailsUpdatePayload, updateAdditionalDetails } from "../../../utils/bookingHelpers.js";
import { NotificationService } from "../../notification/notification.service.js";
import axios from "axios";
import { envVars } from "../../../config/env.js";

// Helper function to create or update Vapi booking and CRM Lead data
const processVapiData = async ({
  agent,
  vapiCallId,
  customerNameFromPayload,
  customerNumberFromPayload,
  analysis,
  structuredData,
  isToolCall = false,
  toolCallId = null,
  isBookingConfirmed = false
}) => {
  // Check if CRM Lead already exists for this call to determine create vs update
  let existingLead = null;
  if (vapiCallId) {
    existingLead = await prisma.crmLead.findFirst({
      where: { conversationId: vapiCallId }
    });
  }

  // Normalize keys for both tool-calls and end-of-call-report structuredData
  const normalizedData = {
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

  const customerName = normalizedData.customerName || customerNameFromPayload || "Vapi Customer";
  const customerNumber = normalizedData.customerNumber || customerNumberFromPayload || "";
  const email = normalizedData.email || "";
  const price = normalizedData.price || "0";
  const note = normalizedData.note || "";

  const bookingConfirmationVal = normalizedData.booking_confirmation !== undefined
    ? normalizedData.booking_confirmation
    : normalizedData.bookingConfirmation;

  const shouldConfirm = isBookingConfirmed ||
    bookingConfirmationVal === true ||
    bookingConfirmationVal === "true" ||
    bookingConfirmationVal === "True" ||
    bookingConfirmationVal === 1 ||
    bookingConfirmationVal === "1";

  // Resolve business type
  const business = await prisma.business.findUnique({
    where: { id: agent.businessId },
    select: { businessType: true }
  });
  const businessType = business?.businessType || "ORDER_BOOKING";
  const { model, detailsModel, detailsKey, detailsRelation } = getBookingModel(businessType);

  if (shouldConfirm) {
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
      bookingData.productName = normalizedData.productName || normalizedData.product_name ||
        normalizedData.packageName || normalizedData.package_name ||
        normalizedData["PACKAGE NAME"] || normalizedData["PRODUCT NAME"] || null;
    }

    if (existingBooking) {
      // UPDATE existing booking
      await model.update({
        where: { id: existingBooking.id },
        data: bookingData
      });

      const detailsUpdatePayload = buildDetailsUpdatePayload(businessType, normalizedData);
      if (Object.keys(detailsUpdatePayload).length > 0) {
        await detailsModel.updateMany({
          where: { [detailsKey]: existingBooking.id },
          data: detailsUpdatePayload
        });
      }

      // Update additional fields
      await updateAdditionalDetails(prisma, agent.businessId, agent.branchId, existingBooking.id, normalizedData);
      console.log(`✅ [Vapi Booking Update] Updated existing ${businessType} booking: ${existingBooking.id}`);
    } else {
      // CREATE new booking
      const booking = await model.create({
        data: bookingData
      });

      const detailsPayload = buildDetailsPayload(businessType, normalizedData, booking.id, agent.businessId, agent.branchId);
      await detailsModel.create({ data: detailsPayload });

      // Save any non-standard additional fields
      await saveAdditionalDetails(prisma, agent.businessId, agent.branchId, booking.id, normalizedData);

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
    metadata: normalizedData,
  });

  if (existingLead) {
    // UPDATE existing lead
    delete cleanLead.businessId;
    delete cleanLead.conversationId;
    cleanLead.metadata = {
      ...(existingLead.metadata && typeof existingLead.metadata === "object" ? existingLead.metadata : {}),
      ...normalizedData
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
};

export const handleVapiWebhook = async (req, res, next) => {
  try {
    const payload = req.body;
    const eventType = payload.message?.type || payload.type;
    const status = payload.message?.status || payload.status || payload.message?.call?.status || null;
    const analysis = payload.message?.analysis ||
      payload.message?.call?.analysis ||
      payload.call?.analysis ||
      payload.analysis || null;

    const agentId = payload.message?.call?.assistantId ||
      payload.message?.assistantId ||
      payload.message?.call?.assistant?.id ||
      payload.message?.assistant?.id ||
      payload.call?.assistantId ||
      payload.call?.assistant?.id ||
      payload.assistantId ||
      payload.agentId || null;

    const vapiCallId = payload.message?.call?.id ||
      payload.call?.id ||
      payload.message?.callId ||
      payload.callId || null;
    const hasAnalysis = analysis && Object.keys(analysis).length > 0;
    const isToolCall = eventType === "tool-calls";
    const isEndOfCall = eventType === "end-of-call-report" || eventType === "end-of-call" || isToolCall;
    const isCallEndedStatus = eventType === "status-update" && status === "ended";

    console.log(`🤖 [Vapi Webhook] Triggered | Event Type: ${eventType} | Status: ${status} | Agent ID: ${agentId} | Call ID: ${vapiCallId}`);

    if (eventType === "end-of-call-report" || eventType === "end-of-call") {
      console.log(`📞 [Vapi End of Call Report Payload]:`, JSON.stringify(payload, null, 2));
    }

    let responsePayload = { success: true, message: "Webhook processed successfully" };

    if (agentId) {
      const agent = await prisma.agent.findFirst({ where: { vapiId: agentId } });

      if (agent) {
        if (isEndOfCall || hasAnalysis) {
          try {
            let structuredData = analysis?.structuredData || {};
            let toolCallId = null;
            let toolCall = null;
            let isBookingConfirmed = false;

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

              const isConfirmBookingTool = (toolCall?.function?.name === "confirm_booking" || toolCall?.name === "confirm_booking");
              if (isConfirmBookingTool) {
                isBookingConfirmed = true;
              }
            }

            console.log(`\n==================================================`);
            console.log(`📞 [Vapi Webhook] Processing Webhook Data`);
            console.log(`Customer: ${structuredData.customer_name || structuredData.customerName || "Vapi Customer"} | Phone: ${structuredData.customer_phone || structuredData.customerNumber || ""}`);
            console.log(`==================================================\n`);

            await processVapiData({
              agent,
              vapiCallId,
              customerNameFromPayload: payload.message?.customer?.name || null,
              customerNumberFromPayload: payload.message?.customer?.number || null,
              analysis,
              structuredData,
              isToolCall,
              toolCallId,
              isBookingConfirmed
            });

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
          } catch (dbError) {
            console.error("❌ [Vapi] DB Error in processing:", dbError);
          }
        }

        // Fail-safe backup fallback when Call status ends but end-of-call-report wasn't sent/received in time
        if (isCallEndedStatus && envVars.VAPI_API_KEY) {
          setTimeout(async () => {
            try {
              console.log(`ℹ️ [Vapi Webhook] Background backup fetching call details from Vapi API for Call ID: ${vapiCallId}...`);
              const response = await axios.get(`https://api.vapi.ai/call/${vapiCallId}`, {
                headers: { Authorization: `Bearer ${envVars.VAPI_API_KEY}` }
              });
              const callData = response.data;
              const callAnalysis = callData?.analysis;
              if (callAnalysis && Object.keys(callAnalysis).length > 0) {
                console.log(`✅ [Vapi API Backup] Successfully fetched call analysis from Vapi API.`);
                
                await processVapiData({
                  agent,
                  vapiCallId,
                  customerNameFromPayload: callData?.customer?.name || null,
                  customerNumberFromPayload: callData?.customer?.number || null,
                  analysis: callAnalysis,
                  structuredData: callAnalysis.structuredData || {},
                  isBookingConfirmed: false
                });
              } else {
                console.warn(`⚠️ [Vapi API Backup] Fetched call details but no analysis was found.`);
              }
            } catch (error) {
              console.error(`❌ [Vapi API Backup Error] Failed to fetch call details:`, error.message);
            }
          }, 25000); // 25s delay to allow Vapi to finish generating the analysis
        }
      } else {
        console.warn(`⚠️ [Vapi] No Agent found for ID: ${agentId}`);
      }
    }

    res.status(StatusCodes.OK).json(responsePayload);
  } catch (error) {
    next(error);
  }
};
