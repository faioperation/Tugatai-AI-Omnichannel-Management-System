import crypto from "crypto";
import prisma from "../../../prisma/client.js";
import { AppError } from "../../../errorHelper/appError.js";
import { envVars } from "../../../config/env.js";
import { notifyAiAgent } from "../../../utils/aiAgent.js";

const generateWebhookUrl = async (businessId, branchId) => {
  // 1. Verify business existence
  const business = await prisma.business.findUnique({
    where: { id: businessId },
  });

  if (!business) {
    throw new AppError(404, "Business not found.");
  }

  // 2. Verify branch if provided
  if (branchId) {
    const branch = await prisma.branch.findFirst({
      where: { id: branchId, businessId },
    });
    if (!branch) {
      throw new AppError(404, "Branch not found for this business.");
    }
  }

  // 3. Enforce 1 URL per branch/business: Check if URL already exists
  const existingWebhook = await prisma.webhookUrl.findFirst({
    where: {
      businessId,
      branchId: branchId || null,
      deletedAt: null,
    },
    include: {
      business: {
        select: { id: true, name: true },
      },
      branch: {
        select: { id: true, name: true },
      },
    },
  });

  if (existingWebhook) {
    return {
      isNew: false,
      webhook: existingWebhook,
    };
  }

  // 4. Generate unique token and full URL if not exists
  const token = `wh_${crypto.randomBytes(16).toString("hex")}`;
  const baseUrl = envVars.BACKEND_URL || "http://localhost:5000";
  const generatedUrl = `${baseUrl}/api/v1/public/webhook/send-message/${token}`;

  // 5. Save to webhookUrl model
  const webhookRecord = await prisma.webhookUrl.create({
    data: {
      businessId,
      branchId: branchId || null,
      token,
      url: generatedUrl,
      isActive: true,
    },
    include: {
      business: {
        select: { id: true, name: true },
      },
      branch: {
        select: { id: true, name: true },
      },
    },
  });

  return {
    isNew: true,
    webhook: webhookRecord,
  };
};

const getAllWebhookUrlsByBusiness = async (businessId) => {
  const business = await prisma.business.findUnique({
    where: { id: businessId },
  });

  if (!business) {
    throw new AppError(404, "Business not found.");
  }

  // Fetch all branches of the business along with their generated webhook URLs
  const webhookUrls = await prisma.webhookUrl.findMany({
    where: {
      businessId,
      deletedAt: null,
    },
    include: {
      business: {
        select: { id: true, name: true },
      },
      branch: {
        select: { id: true, name: true, phone: true, address: true },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  return webhookUrls;
};

const sendWebhookMessage = async ({
  token,
  businessId,
  branchId,
  conversationId,
  message,
  file,
}) => {
  let resolvedBusinessId = businessId;
  let resolvedBranchId = branchId;

  // 1. Resolve business & branch from Token if token is present
  if (token) {
    const webhookRecord = await prisma.webhookUrl.findFirst({
      where: { token, isActive: true, deletedAt: null },
    });

    if (!webhookRecord) {
      throw new AppError(404, "Invalid, inactive, or expired Webhook URL token.");
    }

    resolvedBusinessId = webhookRecord.businessId;
    resolvedBranchId = webhookRecord.branchId || resolvedBranchId;
  }

  if (!resolvedBusinessId) {
    throw new AppError(400, "businessId is required.");
  }

  // 2. Verify business existence
  const business = await prisma.business.findUnique({
    where: { id: resolvedBusinessId },
  });

  if (!business) {
    throw new AppError(404, "Business not found.");
  }

  if (!conversationId) {
    throw new AppError(400, "conversationId is required.");
  }

  if (!message && !file) {
    throw new AppError(400, "Either 'message' or 'file' must be provided.");
  }

  // 3. Process File if present
  let mediaUrl = null;
  let filePath = null;
  let messageType = "text";

  if (file) {
    filePath = file.path;
    const hostUrl = envVars.BACKEND_URL || "http://localhost:5000";
    const normalizedPath = file.path.replace(/\\/g, "/");
    mediaUrl = `${hostUrl}/${normalizedPath}`;

    if (file.mimetype.startsWith("image/")) {
      messageType = "image";
    } else if (file.mimetype.startsWith("audio/")) {
      messageType = "audio";
    } else if (file.mimetype.startsWith("video/")) {
      messageType = "video";
    } else {
      messageType = "file";
    }
  }

  // 4. Create or update Conversation
  const displayLastMessage = message || `[${messageType.toUpperCase()}]`;

  const conversation = await prisma.conversation.upsert({
    where: {
      businessId_platform_customerId: {
        businessId: resolvedBusinessId,
        platform: "webhook",
        customerId: conversationId,
      },
    },
    update: {
      lastMessage: displayLastMessage,
      lastMessageAt: new Date(),
      branchId: resolvedBranchId || undefined,
    },
    create: {
      businessId: resolvedBusinessId,
      branchId: resolvedBranchId || null,
      platform: "webhook",
      customerId: conversationId,
      customerName: `Webhook Customer (${conversationId})`,
      lastMessage: displayLastMessage,
      lastMessageAt: new Date(),
    },
  });

  // 5. Save Message
  const newMessage = await prisma.message.create({
    data: {
      conversationId: conversation.id,
      senderType: "customer",
      senderId: conversationId,
      type: messageType,
      messageText: message || null,
      mediaUrl: mediaUrl || null,
      filePath: filePath || null,
      rawPayload: {
        businessId: resolvedBusinessId,
        branchId: resolvedBranchId,
        conversationId,
        file: file
          ? {
              filename: file.filename,
              originalname: file.originalname,
              mimetype: file.mimetype,
              size: file.size,
            }
          : null,
      },
    },
  });

  // 6. Notify AI Agent and capture response
  let aiReplyText = null;
  try {
    const aiResult = await notifyAiAgent({
      businessId: resolvedBusinessId,
      recipientId: conversationId,
      conversationId: conversation.id,
      channel: "webhook",
      message: message || `[${messageType}]`,
    });

    if (aiResult?.response) {
      aiReplyText = aiResult.response;
    }
  } catch (err) {
    console.error("[MessageWebhook Service] Error triggering AI Agent notification:", err);
  }

  return {
    conversationId: conversation.id,
    businessId: resolvedBusinessId,
    branchId: resolvedBranchId || null,
    userMessage: newMessage,
    aiReply: aiReplyText || null,
  };
};

export const MessageWebhookService = {
  generateWebhookUrl,
  getAllWebhookUrlsByBusiness,
  sendWebhookMessage,
};
