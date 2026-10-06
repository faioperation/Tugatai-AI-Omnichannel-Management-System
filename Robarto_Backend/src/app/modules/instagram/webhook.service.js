import { handleIncomingMessage } from "./instagram.service.js";

export const processWebhookEvent = async (body) => {
  if (body.object === "instagram" || body.object === "page") {
    for (const entry of body.entry || []) {
      const accountId = entry.id;

      // 1. Check messaging and standby events
      const messagingEvents = entry.messaging || entry.standby || [];
      for (const webhookEvent of messagingEvents) {
        if (webhookEvent.message && !webhookEvent.message.is_echo) {
          await handleIncomingMessage(accountId, webhookEvent);
        }
      }

      // 2. Check changes array (alternative Instagram webhook delivery)
      if (entry.changes && Array.isArray(entry.changes)) {
        for (const change of entry.changes) {
          if (change.field === "messages" && change.value) {
            const val = change.value;
            const webhookEvent = {
              sender: val.sender || { id: val.from?.id || val.sender_id },
              recipient: val.recipient || { id: val.to?.id || val.recipient_id || accountId },
              message: val.message || { mid: val.mid || val.id, text: val.text || val.message },
              timestamp: val.timestamp || Date.now(),
            };
            if (webhookEvent.sender?.id && webhookEvent.message && !webhookEvent.message.is_echo) {
              await handleIncomingMessage(accountId, webhookEvent);
            }
          }
        }
      }
    }
  }
};

