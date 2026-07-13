import express from "express";
import { getMessageHistory } from "./messageHistory.controller.js";
import { publicApiAuth } from "../../../middleware/publicApiAuth.js";

const router = express.Router();

router.get("/:conversationId", publicApiAuth, getMessageHistory);

export const PublicMessageHistoryRoutes = router;
