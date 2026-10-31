import axios from "axios";
import prisma from "../prisma/client.js";
import { envVars } from "../config/env.js";

// Debounce configuration: wait 4.5s after the last message before calling AI
const DEBOUNCE_DELAY_MS = 4500;

// In-memory conversation state for debouncing & queueing
// key: lockKey (conversationId or channel:recipientId)
// value: { timer, messages: string[], businessId, recipientId, conversationId, channel, resolvers: Function[], inFlight: boolean }
const conversationBuffers = new Map();

/**
 * Executes the actual AI call with all buffered messages combined
 */
const executeAiCall = async (lockKey) => {
  const buffer = conversationBuffers.get(lockKey);
  if (!buffer || buffer.messages.length === 0) {
    conversationBuffers.delete(lockKey);
    return;
  }

  buffer.inFlight = true;

  // Combine all buffered messages into a single message
  const combinedMessage = buffer.messages.join("\n").trim();
  buffer.messages = []; // Clear for any new messages arriving while in-flight

  const { businessId, recipientId, conversationId, channel, resolvers } = buffer;

  console.log(`[AI Agent Debounce] Processing combined message for ${lockKey} (${channel}):\n"${combinedMessage}"`);

  let aiResult = null;

  try {
    const apiBaseUrl = envVars.AI_API_TAREQ;
    if (!apiBaseUrl) {
      console.warn("AI_API_TAREQ is not defined in environment variables.");
      return;
    }

    // Fetch business to get type (subject)
    const business = await prisma.business.findUnique({
      where: { id: businessId }
    });

    // Fetch branchId depending on channel and check if AI reply is enabled
    let branchId = null;
    try {
      if (channel === "whatsapp") {
        const waConv = await prisma.whatsappConversation.findUnique({
          where: { id: conversationId },
          include: { whatsappAccount: true }
        });
        if (waConv) {
          if (!waConv.aiReply || waConv.continueAi === false) {
            console.log(`[AI Agent] AI reply is disabled or paused (aiReply: ${waConv.aiReply}, continueAi: ${waConv.continueAi}) for Whatsapp conversation ${conversationId}. Skipping AI notification.`);
            return;
          }
          if (waConv.whatsappAccount) {
            branchId = waConv.whatsappAccount.branchId || null;
          }
        }
      } else if (channel === "instagram" || channel === "messenger" || channel === "webhook") {
        const conv = await prisma.conversation.findUnique({
          where: { id: conversationId }
        });
        if (conv) {
          if (!conv.aiReply || conv.continueAi === false) {
            console.log(`[AI Agent] AI reply is disabled or paused (aiReply: ${conv.aiReply}, continueAi: ${conv.continueAi}) for ${channel} conversation ${conversationId}. Skipping AI notification.`);
            return;
          }
          branchId = conv.branchId;
        }
      }

      // If branchId is null, resolve from active connection or branch and persist
      if (!branchId) {
        if (channel === "messenger" || channel === "instagram") {
          const conn = await prisma.socialConnection.findFirst({
            where: { businessId, provider: channel === "messenger" ? "facebook" : "instagram", isActive: true },
            orderBy: { updatedAt: "desc" },
          });
          if (conn?.branchId) {
            branchId = conn.branchId;
          }
        } else if (channel === "whatsapp") {
          const acc = await prisma.whatsappAccount.findFirst({
            where: { businessId, status: "ACTIVE" },
            orderBy: { updatedAt: "desc" },
          });
          if (acc?.branchId) {
            branchId = acc.branchId;
          }
        }

        if (!branchId) {
          const br = await prisma.branch.findFirst({ where: { businessId } });
          if (br) branchId = br.id;
        }

        if (branchId) {
          if (channel === "whatsapp") {
            const waConv = await prisma.whatsappConversation.findUnique({ where: { id: conversationId } });
            if (waConv?.whatsappAccountId) {
              await prisma.whatsappAccount.update({
                where: { id: waConv.whatsappAccountId },
                data: { branchId },
              }).catch(() => {});
            }
          } else {
            await prisma.conversation.update({
              where: { id: conversationId },
              data: { branchId },
            }).catch(() => {});
          }
        }
      }
    } catch (e) {
      console.error("[AI Agent] Error resolving branchId or aiReply for conversation:", e);
    }

    const payload = {
      business_id: businessId,
      branchId: branchId || null,
      subject: business?.businessType || "ORDER_BOOKING",
      recipient_id: recipientId,
      conversation_id: conversationId,
      channel,
      source_type: channel ? channel.toUpperCase() : null,
      message: combinedMessage
    };

    console.log(`[AI Agent] Triggering notifyAiAgent for channel ${channel}...`);
    console.log("[AI Agent] Payload:", JSON.stringify(payload, null, 2));

    const response = await axios.post(`${apiBaseUrl}/agent/message`, payload, {
      headers: {
        "x-api-token": envVars.AI_AGENT_API_TOKEN,
        "Content-Type": "application/json"
      }
    });

    console.log("[AI Agent] Response from AI API:", response.data);
    aiResult = response.data;

    // If AI replied successfully, send it back to the customer
    const responseText = response.data?.response;
    if (responseText) {
      // Deduplication check: check if the response was already sent
      let alreadySent = false;
      try {
        const tenSecondsAgo = new Date(Date.now() - 10000);
        if (channel === "whatsapp") {
          const lastOutgoing = await prisma.whatsappMessage.findFirst({
            where: {
              conversationId,
              direction: "OUTGOING",
              createdAt: { gte: tenSecondsAgo }
            },
            orderBy: { createdAt: "desc" }
          });
          if (lastOutgoing && lastOutgoing.text?.trim() === responseText.trim()) {
            alreadySent = true;
          }
        } else if (channel === "instagram" || channel === "messenger" || channel === "webhook") {
          const lastOutgoing = await prisma.message.findFirst({
            where: {
              conversationId,
              senderType: { in: ["agent", "business"] },
              createdAt: { gte: tenSecondsAgo }
            },
            orderBy: { createdAt: "desc" }
          });
          if (lastOutgoing && lastOutgoing.messageText?.trim() === responseText.trim()) {
            alreadySent = true;
          }
        }
      } catch (dbError) {
        console.error("[AI Agent] Error in deduplication check:", dbError);
      }

      if (alreadySent) {
        console.log(`[AI Agent] Reply was already sent to user on ${channel} (deduplicated). Skipping.`);
      } else {
        console.log(`[AI Agent] Sending AI reply back to user on ${channel}: ${responseText}`);

        if (channel === "messenger") {
          const { sendMessageToUser } = await import("../modules/messenger/messenger.service.js");
          await sendMessageToUser(businessId, recipientId, responseText, "agent");
        } else if (channel === "instagram") {
          const { sendMessageToUser } = await import("../modules/instagram/instagram.service.js");
          await sendMessageToUser(businessId, recipientId, responseText, "agent");
        } else if (channel === "whatsapp") {
          const { WhatsappService } = await import("../modules/whatsapp/whatsapp.service.js");
          await WhatsappService.sendTextMessage(businessId, conversationId, responseText);
        } else if (channel === "webhook") {
          await prisma.message.create({
            data: {
              conversationId,
              senderType: "agent",
              senderId: "ai_agent",
              type: "text",
              messageText: responseText,
              aiReply: true,
              continueAi: true,
            },
          });
          await prisma.conversation.update({
            where: { id: conversationId },
            data: {
              lastMessage: responseText,
              lastMessageAt: new Date(),
            },
          });
        }
      }
    }
  } catch (error) {
    console.error(
      "[AI Agent] Error in notifyAiAgent:",
      error.response?.data ? JSON.stringify(error.response.data, null, 2) : error.message
    );
  } finally {
    // Resolve all promises waiting for this batch
    resolvers.forEach((resolve) => resolve(aiResult));
    buffer.resolvers = [];
    buffer.inFlight = false;

    // Check if new customer messages arrived while this request was in-flight
    if (buffer.messages.length > 0) {
      console.log(`[AI Agent Debounce] New messages arrived while in-flight for ${lockKey}. Scheduling next run in ${DEBOUNCE_DELAY_MS}ms...`);
      buffer.timer = setTimeout(() => executeAiCall(lockKey), DEBOUNCE_DELAY_MS);
    } else {
      conversationBuffers.delete(lockKey);
    }
  }
};

