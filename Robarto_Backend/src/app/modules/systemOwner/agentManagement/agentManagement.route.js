import express from "express";
import { AgentController } from "./agentManagement.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { AgentValidation } from "./agentManagement.validation.js";
import { checkAuthMiddleware } from "../../../middleware/checkAuthMiddleware.js";
import { Role } from "../../../utils/role.js";
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
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    uploadFields,
    validateRequest(AgentValidation.createAgentSchema),
    AgentController.createAgent
);

router.get(
    "/all",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    AgentController.getAllAgents
);

router.get(
    "/:id",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    AgentController.getAgentById
);

router.patch(
    "/:id",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    uploadFields,
    validateRequest(AgentValidation.updateAgentSchema),
    AgentController.updateAgent
);

router.put(
    "/:id/product-file",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    upload.fields([
        { name: "product_file", maxCount: 1 },
        { name: "productFile", maxCount: 1 }
    ]),
    AgentController.updateProductFile
);

router.delete(
    "/:id",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    AgentController.deleteAgent
);

export const AgentManagementRoutes = router;
