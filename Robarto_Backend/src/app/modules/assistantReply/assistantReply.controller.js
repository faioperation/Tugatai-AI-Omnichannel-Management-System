import { AssistantReplyService } from "./assistantReply.service.js";
import { sendResponse } from "../../utils/sendResponse.js";

export const AssistantReplyController = {
  suggestReply: async (req, res, next) => {
    try {
      const result = await AssistantReplyService.suggestReply(req.body);
      
      sendResponse(res, {
        statusCode: 200,
        success: true,
        message: "Suggested reply generated successfully",
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
};
