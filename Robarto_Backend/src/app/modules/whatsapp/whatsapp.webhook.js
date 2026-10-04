import prisma from "../../prisma/client.js";
import { notifyAiAgent } from "../../utils/aiAgent.js";
import { NotificationService } from "../notification/notification.service.js";
import { isConversationLimitReached } from "../../utils/limitChecker.js";
import { envVars } from "../../config/env.js";
import { MetaGraphAPI } from "./whatsapp.meta.js";
import { downloadAndSaveMedia } from "../../utils/mediaDownloader.js";

export const handleWebhookEvent = async (body) => {
  if (body.object === "whatsapp_business_account") {
    for (const entry of body.entry) {
      for (const change of entry.changes) {
        if (change.value && change.value.messages) {
          await processIncomingMessages(change.value);
        }
        if (change.value && change.value.statuses) {
          await processMessageStatuses(change.value);
        }
      }
    }
  }
};

const processIncomingMessages = async (value) => {
  const phoneNumberId = value.metadata.phone_number_id;
  const contacts = value.contacts;
  const messages = value.messages;

  if (!contacts || !messages) return;

  // Find the WhatsApp Account by phone_number_id
  const account = await prisma.whatsappAccount.findFirst({
    where: { phoneNumberId, status: "ACTIVE" },
  });

  if (!account) return;

  const businessId = account.businessId;

  for (const contact of contacts) {
    const waUserId = contact.wa_id;
    const name = contact.profile?.name;
    const phoneNumber = waUserId;

    // Check if conversation already exists before checking limits
    const existingContact = await prisma.whatsappContact.findUnique({
      where: {
        businessId_waUserId: { businessId, waUserId },
      },
    });

    let existingConv = null;
    if (existingContact) {
      existingConv = await prisma.whatsappConversation.findUnique({
        where: {
          businessId_contactId: { businessId, contactId: existingContact.id },
        },
      });
    }

    if (!existingConv) {
      const limitReached = await isConversationLimitReached(businessId);
      if (limitReached) {
        console.warn(`[WhatsApp Webhook] Conversation limit reached for business: ${businessId}. Ignoring incoming message.`);
        continue;
      }
    }

    // Upsert Contact
    const dbContact = await prisma.whatsappContact.upsert({
      where: {
        businessId_waUserId: { businessId, waUserId },
      },
      update: {
        name: name || undefined,
        lastMessageAt: new Date(),
      },
      create: {
        businessId,
        whatsappAccountId: account.id,
        waUserId,
        phoneNumber,
        name,
        lastMessageAt: new Date(),
      },
    });

    // Upsert Conversation
    const conversation = await prisma.whatsappConversation.upsert({
      where: {
        businessId_contactId: { businessId, contactId: dbContact.id },
      },
      update: {
        unreadCount: { increment: 1 },
        seen: false,
        lastMessageAt: new Date(),
      },
      create: {
        businessId,
        whatsappAccountId: account.id,
        contactId: dbContact.id,
        unreadCount: 1,
        seen: false,
        lastMessageAt: new Date(),
      },
    });

    for (const message of messages) {
      const type = message.type;
      let text = null;
      let mediaUrl = null;
      let localMediaUrl = null;
      let location = null;

      if (type === "text") {
        text = message.text.body;
      } else if (type === "location") {
        location = message.location;
      } else if (["image", "video", "audio", "document", "sticker"].includes(type)) {
        const mediaObj = message[type];
        mediaUrl = mediaObj.id; // Store Media ID, to be fetched if necessary

        try {
          const mediaInfo = await MetaGraphAPI.getMediaUrl(mediaUrl, account.accessToken);
          if (mediaInfo && mediaInfo.url) {
            const downloadRes = await downloadAndSaveMedia(
              mediaInfo.url,
              "whatsapp",
              "wa",
              { Authorization: `Bearer ${account.accessToken}` }
            );
            if (downloadRes.success) {
              localMediaUrl = downloadRes.publicUrl;
            }
          }
        } catch (downloadErr) {
          console.error("[WhatsApp Webhook] Error downloading WhatsApp media:", downloadErr);
        }
      }

      await prisma.whatsappMessage.create({
        data: {
          businessId,
          whatsappAccountId: account.id,
          conversationId: conversation.id,
          contactId: dbContact.id,
          metaMessageId: message.id,
          direction: "INCOMING",
          type,
          text,
          mediaUrl: localMediaUrl || mediaUrl,
          location,
          rawPayload: message,
          status: "DELIVERED",
        },
      });

      // Trigger notification for incoming WhatsApp message with throttling
      NotificationService.shouldSendMessageNotification(conversation.id, "whatsapp").then((shouldNotify) => {
        if (shouldNotify) {
          NotificationService.createAndSendNotification({
            title: "New WhatsApp Message",
            message: `Message: "${text || "Attachment/Other"}"`,
            type: "NEW_MESSAGE",
            businessId: businessId,
            branchId: account.branchId || null,
            conversationId: conversation.id,
          }).catch(err => console.error("Error sending WhatsApp incoming message notification:", err));
        }
      }).catch(err => console.error("Error checking WhatsApp throttling:", err));

      // Update conversation's last message ID
      await prisma.whatsappConversation.update({
        where: { id: conversation.id },
        data: { lastMessageId: message.id },
      });

      // Construct AI message body (if text, send body; if media, send proxy media URL)
      let aiMessage = "";
      if (type === "text") {
        aiMessage = text || "";
      } else if (type === "location" && location) {
        aiMessage = `[Location: latitude ${location.latitude}, longitude ${location.longitude}]`;
      } else if (mediaUrl) {
        const urlToSend = localMediaUrl || `${envVars.BACKEND_URL}/v1/whatsapp/media/${mediaUrl}`;
        aiMessage = `[Media ${type}: ${urlToSend}]`;
      }

      // Notify AI Agent of incoming WhatsApp message
      notifyAiAgent({
        businessId,
        recipientId: waUserId,
        conversationId: conversation.id,
        channel: "whatsapp",
        message: aiMessage
      });
    }
  }
};

