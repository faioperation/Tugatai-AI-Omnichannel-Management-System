import prisma from "../../../prisma/client.js";
import { StatusCodes } from "http-status-codes";
import { sendResponse } from "../../../utils/sendResponse.js";
import { AppError } from "../../../errorHelper/appError.js";
import { NotificationService } from "../../notification/notification.service.js";
import { GoogleCalendarService } from "../../googleCalendar/googleCalendar.service.js";
import {
    getBookingModel,
    buildDetailsPayload,
    saveAdditionalDetails,
    attachDetails,
    parseDateAndTimeFromPayload,
} from "../../../utils/bookingHelpers.js";

export const createBooking = async (req, res, next) => {
  try {
    console.log("📥 [Public API - Create Booking] Payload:", JSON.stringify(req.body, null, 2));
    const { businessId, customerName, customerNumber, price } = req.body;

    if (!businessId) throw new AppError(StatusCodes.BAD_REQUEST, "businessId is required.");
    if (!customerName) throw new AppError(StatusCodes.BAD_REQUEST, "customerName is required.");
    if (!customerNumber) throw new AppError(StatusCodes.BAD_REQUEST, "customerNumber is required.");

    const business = await prisma.business.findUnique({ where: { id: businessId } });
    if (!business) throw new AppError(StatusCodes.NOT_FOUND, `Business ${businessId} not found.`);

    if (req.body.branchId) {
      const branchExists = await prisma.branch.findFirst({ where: { id: req.body.branchId, businessId } });
      if (!branchExists) throw new AppError(StatusCodes.NOT_FOUND, "Branch not found in this business.");
    }

    const businessType = business.businessType || "ORDER_BOOKING";
    const { model, detailsModel, detailsRelation } = getBookingModel(businessType);

    let conversationId = null;
    if (req.body.conversationId) {
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      if (!uuidRegex.test(req.body.conversationId)) {
        throw new AppError(StatusCodes.BAD_REQUEST, "Invalid conversationId format.");
      }

      const standardExists = await prisma.conversation.findUnique({
        where: { id: req.body.conversationId }
      });
      if (standardExists) {
        conversationId = req.body.conversationId;
      } else {
        const whatsappExists = await prisma.whatsappConversation.findUnique({
          where: { id: req.body.conversationId }
        });
        if (whatsappExists) {
          conversationId = req.body.conversationId;
        } else {
          throw new AppError(StatusCodes.BAD_REQUEST, `Conversation ${req.body.conversationId} not found.`);
        }
      }
    }

    const { date, time } = parseDateAndTimeFromPayload(req.body);

    const result = await prisma.$transaction(async (tx) => {
      const booking = await model.create({
        data: {
          businessId,
          branchId: req.body.branchId || null,
          customerName,
          customerNumber,
          email: req.body.email || null,
          productName: req.body.productName || null,
          price: price ? String(price) : "0",
          note: req.body.note || req.body.orderNote || null,
          status: req.body.status || "PENDING",
          conversationId,
          calenderDate: date || null,
          calenderTime: time || null,
        }
      });

      const detailsPayload = buildDetailsPayload(businessType, req.body, booking.id, businessId, req.body.branchId || null);
      await detailsModel.create({ data: detailsPayload });

      // Create payment detail if provided
      const hasPaymentStatus = req.body.paymentStatus || req.body.paymentDetails?.paymentStatus;
      const hasPaymentMethod = req.body.paymentMethod || req.body.paymentDetails?.paymentMethod;
      const hasTransactionId = req.body.transactionId || req.body.paymentDetails?.transactionId;

      if (hasPaymentStatus || hasPaymentMethod || hasTransactionId) {
        await tx.paymentDetail.create({
          data: {
            referenceId: booking.id,
            createdById: null,
            paymentStatus: hasPaymentStatus || "PENDING",
            paymentMethod: hasPaymentMethod || null,
            transactionId: hasTransactionId || null,
          }
        });
      }

      // Save additional details
      await saveAdditionalDetails(tx, booking.businessId, booking.branchId, booking.id, req.body);

      const createdBooking = await model.findUnique({
        where: { id: booking.id },
        include: { [detailsRelation]: true }
      });

      return await attachDetails(tx, createdBooking);
    });

    // Resolve social media platform name if booking has conversationId
    let platformName = "";
    if (result.conversationId) {
      try {
        const standardConv = await prisma.conversation.findUnique({
          where: { id: result.conversationId },
          select: { platform: true }
        });
        if (standardConv && standardConv.platform) {
          const p = standardConv.platform.toLowerCase();
          if (p === "messenger") {
            platformName = "Facebook Messenger";
          } else if (p === "instagram") {
            platformName = "Instagram";
          } else {
            platformName = p.charAt(0).toUpperCase() + p.slice(1);
          }
        } else {
          const whatsappConv = await prisma.whatsappConversation.findUnique({
            where: { id: result.conversationId }
          });
          if (whatsappConv) {
            platformName = "WhatsApp";
          }
        }
      } catch (err) {
        console.error("Error resolving platform name for notification:", err);
      }
    }

    const viaText = platformName ? ` via ${platformName}` : "";

    // Trigger notification for Public API Booking
    NotificationService.createAndSendNotification({
      title: `New ${businessType.replace('_', ' ')} Created`,
      message: `Booking for ${result.customerName} (${result.customerNumber}) has been created${viaText}.`,
      type: businessType,
      businessId: result.businessId,
      branchId: result.branchId || null,
      bookingId: result.id,
      conversationId: result.conversationId || null,
    }).catch(err => console.error("Error sending Public API booking notification:", err));

    GoogleCalendarService.syncBookingToCalendar(result).catch(err => {
      console.error("Error auto-syncing booking to Google Calendar in public API controller:", err);
    });

    sendResponse(res, { success: true, statusCode: StatusCodes.CREATED, message: "Booking created successfully.", data: result });
  } catch (error) {
    next(error);
  }
};
