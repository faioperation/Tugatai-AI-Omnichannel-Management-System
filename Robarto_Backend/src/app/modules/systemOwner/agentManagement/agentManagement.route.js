import express from "express";
import { AgentController } from "./agentManagement.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { AgentValidation } from "./agentManagement.validation.js";
import { checkPermission } from "../../../middleware/checkAuthMiddleware.js";
import { createMulterUpload } from "../../../config/multer.config.js";

const router = express.Router();
const upload = createMulterUpload({ folder: "agents", allowedTypes: /.*/ });
const uploadFields = upload.fields([
    { name: "rules_file", maxCount: 10 },
    { name: "product_file", maxCount: 1 },
    { name: "productFile", maxCount: 1 }
]);

router.post(
    "/create",
    checkPermission("CONFIGURE_AGENT"),
    uploadFields,
    validateRequest(AgentValidation.createAgentSchema),
    AgentController.createAgent
);

router.get(
    "/all",
    checkPermission("CONFIGURE_AGENT"),
    AgentController.getAllAgents
);

router.get(
    "/:id",
    checkPermission("CONFIGURE_AGENT"),
    AgentController.getAgentById
);

router.patch(
    "/:id",
    checkPermission("CONFIGURE_AGENT"),
    uploadFields,
    validateRequest(AgentValidation.updateAgentSchema),
    AgentController.updateAgent
);

router.put(
    "/:id/product-file",
    checkPermission("CONFIGURE_AGENT"),
    upload.fields([
        { name: "product_file", maxCount: 1 },
        { name: "productFile", maxCount: 1 }
    ]),
    AgentController.updateProductFile
);

router.delete(
    "/:id",
    checkPermission("CONFIGURE_AGENT"),
    AgentController.deleteAgent
);

export const AgentManagementRoutes = router;

