import axios from "axios";
import prisma from "../../prisma/client.js";
import { envVars } from "../../config/env.js";
import { AppError } from "../../errorHelper/appError.js";
import { notifyAiAgent } from "../../utils/aiAgent.js";
import { NotificationService } from "../notification/notification.service.js";
import { isConversationLimitReached } from "../../utils/limitChecker.js";
import { downloadAndSaveMedia } from "../../utils/mediaDownloader.js";

const getGraphUrl = () => `https://graph.facebook.com/${envVars.META_GRAPH_VERSION || "v23.0"}`;

const getInstagramUserProfile = async (igsid, pageAccessToken) => {
  try {
    const response = await axios.get(
      `${getGraphUrl()}/me/conversations`,
      {
        params: {
          platform: "instagram",
          user_id: igsid,
          fields: "participants",
          access_token: pageAccessToken,
        },
      }
    );
    const conversations = response.data?.data;
    if (conversations && conversations.length > 0) {
      const participants = conversations[0].participants?.data;
      if (participants) {
        const customer = participants.find((p) => p.id === igsid);
        if (customer && customer.name) {
          return { name: customer.name };
        }
      }
    }
    return { name: "Instagram User" };
  } catch (error) {
    console.error("Error fetching Instagram user profile from conversations:", error.response?.data || error.message);
    return { name: "Instagram User" };
  }
};

const extractMediaInfo = (messageObj) => {
  if (!messageObj) return { mediaUrl: null, mediaType: null, hasMedia: false };

  // 1. message.attachments (Array or Graph API { data: [...] })
  const atts = Array.isArray(messageObj.attachments)
    ? messageObj.attachments
    : (messageObj.attachments?.data || (messageObj.attachment ? [messageObj.attachment] : null));

  if (atts && atts.length > 0) {
    const first = atts[0];
    const url = first.payload?.url || first.image_data?.url || first.video_data?.url || first.file_url || first.url || null;
    const type = first.type || (first.image_data ? "image" : (first.video_data ? "video" : "media"));
    return { mediaUrl: url, mediaType: type, hasMedia: true };
  }

  // 2. Direct media object
  if (messageObj.media) {
    const url = typeof messageObj.media === "string" ? messageObj.media : (messageObj.media.url || messageObj.media.link);
    const type = messageObj.media.type || "image";
    return { mediaUrl: url, mediaType: type, hasMedia: true };
  }

  // 3. shares / story_share
  const shares = Array.isArray(messageObj.shares) ? messageObj.shares : (messageObj.shares?.data || null);
  if (shares && shares.length > 0) {
    const share = shares[0];
    const url = share.link || share.url || null;
    return { mediaUrl: url, mediaType: "image", hasMedia: true };
  }

  if (messageObj.story_share) {
    const url = messageObj.story_share.link || messageObj.story_share.url || null;
    return { mediaUrl: url, mediaType: "image", hasMedia: true };
  }

  return { mediaUrl: null, mediaType: null, hasMedia: false };
};

const fetchMediaFromMetaGraph = async (mid, accessToken) => {
  if (!mid || !accessToken) return null;
  try {
    const res = await axios.get(`${getGraphUrl()}/${mid}`, {
      params: {
        fields: "id,message,attachments,shares,story_share",
        access_token: accessToken,
      },
      timeout: 8000,
    });
    return extractMediaInfo(res.data);
  } catch (err) {
    return null;
  }
};

