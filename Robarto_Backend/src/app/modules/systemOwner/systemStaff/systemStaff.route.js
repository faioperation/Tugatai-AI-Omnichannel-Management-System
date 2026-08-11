import express from "express";
import { SystemStaffController } from "./systemStaff.controller.js";
import validateRequest from "../../../middleware/validateRequest.js";
import { SystemStaffValidation } from "./systemStaff.validation.js";
import { checkAuthMiddleware, checkPermission } from "../../../middleware/checkAuthMiddleware.js";
import { Role } from "../../../utils/role.js";

const router = express.Router();

// Get logged-in System Staff user's permissions
router.get(
  "/my-permissions",
  checkAuthMiddleware(...Object.values(Role)),
  SystemStaffController.getMyPermissions
);

// Get all assignable permissions (SYSTEM_OWNER or staff with MANAGE_STAFF_USERS)
router.get(
  "/permissions/all",
  checkPermission("MANAGE_STAFF_USERS"),
  SystemStaffController.getAllAssignablePermissions
);

// Create new System Staff user (SYSTEM_OWNER ONLY to prevent escalation)
router.post(
  "/create",
  checkAuthMiddleware(Role.SYSTEM_OWNER),
  validateRequest(SystemStaffValidation.createStaffSchema),
  SystemStaffController.createStaff
);

// Get all System Staff users
router.get(
  "/all",
  checkPermission("MANAGE_STAFF_USERS"),
  SystemStaffController.getAllStaff
);

// Get specific System Staff user by ID
router.get(
  "/:id",
  checkPermission("MANAGE_STAFF_USERS"),
  SystemStaffController.getStaffById
);

// Update System Staff details
router.patch(
  "/:id",
  checkPermission("MANAGE_STAFF_USERS"),
  validateRequest(SystemStaffValidation.updateStaffSchema),
  SystemStaffController.updateStaff
);

// Update System Staff permissions (SYSTEM_OWNER ONLY - Strictly prevents staff escalation)
router.patch(
  "/:id/permissions",
  checkAuthMiddleware(Role.SYSTEM_OWNER),
  validateRequest(SystemStaffValidation.updatePermissionsSchema),
  SystemStaffController.updateStaffPermissions
);

export const SystemStaffRoutes = router;
