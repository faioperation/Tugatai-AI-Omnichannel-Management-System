import express from "express";
import { AgentTrainingController } from "./agentTraining.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { AgentTrainingValidation } from "./agentTraining.validation.js";
import { checkPermission } from "../../../middleware/checkAuthMiddleware.js";
import { createMulterUpload } from "../../../config/multer.config.js";

const router = express.Router();
const upload = createMulterUpload({ folder: "agentTraining", allowedTypes: /.*/ });

router.post(
    "/create",
    checkPermission("CHATBOT_AGENT_KNOWLEDGE_BASE_UPLOAD"),
    upload.fields([
        { name: 'productInformation', maxCount: 10 },
        { name: 'policiesGuidelines', maxCount: 10 },
        { name: 'faq', maxCount: 10 }
    ]),
    validateRequest(AgentTrainingValidation.createAgentTrainingSchema),
    AgentTrainingController.createAgentTraining
);

router.get(
    "/all",
    checkPermission("CHATBOT_AGENT_VIEW"),
    AgentTrainingController.getAllAgentTrainings
);

router.get(
    "/:id",
    checkPermission("CHATBOT_AGENT_VIEW"),
    AgentTrainingController.getAgentTrainingById
);

router.patch(
    "/:id",
    checkPermission("CHATBOT_AGENT_KNOWLEDGE_UPDATE", "CHATBOT_AGENT_KNOWLEDGE_BASE_UPLOAD"),
    upload.fields([
        { name: 'productInformation', maxCount: 10 },
        { name: 'policiesGuidelines', maxCount: 10 },
        { name: 'faq', maxCount: 10 }
    ]),
    validateRequest(AgentTrainingValidation.updateAgentTrainingSchema),
    AgentTrainingController.updateAgentTraining
);

router.delete(
    "/:id",
    checkPermission("CHATBOT_AGENT_KNOWLEDGE_UPDATE"),
    AgentTrainingController.deleteAgentTraining
);

export const AgentTrainingRoutes = router;

