import express from "express";
import { TwiloNumberCallController } from "./twiloNumberCall.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { TwiloNumberCallValidation } from "./twiloNumberCall.validation.js";

import { checkPermission } from "../../../middleware/checkAuthMiddleware.js";

const router = express.Router();

router.post(
  "/setup-twilio",
  checkPermission("VOICE_AGENT_TWILIO_NUMBER_ADD"),
  validateRequest(TwiloNumberCallValidation.setupTwilioSchema),
  TwiloNumberCallController.setupTwilio
);

router.delete(
  "/teardown",
  validateRequest(TwiloNumberCallValidation.teardownTelephonySchema),
  TwiloNumberCallController.teardownTelephony
);

export const TelephonyRoutes = router;