/**
 * Public notifyAiAgent entry point with smart debouncing.
 * Batches rapid consecutive messages from a customer within DEBOUNCE_DELAY_MS (4.5s)
 * into a single AI call, dramatically reducing LLM costs and improving response quality.
 */
export const notifyAiAgent = async ({
  businessId,
  recipientId,
  conversationId,
  channel,
  message
}) => {
  const lockKey = conversationId || `${channel}:${recipientId}`;
  const normalizedMessage = (message || "").trim();

  // For synchronous testing webhooks, execute without debounce delay
  const delay = channel === "webhook" ? 0 : DEBOUNCE_DELAY_MS;

  return new Promise((resolve) => {
    let buffer = conversationBuffers.get(lockKey);

    if (!buffer) {
      buffer = {
        timer: null,
        messages: [],
        businessId,
        recipientId,
        conversationId,
        channel,
        resolvers: [],
        inFlight: false,
      };
      conversationBuffers.set(lockKey, buffer);
    }

    // Always keep latest parameters
    buffer.businessId = businessId;
    buffer.recipientId = recipientId;
    buffer.channel = channel;
    buffer.resolvers.push(resolve);

    // Prevent immediate exact duplicate message within the buffer
    if (normalizedMessage) {
      const isDuplicate = buffer.messages.length > 0 && buffer.messages[buffer.messages.length - 1] === normalizedMessage;
      if (!isDuplicate) {
        buffer.messages.push(normalizedMessage);
      }
    }

    // If an AI call is already in-flight, keep message buffered. It will be scheduled once in-flight finishes.
    if (buffer.inFlight) {
      console.log(`[AI Agent Debounce] Request in-flight for ${lockKey}. Buffered message: "${normalizedMessage}"`);
      return;
    }

    // Reset the debounce timer on each new message received
    if (buffer.timer) {
      clearTimeout(buffer.timer);
    }

    console.log(`[AI Agent Debounce] Message received for ${lockKey}. Waiting ${delay}ms before calling AI (messages count: ${buffer.messages.length})...`);
    buffer.timer = setTimeout(() => executeAiCall(lockKey), delay);
  });
};

