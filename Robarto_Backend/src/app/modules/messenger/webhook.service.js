import prisma from "../../prisma/client.js";
import { handleIncomingMessage } from "./messenger.service.js";
import { handleIncomingMessage as handleInstagramIncoming } from "../instagram/instagram.service.js";

export const processWebhookEvent = async (body) => {
  if (body.object === "instagram") {
    for (const entry of body.entry || []) {
      const accountId = entry.id;
      if (!entry.messaging) continue;
      for (const webhookEvent of entry.messaging) {
        if (webhookEvent.message && !webhookEvent.message.is_echo) {
          await handleInstagramIncoming(accountId, webhookEvent);
        }
      }
    }
    return;
  }

  if (body.object === "page") {
    for (const entry of body.entry || []) {
      const pageId = entry.id;

      // Ensure this is a messaging event
      if (!entry.messaging) continue;
      
      for (const webhookEvent of entry.messaging) {
        // Handle message event, ignore echos (messages sent by the page itself)
        if (webhookEvent.message && !webhookEvent.message.is_echo) {
          // Check if this pageId or recipient is an Instagram connection
          const isIgConnection = await prisma.socialConnection.findFirst({
            where: {
              OR: [
                { pageId: pageId, provider: "instagram", isActive: true },
                { pageId: webhookEvent.recipient?.id, provider: "instagram", isActive: true },
              ],
            },
          });

          if (isIgConnection) {
            await handleInstagramIncoming(pageId, webhookEvent);
          } else {
            await handleIncomingMessage(pageId, webhookEvent);
          }
        }
      }
    }
  }
};

