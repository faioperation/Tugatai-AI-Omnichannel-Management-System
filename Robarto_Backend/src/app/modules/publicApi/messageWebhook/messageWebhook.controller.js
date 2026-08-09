import { AppError } from "../../../errorHelper/appError.js";
import { MessageWebhookService } from "./messageWebhook.service.js";

const generateWebhookUrlController = async (req, res, next) => {
  try {
    let businessId = req.body?.businessId;

    // Auto-detect businessId from logged-in Business Owner / Branch Manager if not provided
    if (!businessId && req.business?.id) {
      businessId = req.business.id;
    }

    if (!businessId) {
      throw new AppError(400, "businessId is required (or login as a Business Owner).");
    }

    const branchId = req.body?.branchId;

    const result = await MessageWebhookService.generateWebhookUrl(businessId, branchId);

    res.status(result.isNew ? 201 : 200).json({
      success: true,
      message: result.isNew
        ? "Webhook URL generated and saved successfully"
        : "Existing Webhook URL retrieved for this branch",
      data: result.webhook,
    });
  } catch (error) {
    next(error);
  }
};

const getAllWebhookUrlsController = async (req, res, next) => {
  try {
    let businessId = req.query?.businessId || req.params?.businessId;

    if (!businessId && req.business?.id) {
      businessId = req.business.id;
    }

    if (!businessId) {
      throw new AppError(400, "businessId is required (or login as a Business Owner).");
    }

    const webhookUrls = await MessageWebhookService.getAllWebhookUrlsByBusiness(businessId);

    res.status(200).json({
      success: true,
      message: "Branch-wise Webhook URLs retrieved successfully",
      data: webhookUrls,
    });
  } catch (error) {
    next(error);
  }
};

const sendWebhookMessageController = async (req, res, next) => {
  try {
    const token = req.params.token || req.query.token;
    const businessId = req.params.businessId || req.body.businessId || req.query.businessId;
    const branchId = req.params.branchId || req.body.branchId || req.query.branchId;

    const conversationId = req.body.conversationId || req.query.conversationId;
    const message = req.body.message || req.query.message;
    const file = req.file;

    const result = await MessageWebhookService.sendWebhookMessage({
      token,
      businessId,
      branchId,
      conversationId,
      message,
      file,
    });

    res.status(200).json({
      success: true,
      message: "Message sent successfully via Webhook API",
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const MessageWebhookController = {
  generateWebhookUrlController,
  getAllWebhookUrlsController,
  sendWebhookMessageController,
};
