import { Router } from "express";
import { AssistantReplyController } from "./assistantReply.controller.js";
import { checkAuthMiddleware } from "../../middleware/checkAuthMiddleware.js";

export const AssistantReplyRoutes = Router();

AssistantReplyRoutes.post(
  "/suggest-reply",
  checkAuthMiddleware(),
  AssistantReplyController.suggestReply
);
