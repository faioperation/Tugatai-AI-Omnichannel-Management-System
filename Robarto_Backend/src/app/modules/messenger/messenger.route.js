import { Router } from "express";
import {
  authFacebook,
  authFacebookCallback,
  verifyWebhook,
  handleWebhookEvent,
  sendMessengerMessage,
  getConversations,
  getMessages,
} from "./messenger.controller.js";

export const MessengerRoutes = Router();

// OAuth Routes
MessengerRoutes.get("/auth/facebook", authFacebook);
MessengerRoutes.get("/auth/facebook/callback", authFacebookCallback);

// Webhook Routes
MessengerRoutes.get("/webhook/facebook", verifyWebhook);
MessengerRoutes.post("/webhook/facebook", handleWebhookEvent);

// Send Message Route
MessengerRoutes.post("/messages/send", sendMessengerMessage);

// Get Data Routes
MessengerRoutes.get("/conversations/:businessId", getConversations);
MessengerRoutes.get("/messages/:conversationId", getMessages);
