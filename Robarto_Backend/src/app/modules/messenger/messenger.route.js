import { Router } from "express";
import {
  authFacebook,
  authFacebookCallback,
  verifyWebhook,
  handleWebhookEvent,
  sendMessengerMessage,
  getConversations,
  getMessages,
  checkConnectionStatus,
  sendMediaMessage,
} from "./messenger.controller.js";
import { checkAuthMiddleware } from "../../middleware/checkAuthMiddleware.js";
import { messengerUpload } from "./messengerUpload.js";

export const MessengerRoutes = Router();

// --- Public Routes (No Auth Needed) ---
// Facebook redirects here directly from browser, so we handle it without JWT auth
MessengerRoutes.get("/auth/facebook/callback", authFacebookCallback);

// Webhook Routes (Meta calls these directly)
// Note: Kept as /webhook/facebook in case existing Meta apps are using it
MessengerRoutes.get("/webhook/facebook", verifyWebhook);
MessengerRoutes.post("/webhook/facebook", handleWebhookEvent);


// --- Protected API Routes ---
const ProtectedMessengerRoutes = Router();
ProtectedMessengerRoutes.use(checkAuthMiddleware());

// OAuth Initialization
ProtectedMessengerRoutes.get("/messenger/auth/facebook", authFacebook);

// Status
ProtectedMessengerRoutes.get("/messenger/status", checkConnectionStatus);

// Send Message
ProtectedMessengerRoutes.post("/messenger/messages/send", sendMessengerMessage);
ProtectedMessengerRoutes.post(
  "/messenger/messages/media",
  messengerUpload.single("file"),
  sendMediaMessage
);

// Get Data
ProtectedMessengerRoutes.get("/messenger/conversations", getConversations);
ProtectedMessengerRoutes.get("/messenger/messages/:conversationId", getMessages);

MessengerRoutes.use(ProtectedMessengerRoutes);