export const handleIncomingMessage = async (instagramAccountId, webhookEvent) => {
  const senderId = webhookEvent.sender.id;
  const messageText = webhookEvent.message?.text || null;
  const platformMessageId = webhookEvent.message?.mid || null;
  
  // Find the social connection for this instagram account to identify the business
  let connection = await prisma.socialConnection.findFirst({
    where: { pageId: instagramAccountId, provider: "instagram", isActive: true },
  });

  if (!connection && webhookEvent.recipient?.id) {
    connection = await prisma.socialConnection.findFirst({
      where: { pageId: webhookEvent.recipient.id, provider: "instagram", isActive: true },
    });
  }

  if (!connection) {
    const fbConnection = await prisma.socialConnection.findFirst({
      where: { pageId: instagramAccountId, provider: "facebook", isActive: true },
    });
    if (fbConnection) {
      connection = await prisma.socialConnection.findFirst({
        where: { businessId: fbConnection.businessId, provider: "instagram", isActive: true },
      });
    }
  }

  if (!connection) {
    // Fallback: match any active Instagram connection in system
    connection = await prisma.socialConnection.findFirst({
      where: { provider: "instagram", isActive: true },
      orderBy: { updatedAt: "desc" },
    });
  }

  if (!connection) {
    console.warn(`Received message for unconnected instagram account: ${instagramAccountId}`);
    return;
  }

  // Extract media info from incoming payload
  let { mediaUrl, mediaType, hasMedia } = extractMediaInfo(webhookEvent.message);

  // If no mediaUrl in webhook payload and text is empty, query Meta Graph API for attachment details
  if (!mediaUrl && !messageText && platformMessageId && connection.accessToken) {
    const fetched = await fetchMediaFromMetaGraph(platformMessageId, connection.accessToken);
    if (fetched && fetched.hasMedia) {
      mediaUrl = fetched.mediaUrl;
      mediaType = fetched.mediaType;
      hasMedia = true;
    }
  }

  let lastMessageContent = messageText;
  if (!lastMessageContent && hasMedia) {
    lastMessageContent = `[Media: ${mediaType || "image"}]`;
  }
  if (!lastMessageContent) lastMessageContent = "Attachment/Other";

  const businessId = connection.businessId;
  let branchId = connection.branchId || null;

  // Fetch customerName if conversation doesn't exist or is missing name
  const existingConv = await prisma.conversation.findUnique({
    where: {
      businessId_platform_customerId: {
        businessId,
        platform: "instagram",
        customerId: senderId,
      },
    },
  });

  if (!branchId) {
    if (existingConv?.branchId) {
      branchId = existingConv.branchId;
    } else {
      const firstBranch = await prisma.branch.findFirst({
        where: { businessId },
        orderBy: { createdAt: "asc" },
      });
      if (firstBranch) {
        branchId = firstBranch.id;
      }
    }
    if (branchId) {
      await prisma.socialConnection.update({
        where: { id: connection.id },
        data: { branchId },
      }).catch(() => {});
    }
  }

  if (!existingConv) {
    const limitReached = await isConversationLimitReached(businessId);
    if (limitReached) {
      console.warn(`[Instagram Webhook] Conversation limit reached for business: ${businessId}. Ignoring incoming message.`);
      return;
    }
  }

  let customerName = existingConv?.customerName;
  if (!customerName || customerName === "Instagram User") {
    const profile = await getInstagramUserProfile(senderId, connection.accessToken);
    customerName = profile.name;
  }

  // Create or update conversation
  const conversation = await prisma.conversation.upsert({
    where: {
      businessId_platform_customerId: {
        businessId,
        platform: "instagram",
        customerId: senderId,
      },
    },
    update: {
      lastMessage: lastMessageContent,
      lastMessageAt: new Date(),
      branchId: branchId || existingConv?.branchId || null,
      customerName: customerName || undefined,
      seen: false,
    },
    create: {
      businessId,
      branchId: branchId || null,
      platform: "instagram",
      customerId: senderId,
      customerName: customerName || "Instagram User",
      lastMessage: lastMessageContent,
      lastMessageAt: new Date(),
      seen: false,
    },
  });

  let localMediaUrl = null;
  if (mediaUrl) {
    try {
      const downloadRes = await downloadAndSaveMedia(mediaUrl, "instagram", "ig", {
        Authorization: `Bearer ${connection.accessToken}`,
      });
      if (downloadRes.success) {
        localMediaUrl = downloadRes.publicUrl;
      }
    } catch (downloadErr) {
      console.error("[Instagram Service] Error downloading instagram media:", downloadErr);
    }
  }

  const resolvedMediaUrl = localMediaUrl || mediaUrl || null;
  const isMediaType = hasMedia || !!resolvedMediaUrl;

  // Save the message
  await prisma.message.create({
    data: {
      conversationId: conversation.id,
      senderType: "customer",
      senderId: senderId,
      messageText: messageText || (isMediaType ? "" : null),
      platformMessageId: platformMessageId,
      rawPayload: webhookEvent,
      type: isMediaType ? (mediaType || "image") : "text",
      mediaUrl: resolvedMediaUrl,
    },
  });

  // Trigger notification for incoming Instagram message with throttling
  NotificationService.shouldSendMessageNotification(conversation.id, "instagram").then((shouldNotify) => {
    if (shouldNotify) {
      NotificationService.createAndSendNotification({
        title: "New Instagram Message",
        message: `Message: "${messageText || lastMessageContent}"`,
        type: "NEW_MESSAGE",
        businessId: businessId,
        branchId: connection.branchId || null,
        conversationId: conversation.id,
      }).catch(err => console.error("Error sending Instagram incoming message notification:", err));
    }
  }).catch(err => console.error("Error checking Instagram throttling:", err));

  // Construct AI message body (if text, send text; if media, send media URL)
  let aiMessage = messageText || "";
  if (!aiMessage && isMediaType) {
    const urlToSend = resolvedMediaUrl || "";
    aiMessage = `[Media ${mediaType || "image"}: ${urlToSend}]`;
  }

  // Notify AI Agent of incoming Instagram message
  notifyAiAgent({
    businessId,
    recipientId: senderId,
    conversationId: conversation.id,
    channel: "instagram",
    message: aiMessage
  });
};

