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

    console.log("🤖 [Vapi Webhook] Agent ID:", agentId);

    const hasAnalysis = analysis && Object.keys(analysis).length > 0;
    const isEndOfCall = eventType === "end-of-call-report" || eventType === "end-of-call";

    if (agentId && (isEndOfCall || hasAnalysis)) {
      try {
        const agent = await prisma.agent.findFirst({ where: { vapiId: agentId } });

        if (agent) {
          const structuredData = analysis?.structuredData || {};

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
            metadata: structuredData,
          });
          const newLead = await prisma.crmLead.create({ data: cleanLead });
          console.log(`👥 [Vapi CRM Lead Success] Created CrmLead: ${newLead.id} for Customer: ${customerName}`);

        } else {
          console.warn(`⚠️ [Vapi] No Agent found for ID: ${agentId}`);
        }
      } catch (dbError) {
        console.error("❌ [Vapi] DB Error:", dbError);
      }
    }

    res.status(StatusCodes.OK).json({ success: true, message: "Webhook processed successfully" });
  } catch (error) {
    next(error);
  }
};
