import express from "express";
import { BusinessController } from "./businessManagement.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { BusinessValidation } from "./businessManagement.validation.js";
import { checkAuthMiddleware, checkPermission } from "../../../middleware/checkAuthMiddleware.js";
import { Role } from "../../../utils/role.js";

const router = express.Router();

router.post(
    "/create",
    checkPermission("ONBOARD_BUSINESS"),
    validateRequest(BusinessValidation.createBusinessSchema),
    BusinessController.createBusiness
);

router.get(
    "/all",
    checkPermission("VIEW_BUSINESS"),
    BusinessController.getAllBusinesses
);

router.get(
    "/:id",
    checkPermission("VIEW_BUSINESS"),
    BusinessController.getBusinessById
);

router.patch(
    "/:id",
    checkPermission("UPDATE_BUSINESS"),
    validateRequest(BusinessValidation.updateBusinessSchema),
    BusinessController.updateBusiness
);

router.delete(
    "/:id",
    checkAuthMiddleware(Role.SYSTEM_OWNER),
    BusinessController.deleteBusiness
);

export const BusinessRoutes = router;

