import prisma from "../../prisma/client.js";
import axios from "axios";
import { envVars } from "../../config/env.js";

export const AssistantReplyService = {
  suggestReply: async (payload) => {
    const { conversation_id: conversationId, subject } = payload;
    if (!conversationId) {
      throw new Error("conversation_id is required");
    }

    // 1. Try fetching from standard Conversation table
    let conversation = await prisma.conversation.findUnique({
      where: { id: conversationId }
    });

    let channel = null;
    let businessId = null;
    let branchId = null;
    let recipientId = null;
    let lastMessageText = "";

    if (conversation) {
      channel = conversation.platform; // 'messenger' or 'instagram'
      businessId = conversation.businessId;
      branchId = conversation.branchId || null;
      recipientId = conversation.customerId;

      // Find the last message in this conversation
      const lastMsg = await prisma.message.findFirst({
        where: { conversationId },
        orderBy: { createdAt: "desc" }
      });
      if (lastMsg) {
        lastMessageText = lastMsg.messageText || "";
      }
    } else {
      // 2. Try fetching from WhatsappConversation table
      const waConv = await prisma.whatsappConversation.findUnique({
        where: { id: conversationId },
        include: { whatsappAccount: true, contact: true }
      });

      if (waConv) {
        channel = "whatsapp";
        businessId = waConv.businessId;
        branchId = waConv.whatsappAccount?.branchId || null;
        recipientId = waConv.contact?.phoneNumber || waConv.contactId;

        const lastMsg = await prisma.whatsappMessage.findFirst({
          where: { conversationId },
          orderBy: { createdAt: "desc" }
        });
        if (lastMsg) {
          lastMessageText = lastMsg.text || (lastMsg.type !== "text" ? `[Media: ${lastMsg.type}]` : "");
        }
      }
    }

    if (!businessId) {
      throw new Error("Conversation not found");
    }

    const apiBaseUrl = envVars.AI_API_TAREQ;
    if (!apiBaseUrl) {
      throw new Error("AI API base URL (AI_API_TAREQ) is not configured in env");
    }

    const aiPayload = {
      business_id: businessId,
      branchId: branchId,
      subject: subject || "ORDER_BOOKING",
      recipient_id: recipientId,
      conversation_id: conversationId,
      channel,
      source_type: channel ? channel.toUpperCase() : null,
      message: lastMessageText
    };

    console.log(`[Assistant Reply] Sending request to AI API: ${apiBaseUrl}/agent/suggest-reply`);
    console.log("[Assistant Reply] Payload:", JSON.stringify(aiPayload, null, 2));

    const response = await axios.post(`${apiBaseUrl}/agent/suggest-reply`, aiPayload, {
      headers: {
        "x-api-token": envVars.AI_AGENT_API_TOKEN,
        "Content-Type": "application/json"
      }
    });

    return response.data;
  }
};
