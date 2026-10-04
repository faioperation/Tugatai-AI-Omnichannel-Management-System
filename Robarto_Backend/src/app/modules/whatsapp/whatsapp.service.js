import prisma from "../../prisma/client.js";
import { MetaGraphAPI } from "./whatsapp.meta.js";
import { EvolutionAPI } from "./whatsapp.evolution.js";
import { envVars } from "../../config/env.js";
import { NotificationService } from "../notification/notification.service.js";

export const WhatsappService = {
  connectAccount: async (businessId, payload) => {
    // Clean up any existing connection for this WhatsApp phone number under a DIFFERENT business
    await prisma.whatsappAccount.deleteMany({
      where: {
        phoneNumberId: payload.phoneNumberId,
        businessId: { not: businessId },
      },
    });

    return await prisma.whatsappAccount.upsert({
      where: {
        businessId_phoneNumberId: {
          businessId,
          phoneNumberId: payload.phoneNumberId,
        },
      },
      update: {
        connectionType: "META_CLOUD_API",
        wabaId: payload.wabaId,
        phoneNumber: payload.phoneNumber,
        accessToken: payload.accessToken,
        status: "ACTIVE",
        branchId: payload.branchId || null,
      },
      create: {
        businessId,
        branchId: payload.branchId || null,
        connectionType: "META_CLOUD_API",
        wabaId: payload.wabaId,
        phoneNumberId: payload.phoneNumberId,
        phoneNumber: payload.phoneNumber,
        accessToken: payload.accessToken,
        status: "ACTIVE",
      },
    });
  },

  connectQrAccount: async (businessId, branchId = null) => {
    const instanceName = `biz_${businessId.replace(/[^a-zA-Z0-9]/g, "").slice(0, 16)}_${Date.now()}`;
    const webhookUrl = `${envVars.BACKEND_URL}/api/v1/whatsapp/webhook/evolution`;

    // 1. Create or get instance from Evolution API
    const instanceData = await EvolutionAPI.createInstance(instanceName, webhookUrl);

    let qrCode = instanceData.qrcode?.base64 || instanceData.base64 || instanceData.code || null;

    // If QR code is not immediately in create response, try to fetch it
    if (!qrCode) {
      try {
        const connectData = await EvolutionAPI.connectInstance(instanceName);
        qrCode = connectData.base64 || connectData.code || null;
      } catch (err) {
        console.warn("[Evolution API] Could not fetch immediate QR code:", err.message);
      }
    }

    // 2. Upsert account record
    const account = await prisma.whatsappAccount.upsert({
      where: {
        businessId_instanceName: {
          businessId,
          instanceName,
        },
      },
      update: {
        connectionType: "QR_CODE",
        branchId: branchId || null,
        status: "INACTIVE",
        qrCode: qrCode || null,
      },
      create: {
        businessId,
        branchId: branchId || null,
        connectionType: "QR_CODE",
        instanceName,
        status: "INACTIVE",
        qrCode: qrCode || null,
      },
    });

    return {
      accountId: account.id,
      instanceName,
      qrCode,
      status: account.status,
    };
  },

  getQrCodeStatus: async (businessId, instanceName) => {
    const account = await prisma.whatsappAccount.findFirst({
      where: { businessId, instanceName },
    });

    if (!account) throw new Error("WhatsApp QR instance not found");

    const state = await EvolutionAPI.getConnectionState(instanceName);

    let qrCode = account.qrCode;
    if (state !== "open") {
      try {
        const connectData = await EvolutionAPI.connectInstance(instanceName);
        qrCode = connectData.base64 || connectData.code || qrCode;
        if (qrCode !== account.qrCode) {
          await prisma.whatsappAccount.update({
            where: { id: account.id },
            data: { qrCode },
          });
        }
      } catch (e) {}
    }

    if (state === "open" && account.status !== "ACTIVE") {
      await prisma.whatsappAccount.update({
        where: { id: account.id },
        data: { status: "ACTIVE", qrCode: null },
      });
    }

    return {
      connected: state === "open",
      state,
      qrCode: state === "open" ? null : qrCode,
    };
  },

  disconnectAccount: async (businessId, accountId) => {
    const account = await prisma.whatsappAccount.findFirst({
      where: { id: accountId, businessId },
    });

    if (account?.connectionType === "QR_CODE" && account.instanceName) {
      await EvolutionAPI.logoutInstance(account.instanceName);
      await EvolutionAPI.deleteInstance(account.instanceName);
    }

    return await prisma.whatsappAccount.updateMany({
      where: { id: accountId, businessId },
      data: { status: "DISCONNECTED", qrCode: null },
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

    let metaMsgId = null;

    if (account.connectionType === "QR_CODE") {
      const evoRes = await EvolutionAPI.sendMessage(
        account.instanceName,
        contact.phoneNumber,
        messageText
      );
      metaMsgId = evoRes?.key?.id || `evo_out_${Date.now()}`;
    } else {
      const response = await MetaGraphAPI.sendMessage(
        account.phoneNumberId,
        account.accessToken,
        contact.phoneNumber,
        messageText
      );
      metaMsgId = response.messages?.[0]?.id;
    }

    const message = await prisma.whatsappMessage.create({
      data: {
        businessId,
        whatsappAccountId: account.id,
        conversationId,
        contactId: contact.id,
        metaMessageId: metaMsgId,
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

    let metaMsgId = null;

    if (account.connectionType === "QR_CODE") {
      const evoRes = await EvolutionAPI.sendMedia(
        account.instanceName,
        contact.phoneNumber,
        type,
        mediaUrl
      );
      metaMsgId = evoRes?.key?.id || `evo_out_media_${Date.now()}`;
    } else {
      const response = await MetaGraphAPI.sendMedia(
        account.phoneNumberId,
        account.accessToken,
        contact.phoneNumber,
        type,
        mediaUrl
      );
      metaMsgId = response.messages?.[0]?.id;
    }

    const message = await prisma.whatsappMessage.create({
      data: {
        businessId,
        whatsappAccountId: account.id,
        conversationId,
        contactId: contact.id,
        metaMessageId: metaMsgId,
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
