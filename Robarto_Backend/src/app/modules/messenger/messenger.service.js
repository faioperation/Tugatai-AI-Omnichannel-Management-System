import axios from "axios";
import prisma from "../../prisma/client.js";
import { envVars } from "../../config/env.js";
import { AppError } from "../../errorHelper/appError.js";
import { notifyAiAgent } from "../../utils/aiAgent.js";
import { NotificationService } from "../notification/notification.service.js";
import { isConversationLimitReached } from "../../utils/limitChecker.js";
import { downloadAndSaveMedia } from "../../utils/mediaDownloader.js";

const getGraphUrl = () => `https://graph.facebook.com/${envVars.META_GRAPH_VERSION || "v23.0"}`;

const getMessengerUserProfile = async (psid, pageAccessToken) => {
  try {
    const response = await axios.get(
      `${getGraphUrl()}/me/conversations`,
      {
        params: {
          user_id: psid,
          fields: "participants",
          access_token: pageAccessToken,
        },
      }
    );
    const conversations = response.data?.data;
    if (conversations && conversations.length > 0) {
      const participants = conversations[0].participants?.data;
      if (participants) {
        const customer = participants.find((p) => p.id === psid);
        if (customer && customer.name) {
          return { name: customer.name };
        }
      }
    }
    return { name: "Social Customer" };
  } catch (error) {
    console.error("Error fetching Messenger user profile from conversations:", error.response?.data || error.message);
    return { name: "Social Customer" };
  }
};

export const handleIncomingMessage = async (pageId, webhookEvent) => {
  const senderId = webhookEvent.sender.id;
  const messageText = webhookEvent.message.text;
  const platformMessageId = webhookEvent.message.mid;

  // Find the social connection for this page to identify the business
  const connection = await prisma.socialConnection.findFirst({
    where: { pageId, provider: "facebook", isActive: true },
  });

  if (!connection) {
    console.warn(`Received message for unconnected page: ${pageId}`);
    return;
  }

  const businessId = connection.businessId;

  // Fetch customerName if conversation doesn't exist or is missing name
  const existingConv = await prisma.conversation.findUnique({
    where: {
      businessId_platform_customerId: {
        businessId,
        platform: "messenger",
        customerId: senderId,
      },
    },
  });

  if (!existingConv) {
    const limitReached = await isConversationLimitReached(businessId);
    if (limitReached) {
      console.warn(`[Messenger Webhook] Conversation limit reached for business: ${businessId}. Ignoring incoming message.`);
      return;
    }
  }

  let customerName = existingConv?.customerName;
  if (!customerName || customerName === "Social Customer") {
    const profile = await getMessengerUserProfile(senderId, connection.accessToken);
    customerName = profile.name;
  }

  // Could be an image or other attachment
  const attachments = webhookEvent.message?.attachments;
  let lastMessageContent = messageText;
  if (!lastMessageContent && attachments && attachments.length > 0) {
    lastMessageContent = `[Media: ${attachments[0].type}]`;
  }
  if (!lastMessageContent) lastMessageContent = "Attachment/Other";

  // Create or update conversation
  const conversation = await prisma.conversation.upsert({
    where: {
      businessId_platform_customerId: {
        businessId,
        platform: "messenger",
        customerId: senderId,
      },
    },
    update: {
      lastMessage: lastMessageContent,
      lastMessageAt: new Date(),
      branchId: connection.branchId || null,
      customerName: customerName || undefined,
      seen: false,
    },
    create: {
      businessId,
      branchId: connection.branchId || null,
      platform: "messenger",
      customerId: senderId,
      customerName: customerName || "Social Customer",
      lastMessage: lastMessageContent,
      lastMessageAt: new Date(),
      seen: false,
    },
  });

  let localMediaUrl = null;
  if (attachments && attachments.length > 0) {
    const attachmentUrl = attachments[0].payload?.url;
    if (attachmentUrl) {
      try {
        const downloadRes = await downloadAndSaveMedia(attachmentUrl, "messenger", "msg");
        if (downloadRes.success) {
          localMediaUrl = downloadRes.publicUrl;
        }
      } catch (downloadErr) {
        console.error("[Messenger Service] Error downloading messenger media:", downloadErr);
      }
    }
  }

  // Save the message
  await prisma.message.create({
    data: {
      conversationId: conversation.id,
      senderType: "customer",
      senderId: senderId,
      messageText: messageText,
      platformMessageId: platformMessageId,
      rawPayload: webhookEvent,
      type: attachments ? "media" : "text",
      mediaUrl: localMediaUrl || (attachments ? attachments[0].payload?.url : null),
    },
  });

  // Trigger notification for incoming Messenger message with throttling
  NotificationService.shouldSendMessageNotification(conversation.id, "messenger").then((shouldNotify) => {
    if (shouldNotify) {
      NotificationService.createAndSendNotification({
        title: "New Messenger Message",
        message: `Message: "${messageText || lastMessageContent}"`,
        type: "NEW_MESSAGE",
        businessId: businessId,
        branchId: connection.branchId || null,
        conversationId: conversation.id,
      }).catch(err => console.error("Error sending Messenger incoming message notification:", err));
    }
  }).catch(err => console.error("Error checking Messenger throttling:", err));

  // Construct AI message body (if text, send text; if media, send media URL)
  let aiMessage = messageText || "";
  if (!aiMessage && attachments && attachments.length > 0) {
    const attachmentUrl = localMediaUrl || attachments[0].payload?.url || "";
    aiMessage = `[Media ${attachments[0].type}: ${attachmentUrl}]`;
  }

  // Notify AI Agent of incoming Messenger message
  notifyAiAgent({
    businessId,
    recipientId: senderId,
    conversationId: conversation.id,
    channel: "messenger",
    message: aiMessage
  });
};

