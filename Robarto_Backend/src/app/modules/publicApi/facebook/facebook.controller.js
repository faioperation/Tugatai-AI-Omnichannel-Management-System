import { AppError } from "../../../errorHelper/appError.js";
import { sendMessageToUser } from "../../messenger/messenger.service.js";

export const sendFacebookMessage = async (req, res, next) => {
  try {
    const { businessId, recipientId, message, continueAi } = req.body;

    if (!businessId || !recipientId || !message) {
      throw new AppError(400, "businessId, recipientId, and message are required.");
    }

    // Pass "agent" as the senderType and continueAi
    const result = await sendMessageToUser(businessId, recipientId, message, "agent", continueAi);

    res.status(200).json({
      success: true,
      message: "Message sent via AI Developer API",
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
