import { Router } from "express";
import { AllConversationsController } from "./allConversations.controller.js";
import { checkAuthMiddleware } from "../../middleware/checkAuthMiddleware.js";

export const AllConversationsRoutes = Router();

// Protected endpoint to fetch unified conversations
AllConversationsRoutes.get(
  "/all-conversations",
  checkAuthMiddleware(),
  AllConversationsController.getAllConversations
);

// Protected endpoint to update seen status for any conversation type
AllConversationsRoutes.patch(
  "/:conversationId/seen",
  checkAuthMiddleware(),
  AllConversationsController.updateSeenStatus
);