export const sendMessageToUser = async (businessId, recipientId, messageText, senderType = "business", continueAi = undefined) => {
  // Get connection to find page access token
  const connection = await prisma.socialConnection.findFirst({
    where: { businessId, provider: "facebook", isActive: true },
  });

  if (!connection) {
    throw new AppError(404, "No active Facebook page connection found for this business.");
  }

  const payload = {
    recipient: { id: recipientId },
    message: { text: messageText },
  };

  try {
    const response = await axios.post(
      `${getGraphUrl()}/me/messages`,
      payload,
      {
        params: {
          access_token: connection.accessToken,
        },
      }
    );

    // Save the outgoing message to Prisma
    const conversation = await prisma.conversation.findUnique({
      where: {
        businessId_platform_customerId: {
          businessId,
          platform: "messenger",
          customerId: recipientId,
        },
      },
    });

    if (conversation) {
      await prisma.message.create({
        data: {
          conversationId: conversation.id,
          senderType: senderType,
          senderId: connection.pageId, // Sent by page
          messageText: messageText,
          platformMessageId: response.data.message_id,
          rawPayload: response.data,
          continueAi: continueAi !== undefined ? continueAi : undefined,
        },
      });

      // Update last message and continueAi status
      const updateData = {
        lastMessage: messageText,
        lastMessageAt: new Date(),
      };
      if (continueAi !== undefined) {
        updateData.continueAi = continueAi;
      }

      await prisma.conversation.update({
        where: { id: conversation.id },
        data: updateData,
      });

      if (continueAi === false) {
        await NotificationService.createAndSendNotification({
          title: "Human Help Needed",
          message: "ai can't handle this customer, human help needed.",
          type: "HUMAN_HELP_NEEDED",
          businessId: conversation.businessId,
          branchId: conversation.branchId || null,
          conversationId: conversation.id,
        });
      }
    }

    return response.data;
  } catch (error) {
    console.error("Error sending message via Messenger API:", error.response?.data || error.message);
    throw new AppError(500, "Failed to send message via Facebook Messenger API.");
  }
};

export const sendMediaMessageToUser = async (businessId, recipientId, type, mediaUrl, filePath) => {
  const connection = await prisma.socialConnection.findFirst({
    where: { businessId, provider: "facebook", isActive: true },
  });

  if (!connection) {
    throw new AppError(404, "No active Facebook page connection found for this business.");
  }

  // Messenger API type needs to be one of: image, video, audio, file
  let attachmentType = type;
  if (type === "document") attachmentType = "file";

  const payload = {
    recipient: { id: recipientId },
    message: {
      attachment: {
        type: attachmentType,
        payload: {
          url: mediaUrl,
          is_reusable: true
        }
      }
    }
  };

  try {
    const response = await axios.post(
      `${getGraphUrl()}/me/messages`,
      payload,
      { params: { access_token: connection.accessToken } }
    );

    const conversation = await prisma.conversation.findUnique({
      where: {
        businessId_platform_customerId: {
          businessId,
          platform: "messenger",
          customerId: recipientId,
        },
      },
    });

    if (conversation) {
      await prisma.message.create({
        data: {
          conversationId: conversation.id,
          senderType: "business",
          senderId: connection.pageId,
          type: type,
          messageText: `[Media: ${attachmentType}]`,
          mediaUrl: mediaUrl,
          filePath: filePath,
          platformMessageId: response.data.message_id,
          rawPayload: response.data,
        },
      });

      await prisma.conversation.update({
        where: { id: conversation.id },
        data: {
          lastMessage: `[Media: ${attachmentType}]`,
          lastMessageAt: new Date(),
        },
      });
    }

    return response.data;
  } catch (error) {
    console.error("Error sending media via Messenger API:", error.response?.data || error.message);
    throw new AppError(500, "Failed to send media via Facebook Messenger API.");
  }
};

export const getConversations = async (businessId, branchId) => {
  const whereClause = { businessId, platform: "messenger" };
  if (branchId) {
    whereClause.branchId = branchId;
  }

  const conversations = await prisma.conversation.findMany({
    where: whereClause,
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
};

export const getMessages = async (conversationId) => {
  const messages = await prisma.message.findMany({
    where: { conversationId },
    orderBy: { createdAt: 'asc' },
  });

  return messages.map((msg) => {
    if (msg.mediaUrl && !msg.mediaUrl.startsWith("http://") && !msg.mediaUrl.startsWith("https://")) {
      if (msg.mediaUrl.startsWith("uploads/")) {
        msg.mediaUrl = `${envVars.BACKEND_URL}/${msg.mediaUrl}`;
      } else {
        msg.mediaUrl = `${envVars.BACKEND_URL}/uploads/messenger/${msg.mediaUrl}`;
      }
    }
    return msg;
  });
};
