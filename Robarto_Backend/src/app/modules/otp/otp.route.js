import { Router } from "express";
import { OtpController } from "./otp.controller.js";
import validateRequest from "../../middleware/validateRequest.js";
import { OtpValidation } from "./otp.validation.js";
import { checkOtpSendLimit, checkOtpVerifyBlock } from "../../middleware/otpRateLimiter.js";

const router = Router();
router.post(
  "/send",
  checkOtpSendLimit,
  validateRequest(OtpValidation.sendOtpSchema),
  OtpController.sendOtp
);
router.post(
  "/verify",
  checkOtpVerifyBlock,
  validateRequest(OtpValidation.verifyOtpSchema),
  OtpController.verifyOtp
);

export const OtpRouter = router;