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
    checkPermission("TRAIN_AI", "UPLOAD_KNOWLEDGE"),
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
    checkPermission("TRAIN_AI"),
    AgentTrainingController.getAllAgentTrainings
);

router.get(
    "/:id",
    checkPermission("TRAIN_AI"),
    AgentTrainingController.getAgentTrainingById
);

router.patch(
    "/:id",
    checkPermission("TRAIN_AI", "UPLOAD_KNOWLEDGE"),
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
    checkPermission("TRAIN_AI"),
    AgentTrainingController.deleteAgentTraining
);

export const AgentTrainingRoutes = router;

