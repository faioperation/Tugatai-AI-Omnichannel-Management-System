import prisma from "../../../prisma/client.js";
import { envVars } from "../../../config/env.js";

export const MessageHistoryService = {
  getMessageHistory: async (conversationId) => {
    // 1. Try finding in standard Conversation table
    const standardConv = await prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (standardConv) {
      const messages = await prisma.message.findMany({
        where: { conversationId },
        orderBy: { createdAt: "asc" },
      });

      const formattedMessages = messages.map((msg) => ({
        id: msg.id,
        senderType: msg.senderType, // 'business' or 'customer'
        senderId: msg.senderId,
        type: msg.type || "text",
        text: msg.messageText,
        mediaUrl: msg.mediaUrl,
        filePath: msg.filePath,
        createdAt: msg.createdAt,
      }));

      return {
        conversation: {
          id: standardConv.id,
          platform: standardConv.platform,
          customerName: standardConv.customerName || "Social Customer",
          customerPhone: null,
          businessId: standardConv.businessId,
          branchId: standardConv.branchId,
        },
        messages: formattedMessages,
      };
    }

    // 2. Try finding in WhatsappConversation table
    const whatsappConv = await prisma.whatsappConversation.findUnique({
      where: { id: conversationId },
      include: {
        contact: true,
        whatsappAccount: true,
      },
    });

    if (whatsappConv) {
      const messages = await prisma.whatsappMessage.findMany({
        where: { conversationId },
        orderBy: { createdAt: "asc" },
      });

      const formattedMessages = messages.map((msg) => {
        let resolvedMediaUrl = msg.mediaUrl;
        if (
          resolvedMediaUrl &&
          !resolvedMediaUrl.startsWith("http://") &&
          !resolvedMediaUrl.startsWith("https://")
        ) {
          resolvedMediaUrl = `${envVars.BACKEND_URL}/v1/whatsapp/media/${resolvedMediaUrl}`;
        }

        return {
          id: msg.id,
          senderType: msg.direction === "INCOMING" ? "customer" : "business",
          senderId: msg.direction === "INCOMING" ? msg.contactId : msg.whatsappAccountId,
          type: msg.type,
          text: msg.text,
          mediaUrl: resolvedMediaUrl,
          createdAt: msg.createdAt,
        };
      });

      return {
        conversation: {
          id: whatsappConv.id,
          platform: "whatsapp",
          customerName: whatsappConv.contact?.name || "WhatsApp User",
          customerPhone: whatsappConv.contact?.phoneNumber || null,
          businessId: whatsappConv.businessId,
          branchId: whatsappConv.whatsappAccount?.branchId || null,
        },
        messages: formattedMessages,
      };
    }

    return null;
  },
};
