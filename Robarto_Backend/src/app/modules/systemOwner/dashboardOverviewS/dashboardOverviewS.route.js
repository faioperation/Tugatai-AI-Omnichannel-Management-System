import express from "express";
import { DashboardOverviewSController } from "./dashboardOverviewS.controller.js";
import { checkPermission } from "../../../middleware/checkAuthMiddleware.js";

const router = express.Router();

router.get(
    "/overview",
    checkPermission("VIEW_BUSINESS", "SUPPORT_BUSINESS"),
    DashboardOverviewSController.getDashboardOverview
);

export const DashboardOverviewSRoutes = router;

