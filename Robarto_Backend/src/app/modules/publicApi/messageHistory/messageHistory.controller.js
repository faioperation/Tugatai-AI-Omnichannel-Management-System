import { MessageHistoryService } from "./messageHistory.service.js";
import { sendResponse } from "../../../utils/sendResponse.js";
import { AppError } from "../../../errorHelper/appError.js";
import { StatusCodes } from "http-status-codes";

export const getMessageHistory = async (req, res, next) => {
  try {
    const { conversationId } = req.params;

    if (!conversationId) {
      throw new AppError(StatusCodes.BAD_REQUEST, "conversationId parameter is required.");
    }

    const result = await MessageHistoryService.getMessageHistory(conversationId);

    if (!result) {
      throw new AppError(StatusCodes.NOT_FOUND, "Conversation not found.");
    }

    sendResponse(res, {
      success: true,
      statusCode: StatusCodes.OK,
      message: "Message history retrieved successfully.",
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