const processMessageStatuses = async (value) => {
  const statuses = value.statuses;
  if (!statuses) return;

  for (const status of statuses) {
    const messageId = status.id;
    const statusType = status.status; // 'sent', 'delivered', 'read', 'failed'

    const mappedStatus = statusType.toUpperCase();

    if (["SENT", "DELIVERED", "READ", "FAILED"].includes(mappedStatus)) {
      await prisma.whatsappMessage.updateMany({
        where: { metaMessageId: messageId },
        data: { status: mappedStatus },
      });
    }
  }
};

export const handleEvolutionWebhookEvent = async (body) => {
  const event = body.event || body.type || "";
  const instanceName = body.instance;

  console.log(`[Evolution Webhook] Received event: "${event}" for instance: "${instanceName}"`);

  let account = null;
  if (instanceName) {
    account = await prisma.whatsappAccount.findFirst({
      where: { instanceName },
    });
  }

  // Fallback by sender phone if instanceName lookup fails
  if (!account && (body.sender || body.data?.wuid)) {
    const rawSender = body.sender || body.data?.wuid;
    const phone = rawSender.replace("@s.whatsapp.net", "").replace(/\D/g, "");
    account = await prisma.whatsappAccount.findFirst({
      where: { phoneNumber: phone, status: "ACTIVE" },
    });
  }

  if (!account) {
    console.warn(`[Evolution Webhook] No matching WhatsappAccount found for instance: "${instanceName}"`);
    return;
  }
  const businessId = account.businessId;

  const eventNormalized = event.toLowerCase().replace(/[-_.]/g, "");

  // Handle Connection Status updates
  if (eventNormalized.includes("connectionupdate") || eventNormalized === "connection") {
    const state = body.data?.state || body.state;
    const wuid = body.data?.wuid || body.sender;
    const phone = wuid ? wuid.replace("@s.whatsapp.net", "").replace(/\D/g, "") : null;

    if (state === "open") {
      await prisma.whatsappAccount.update({
        where: { id: account.id },
        data: {
          status: "ACTIVE",
          qrCode: null,
          ...(phone ? { phoneNumber: phone } : {}),
        },
      });
      console.log(`[Evolution Webhook] Instance "${instanceName}" is now ACTIVE. Phone: ${phone}`);
    } else if (state === "close") {
      await prisma.whatsappAccount.update({
        where: { id: account.id },
        data: { status: "DISCONNECTED" },
      });
      console.log(`[Evolution Webhook] Instance "${instanceName}" is now DISCONNECTED.`);
    }
    return;
  }

  // Handle QR Code updates
  if (eventNormalized.includes("qrcodeupdated") || eventNormalized.includes("qrcode")) {
    const qrcode = body.data?.qrcode?.base64 || body.qrcode?.base64 || body.data?.base64;
    if (qrcode) {
      await prisma.whatsappAccount.update({
        where: { id: account.id },
        data: { qrCode: qrcode },
      });
    }
    return;
  }

  // Handle Incoming Messages
  if (eventNormalized.includes("messagesupsert") || eventNormalized.includes("messageupsert") || eventNormalized === "message" || eventNormalized === "messages") {
    const rawItems = Array.isArray(body.data)
      ? body.data
      : (Array.isArray(body.data?.messages) ? body.data.messages : [body.data]);

    for (const item of rawItems) {
      if (!item) continue;
      const key = item.key || item.message?.key;

      console.log(`[Evolution Webhook] Processing message item:`, {
        fromMe: key?.fromMe,
        remoteJid: key?.remoteJid,
        pushName: item.pushName || body.data?.pushName,
      });

      if (!key || key.fromMe) {
        console.log(`[Evolution Webhook] Skipped message because key is missing or fromMe is true.`);
        continue; // Skip outgoing messages
      }

      const remoteJid = key.remoteJid || "";
      if (remoteJid.includes("@g.us")) continue; // Skip group messages

      const phoneNumber = remoteJid.replace("@s.whatsapp.net", "").replace(/\D/g, "");
      const waUserId = phoneNumber;
      const name = item.pushName || body.data?.pushName || "Customer";

      // Extract Message text / media
      let text = null;
      let type = "text";
      let mediaUrl = null;

      const rawMsg = item.message || {};
      if (rawMsg.conversation) {
        text = rawMsg.conversation;
      } else if (rawMsg.extendedTextMessage?.text) {
        text = rawMsg.extendedTextMessage.text;
      } else if (rawMsg.imageMessage) {
        type = "image";
        text = rawMsg.imageMessage.caption || null;
        mediaUrl = rawMsg.imageMessage.url || null;
      } else if (rawMsg.videoMessage) {
        type = "video";
        text = rawMsg.videoMessage.caption || null;
        mediaUrl = rawMsg.videoMessage.url || null;
      } else if (rawMsg.audioMessage) {
        type = "audio";
        mediaUrl = rawMsg.audioMessage.url || null;
      } else if (rawMsg.documentMessage) {
        type = "document";
        text = rawMsg.documentMessage.fileName || "document";
        mediaUrl = rawMsg.documentMessage.url || null;
      }

      if (!text && !mediaUrl) continue;

      // Check conversation limit
      const existingContact = await prisma.whatsappContact.findUnique({
        where: {
          businessId_waUserId: { businessId, waUserId },
        },
      });

      let existingConv = null;
      if (existingContact) {
        existingConv = await prisma.whatsappConversation.findUnique({
          where: {
            businessId_contactId: { businessId, contactId: existingContact.id },
          },
        });
      }

      if (!existingConv) {
        const limitReached = await isConversationLimitReached(businessId);
        if (limitReached) {
          console.warn(`[Evolution Webhook] Conversation limit reached for business: ${businessId}.`);
          continue;
        }
      }

      // Upsert Contact
      const dbContact = await prisma.whatsappContact.upsert({
        where: {
          businessId_waUserId: { businessId, waUserId },
        },
        update: {
          name: name || undefined,
          phoneNumber,
          lastMessageAt: new Date(),
        },
        create: {
          businessId,
          whatsappAccountId: account.id,
          waUserId,
          phoneNumber,
          name,
          lastMessageAt: new Date(),
        },
      });

      // Upsert Conversation
      const conversation = await prisma.whatsappConversation.upsert({
        where: {
          businessId_contactId: { businessId, contactId: dbContact.id },
        },
        update: {
          unreadCount: { increment: 1 },
          seen: false,
          lastMessageAt: new Date(),
        },
        create: {
          businessId,
          whatsappAccountId: account.id,
          contactId: dbContact.id,
          unreadCount: 1,
          seen: false,
          lastMessageAt: new Date(),
        },
      });

      const msgId = key.id || `evo_${Date.now()}`;

      // Create incoming message record
      await prisma.whatsappMessage.create({
        data: {
          businessId,
          whatsappAccountId: account.id,
          conversationId: conversation.id,
          contactId: dbContact.id,
          metaMessageId: msgId,
          direction: "INCOMING",
          type,
          text,
          mediaUrl,
          rawPayload: item,
          status: "DELIVERED",
        },
      });

      // Update conversation last message ID
      await prisma.whatsappConversation.update({
        where: { id: conversation.id },
        data: { lastMessageId: msgId },
      });

      console.log(`[Evolution Webhook] Saved incoming WhatsApp message from ${phoneNumber}: "${text}"`);

      // Send notifications
      NotificationService.shouldSendMessageNotification(conversation.id, "whatsapp").then((shouldNotify) => {
        if (shouldNotify) {
          NotificationService.createAndSendNotification({
            title: "New WhatsApp Message",
            message: `Message: "${text || "Attachment/Other"}"`,
            type: "NEW_MESSAGE",
            businessId,
            branchId: account.branchId || null,
            conversationId: conversation.id,
          }).catch(err => console.error("Error sending incoming message notification:", err));
        }
      }).catch(err => console.error("Error checking throttling:", err));

      // Notify AI Agent
      notifyAiAgent({
        businessId,
        recipientId: waUserId,
        conversationId: conversation.id,
        channel: "whatsapp",
        message: text || `[Media ${type}]`,
      });
    }
  }
};

