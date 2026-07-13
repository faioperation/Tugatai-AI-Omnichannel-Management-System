import { AllConversationsService } from "./allConversations.service.js";
import { sendResponse } from "../../utils/sendResponse.js";
import { AppError } from "../../errorHelper/appError.js";
import { getBusinessAndBranchForUser } from "../../utils/workflowHelpers.js";

export const AllConversationsController = {
  getAllConversations: async (req, res, next) => {
    try {
      const { businessId, branchId: userBranchId, isOwner } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) {
        throw new AppError(404, "Business not found for this user");
      }

      // If owner: filter by query branchId (optional), else return all.
      // If branch manager: strictly filter by their branchId.
      const branchId = isOwner ? (req.query.branchId || null) : userBranchId;

      const conversations = await AllConversationsService.getAllConversations(businessId, branchId);

      sendResponse(res, {
        statusCode: 200,
        success: true,
        message: "All conversations retrieved successfully",
        data: conversations,
      });
    } catch (error) {
      next(error);
    }
  },

  updateSeenStatus: async (req, res, next) => {
    try {
      const { conversationId } = req.params;
      const seen = req.body.seen !== undefined ? req.body.seen : true;

      const updatedConversation = await AllConversationsService.updateSeenStatus(conversationId, seen);

      sendResponse(res, {
        statusCode: 200,
        success: true,
        message: "Conversation seen status updated successfully",
        data: updatedConversation,
      });
    } catch (error) {
      next(error);
    }
  },

  updateContinueAiStatus: async (req, res, next) => {
    try {
      const { conversationId } = req.params;
      const continueAi = req.body.continueAi !== undefined ? req.body.continueAi : true;

      const updatedConversation = await AllConversationsService.updateContinueAiStatus(conversationId, continueAi);

      sendResponse(res, {
        statusCode: 200,
        success: true,
        message: "Conversation continueAi status updated successfully",
        data: updatedConversation,
      });
    } catch (error) {
      next(error);
    }
  },
};