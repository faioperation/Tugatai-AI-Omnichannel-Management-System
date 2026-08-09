import express from "express";
import { MessageWebhookController } from "./messageWebhook.controller.js";
import { MessageWebhookValidation } from "./messageWebhook.validation.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { publicApiAuth } from "../../../middleware/publicApiAuth.js";
import { checkAuthMiddleware } from "../../../middleware/checkAuthMiddleware.js";
import { Role } from "../../../utils/role.js";
import { createMulterUpload } from "../../../config/multer.config.js";

const router = express.Router();

const upload = createMulterUpload({
  folder: "messageWebhook",
  allowedTypes: /jpeg|jpg|png|gif|webp|pdf|doc|docx|mp3|wav|ogg|mpeg|mp4|webm/,
  maxSize: 25 * 1024 * 1024,
});

const generateAuthMiddleware = (req, res, next) => {
  if (req.headers["x-api-token"]) {
    return publicApiAuth(req, res, next);
  }
  return checkAuthMiddleware(Role.BUSINESS_OWNER, Role.SYSTEM_OWNER, Role.BRANCH_MANAGER)(req, res, next);
};

// 1. Generate unique Webhook URL (1 URL per branch/business limit)
router.post(
  "/generate",
  generateAuthMiddleware,
  validateRequest(MessageWebhookValidation.generateWebhookUrlSchema),
  MessageWebhookController.generateWebhookUrlController
);

// 2. Get all generated Webhook URLs branch-wise for the Business Owner
router.get(
  "/all",
  generateAuthMiddleware,
  MessageWebhookController.getAllWebhookUrlsController
);

// 3. Send message via generated Webhook URL (supports text message + file upload with field name 'file')
// A. Using generated Token parameter: POST /v1/public/webhook/send-message/:token
router.post(
  "/send-message/:token",
  upload.single("file"),
  MessageWebhookController.sendWebhookMessageController
);

// B. Using Business ID and Branch ID parameters: POST /v1/public/webhook/send-message/:businessId/:branchId
router.post(
  "/send-message/:businessId/:branchId",
  upload.single("file"),
  MessageWebhookController.sendWebhookMessageController
);

// C. Direct endpoint with Body/Query params: POST /v1/public/webhook/send-message
router.post(
  "/send-message",
  upload.single("file"),
  MessageWebhookController.sendWebhookMessageController
);

export const PublicMessageWebhookRoutes = router;