export const sendMessageToUser = async (businessId, recipientId, messageText, senderType = "business", continueAi = undefined) => {
  // Get connection to find access token
  const connection = await prisma.socialConnection.findFirst({
    where: { businessId, provider: "instagram", isActive: true },
  });

  if (!connection) {
    throw new AppError(404, "No active Instagram connection found for this business.");
  }

  const payload = {
    recipient: { id: recipientId },
    message: { text: messageText },
  };

  let response;
  const errors = [];

  try {
    try {
      response = await axios.post(
        `${getGraphUrl()}/me/messages`,
        payload,
        {
          params: {
            access_token: connection.accessToken,
          },
        }
      );
    } catch (meError) {
      const errDetail = meError.response?.data || meError.message;
      errors.push(`/me/messages: ${JSON.stringify(errDetail)}`);
      console.warn("Instagram /me/messages failed, retrying with pageId endpoint:", errDetail);
      
      try {
        response = await axios.post(
          `${getGraphUrl()}/${connection.pageId}/messages`,
          payload,
          {
            params: {
              access_token: connection.accessToken,
            },
          }
        );
      } catch (pageError) {
        const pageErrDetail = pageError.response?.data || pageError.message;
        errors.push(`/${connection.pageId}/messages: ${JSON.stringify(pageErrDetail)}`);
        console.error(`❌ [Instagram Send Error] Both endpoints failed for recipient ${recipientId}:`, errors);
        throw pageError;
      }
    }

    // Save the outgoing message to Prisma
    const conversation = await prisma.conversation.findUnique({
      where: {
        businessId_platform_customerId: {
          businessId,
          platform: "instagram",
          customerId: recipientId,
        },
      },
    });

    if (conversation) {
      await prisma.message.create({
        data: {
          conversationId: conversation.id,
          senderType: senderType,
          senderId: connection.pageId, // Sent by instagram account
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
    console.error("Error sending message via Instagram API:", error.response?.data || error.message);
    const metaError = error.response?.data?.error?.message || error.message;
    throw new AppError(500, `Instagram API Error: ${metaError}`);
  }
};

export const sendMediaMessageToUser = async (businessId, recipientId, type, mediaUrl, filePath) => {
  const connection = await prisma.socialConnection.findFirst({
    where: { businessId, provider: "instagram", isActive: true },
  });

  if (!connection) {
    throw new AppError(404, "No active Instagram connection found for this business.");
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
          platform: "instagram",
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
    console.error("Error sending media via Instagram API:", error.response?.data || error.message);
    const metaError = error.response?.data?.error?.message || error.message;
    throw new AppError(500, `Instagram API Error: ${metaError}`);
  }
};

export const syncInstagramConversationsFromMeta = async (businessId, branchId = null) => {
  try {
    const connection = await prisma.socialConnection.findFirst({
      where: { businessId, provider: "instagram", isActive: true },
    });

    if (!connection || !connection.accessToken) return;

    const response = await axios.get(`${getGraphUrl()}/me/conversations`, {
      params: {
        access_token: connection.accessToken,
        platform: "instagram",
        fields: "id,updated_time,participants,messages{id,message,from,created_time}",
      },
    });

    const metaConversations = response.data?.data || [];
    const resolvedBranchId = branchId || connection.branchId || null;

    for (const metaConv of metaConversations) {
      const participants = metaConv.participants?.data || [];
      const customer = participants.find((p) => p.id !== connection.pageId) || participants[0];
      if (!customer) continue;

      const customerId = customer.id;
      const customerName = customer.username || customer.name || "Instagram User";

      let conversation = await prisma.conversation.findUnique({
        where: {
          businessId_platform_customerId: {
            businessId,
            platform: "instagram",
            customerId,
          },
        },
      });

      const messagesList = metaConv.messages?.data || [];
      const latestMsg = messagesList[0];

      if (!conversation) {
        conversation = await prisma.conversation.create({
          data: {
            businessId,
            branchId: resolvedBranchId,
            platform: "instagram",
            customerId,
            customerName,
            lastMessage: latestMsg?.message || "Message on Instagram",
            lastMessageAt: latestMsg ? new Date(latestMsg.created_time) : new Date(),
            seen: false,
          },
        });
      } else {
        if (!conversation.branchId && resolvedBranchId) {
          await prisma.conversation.update({
            where: { id: conversation.id },
            data: { branchId: resolvedBranchId },
          });
        }
      }

      for (const msg of [...messagesList].reverse()) {
        const platformMessageId = msg.id;
        const exists = await prisma.message.findFirst({
          where: {
            conversationId: conversation.id,
            platformMessageId,
          },
        });

        if (!exists) {
          const isCustomer = msg.from?.id === customerId;
          const senderType = isCustomer ? "customer" : "business";
          const messageText = msg.message || "";

          await prisma.message.create({
            data: {
              conversationId: conversation.id,
              senderType,
              senderId: msg.from?.id || customerId,
              messageText,
              platformMessageId,
              type: "text",
              createdAt: new Date(msg.created_time),
            },
          });

          await prisma.conversation.update({
            where: { id: conversation.id },
            data: {
              lastMessage: messageText,
              lastMessageAt: new Date(msg.created_time),
            },
          });

          // Trigger AI Agent reply if incoming customer message is recent
          const msgAgeMs = Date.now() - new Date(msg.created_time).getTime();
          if (isCustomer && msgAgeMs < 300000 && messageText) {
            notifyAiAgent({
              businessId,
              recipientId: customerId,
              conversationId: conversation.id,
              channel: "instagram",
              message: messageText,
            });
          }
        }
      }
    }
  } catch (error) {
    console.warn("[Instagram Sync] Notice syncing conversations from Meta Graph API:", error.response?.data?.error?.message || error.message);
  }
};

export const getConversations = async (businessId, branchId) => {
  // Sync live conversations directly from Meta Graph API
  await syncInstagramConversationsFromMeta(businessId, branchId);

  if (branchId) {
    await prisma.conversation.updateMany({
      where: { businessId, platform: "instagram", branchId: null },
      data: { branchId },
    }).catch(() => {});

    await prisma.socialConnection.updateMany({
      where: { businessId, provider: "instagram", branchId: null },
      data: { branchId },
    }).catch(() => {});
  }

  const whereClause = { businessId, platform: "instagram" };
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
  const conversation = await prisma.conversation.findUnique({
    where: { id: conversationId },
  });

  if (conversation) {
    await syncInstagramConversationsFromMeta(conversation.businessId, conversation.branchId);
  }

  const messages = await prisma.message.findMany({
    where: { conversationId },
    orderBy: { createdAt: 'asc' },
  });

  return messages.map((msg) => {
    if (msg.mediaUrl && !msg.mediaUrl.startsWith("http://") && !msg.mediaUrl.startsWith("https://")) {
      if (msg.mediaUrl.startsWith("uploads/")) {
        msg.mediaUrl = `${envVars.BACKEND_URL}/${msg.mediaUrl}`;
      } else {
        msg.mediaUrl = `${envVars.BACKEND_URL}/uploads/instagram/${msg.mediaUrl}`;
      }
    }
    return msg;
  });
};
