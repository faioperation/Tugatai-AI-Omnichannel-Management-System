import { Router } from "express";
import { WhatsappController } from "./whatsapp.controller.js";
import { checkAuthMiddleware } from "../../middleware/checkAuthMiddleware.js";
import validateRequest from "../../middleware/validateRequest.js";
import { WhatsappValidation } from "./whatsapp.validation.js";
import { whatsappUpload } from "./whatsappUpload.js";

export const WhatsappRoutes = Router();

// Public Webhooks (No auth needed, Meta and Evolution API will call these directly)
WhatsappRoutes.get("/webhooks/whatsapp", WhatsappController.verifyWebhook);
WhatsappRoutes.post("/webhooks/whatsapp", WhatsappController.receiveWebhook);
WhatsappRoutes.get("/webhook/whatsapp", WhatsappController.verifyWebhook);
WhatsappRoutes.post("/webhook/whatsapp", WhatsappController.receiveWebhook);
WhatsappRoutes.get("/whatsapp/webhook", WhatsappController.verifyWebhook);
WhatsappRoutes.post("/whatsapp/webhook", WhatsappController.receiveWebhook);
WhatsappRoutes.post("/webhook/evolution", WhatsappController.receiveEvolutionWebhook);
WhatsappRoutes.post("/webhooks/evolution", WhatsappController.receiveEvolutionWebhook);
WhatsappRoutes.post("/whatsapp/webhook/evolution", WhatsappController.receiveEvolutionWebhook);
WhatsappRoutes.get("/auth/whatsapp/callback", WhatsappController.authWhatsAppCallback);

// Protected API Routes
// Uses the existing checkAuthMiddleware
WhatsappRoutes.use("/whatsapp", checkAuthMiddleware());

WhatsappRoutes.post(
  "/whatsapp/connect",
  validateRequest(WhatsappValidation.connectAccount),
  WhatsappController.connectAccount
);

// QR Code Connection Endpoints
WhatsappRoutes.post("/whatsapp/qr/connect", WhatsappController.connectQrAccount);
WhatsappRoutes.get("/whatsapp/qr/status", WhatsappController.getQrCodeStatus);

WhatsappRoutes.get("/whatsapp/auth", WhatsappController.authWhatsApp);
WhatsappRoutes.get("/whatsapp/status", WhatsappController.checkConnectionStatus);

WhatsappRoutes.get("/whatsapp/media/:mediaId", WhatsappController.getMedia);

WhatsappRoutes.get("/whatsapp/conversations", WhatsappController.getConversations);
WhatsappRoutes.get("/whatsapp/conversations/:id/messages", WhatsappController.getMessages);

WhatsappRoutes.post(
  "/whatsapp/messages/send",
  validateRequest(WhatsappValidation.sendMessage),
  WhatsappController.sendTextMessage
);

WhatsappRoutes.post(
  "/whatsapp/messages/media",
  whatsappUpload.single("file"),
  validateRequest(WhatsappValidation.sendMediaMessage),
  WhatsappController.sendMediaMessage
);

WhatsappRoutes.post(
  "/whatsapp/disconnect",
  WhatsappController.disconnectAccount
);
