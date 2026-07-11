import prisma from "../../prisma/client.js";
import { MetaGraphAPI } from "./whatsapp.meta.js";
import { envVars } from "../../config/env.js";
import { NotificationService } from "../notification/notification.service.js";

export const WhatsappService = {
  connectAccount: async (businessId, payload) => {
    return await prisma.whatsappAccount.upsert({
      where: {
        businessId_phoneNumberId: {
          businessId,
          phoneNumberId: payload.phoneNumberId,
        },
      },
      update: {
        wabaId: payload.wabaId,
        phoneNumber: payload.phoneNumber,
        accessToken: payload.accessToken,
        status: "ACTIVE",
        branchId: payload.branchId || null,
      },
      create: {
        businessId,
        branchId: payload.branchId || null,
        wabaId: payload.wabaId,
        phoneNumberId: payload.phoneNumberId,
        phoneNumber: payload.phoneNumber,
        accessToken: payload.accessToken,
        status: "ACTIVE",
      },
    });
  },

  disconnectAccount: async (businessId, accountId) => {
    return await prisma.whatsappAccount.updateMany({
      where: { id: accountId, businessId },
      data: { status: "DISCONNECTED" },
    });
  },

  getAccounts: async (businessId) => {
    return await prisma.whatsappAccount.findMany({
      where: { businessId },
    });
  },

  getContacts: async (businessId) => {
    return await prisma.whatsappContact.findMany({
      where: { businessId },
    });
  },

  getConversations: async (businessId, branchId) => {
    const whereClause = { businessId };
    if (branchId) {
      whereClause.whatsappAccount = { branchId };
    }

    const conversations = await prisma.whatsappConversation.findMany({
      where: whereClause,
      include: { contact: true },
      orderBy: { lastMessageAt: 'desc' },
    });

    const conversationIds = conversations.map((c) => c.id);
    const summaries = await prisma.chatSummary.findMany({
      where: { conversationId: { in: conversationIds } },
    });

    return conversations.map((c) => {
      const summary = summaries.find((s) => s.conversationId === c.id);
      return {
        ...c,
        chatSummary: summary || null,
      };
    });
  },

  getMessages: async (businessId, conversationId) => {
    const messages = await prisma.whatsappMessage.findMany({
      where: { businessId, conversationId },
      orderBy: { createdAt: "asc" },
    });

    return messages.map(msg => {
      if (
        msg.mediaUrl && 
        !msg.mediaUrl.startsWith("http://") && 
        !msg.mediaUrl.startsWith("https://")
      ) {
        msg.mediaUrl = `${envVars.BACKEND_URL}/v1/whatsapp/media/${msg.mediaUrl}`;
      }
      return msg;
    });
  },

  sendTextMessage: async (businessId, conversationId, messageText, continueAi = undefined) => {
    const conversation = await prisma.whatsappConversation.findUnique({
      where: { id: conversationId },
      include: { contact: true, whatsappAccount: true },
    });

    if (!conversation) throw new Error("Conversation not found");

    const account = conversation.whatsappAccount;
    const contact = conversation.contact;

    const response = await MetaGraphAPI.sendMessage(
      account.phoneNumberId,
      account.accessToken,
      contact.phoneNumber,
      messageText
    );

    const message = await prisma.whatsappMessage.create({
      data: {
        businessId,
        whatsappAccountId: account.id,
        conversationId,
        contactId: contact.id,
        metaMessageId: response.messages?.[0]?.id,
        direction: "OUTGOING",
        type: "text",
        text: messageText,
        status: "SENT",
        continueAi: continueAi !== undefined ? continueAi : undefined,
      },
    });

    const updateData = {
      lastMessageId: message.id,
      lastMessageAt: new Date(),
    };
    if (continueAi !== undefined) {
      updateData.continueAi = continueAi;
    }

    await prisma.whatsappConversation.update({
      where: { id: conversationId },
      data: updateData,
    });

    if (continueAi === false) {
      await NotificationService.createAndSendNotification({
        title: "Human Help Needed",
        message: "ai can't handle this customer, human help needed.",
        type: "HUMAN_HELP_NEEDED",
        businessId,
        branchId: account?.branchId || null,
        conversationId,
      });
    }

    return message;
  },

  sendMediaMessage: async (businessId, conversationId, type, mediaUrl) => {
    const conversation = await prisma.whatsappConversation.findUnique({
      where: { id: conversationId },
      include: { contact: true, whatsappAccount: true },
    });

    if (!conversation) throw new Error("Conversation not found");

    const account = conversation.whatsappAccount;
    const contact = conversation.contact;

    const response = await MetaGraphAPI.sendMedia(
      account.phoneNumberId,
      account.accessToken,
      contact.phoneNumber,
      type,
      mediaUrl
    );

    const message = await prisma.whatsappMessage.create({
      data: {
        businessId,
        whatsappAccountId: account.id,
        conversationId,
        contactId: contact.id,
        metaMessageId: response.messages?.[0]?.id,
        direction: "OUTGOING",
        type: type,
        mediaUrl: mediaUrl,
        status: "SENT",
      },
    });

    await prisma.whatsappConversation.update({
      where: { id: conversationId },
      data: { lastMessageId: message.id, lastMessageAt: new Date() },
    });

    return message;
  },

  markConversationAsRead: async (businessId, conversationId) => {
    const messages = await prisma.whatsappMessage.findMany({
      where: {
        businessId,
        conversationId,
        direction: "INCOMING",
        status: "DELIVERED",
      },
    });

    if (messages.length === 0) return;

    const conversation = await prisma.whatsappConversation.findUnique({
      where: { id: conversationId },
      include: { whatsappAccount: true },
    });

    for (const msg of messages) {
      if (msg.metaMessageId) {
        try {
          await MetaGraphAPI.markAsRead(
            conversation.whatsappAccount.phoneNumberId,
            conversation.whatsappAccount.accessToken,
            msg.metaMessageId
          );
        } catch (e) {
          console.error("Error marking message as read:", e);
        }
      }
    }

    await prisma.whatsappConversation.update({
      where: { id: conversationId },
      data: { unreadCount: 0 },
    });
  },

  connectOAuthAccount: async (businessId, branchId, code, redirectUri) => {
    // 1. Exchange authorization code for access token
    const userAccessToken = await MetaGraphAPI.getAccessToken(code, redirectUri);

    // 2. Fetch shared WABA accounts
    const wabas = await MetaGraphAPI.getWabaAccounts(userAccessToken);
    if (!wabas || wabas.length === 0) {
      throw new Error("No shared WhatsApp Business Accounts found.");
    }

    const connectedAccounts = [];

    // 3. For each shared WABA, fetch phone numbers and save
    for (const waba of wabas) {
      const wabaId = waba.id;
      const phoneNumbers = await MetaGraphAPI.getWabaPhoneNumbers(wabaId, userAccessToken);
      
      if (phoneNumbers && phoneNumbers.length > 0) {
        for (const phone of phoneNumbers) {
          const account = await prisma.whatsappAccount.upsert({
            where: {
              businessId_phoneNumberId: {
                businessId,
                phoneNumberId: phone.id,
              },
            },
            update: {
              wabaId,
              phoneNumber: phone.display_phone_number,
              accessToken: userAccessToken,
              status: "ACTIVE",
              branchId: branchId || null,
            },
            create: {
              businessId,
              branchId: branchId || null,
              wabaId,
              phoneNumberId: phone.id,
              phoneNumber: phone.display_phone_number,
              accessToken: userAccessToken,
              status: "ACTIVE",
            },
          });
          
          connectedAccounts.push({
            id: account.id,
            phoneNumber: account.phoneNumber,
            wabaId: account.wabaId,
            phoneNumberId: account.phoneNumberId,
          });
        }
      }
    }

    if (connectedAccounts.length === 0) {
      throw new Error("No phone numbers found under the shared WhatsApp Business Accounts.");
    }

    return connectedAccounts;
  },

  getMediaStream: async (businessId, mediaId) => {
    const account = await prisma.whatsappAccount.findFirst({
      where: { businessId, status: "ACTIVE" },
    });
    if (!account) {
      throw new Error("Active WhatsApp account not found for this business");
    }

    const mediaInfo = await MetaGraphAPI.getMediaUrl(mediaId, account.accessToken);
    if (!mediaInfo || !mediaInfo.url) {
      throw new Error("Failed to retrieve media URL from WhatsApp");
    }

    const streamResponse = await MetaGraphAPI.downloadMedia(mediaInfo.url, account.accessToken);

    return {
      stream: streamResponse.data,
      mimeType: mediaInfo.mime_type || streamResponse.headers["content-type"],
      fileSize: mediaInfo.file_size || streamResponse.headers["content-length"],
    };
  },
};
