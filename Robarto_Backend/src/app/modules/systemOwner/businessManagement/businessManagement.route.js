import express from "express";
import { BusinessController } from "./businessManagement.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { BusinessValidation } from "./businessManagement.validation.js";
import { checkAuthMiddleware, checkPermission } from "../../../middleware/checkAuthMiddleware.js";
import { Role } from "../../../utils/role.js";

const router = express.Router();

router.post(
    "/create",
    checkPermission("TENANT_CREATE"),
    validateRequest(BusinessValidation.createBusinessSchema),
    BusinessController.createBusiness
);

router.get(
    "/all",
    checkPermission("TENANT_MANAGEMENT", "TENANT_VIEW"),
    BusinessController.getAllBusinesses
);

router.get(
    "/:id",
    checkPermission("TENANT_VIEW"),
    BusinessController.getBusinessById
);

router.patch(
    "/:id",
    checkPermission("TENANT_UPDATE"),
    validateRequest(BusinessValidation.updateBusinessSchema),
    BusinessController.updateBusiness
);

router.delete(
    "/:id",
    checkPermission("TENANT_DELETE"),
    BusinessController.deleteBusiness
);

export const BusinessRoutes = router;

