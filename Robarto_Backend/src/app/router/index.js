import { Router } from "express";
import { AuthRouter } from "../modules/auth/auth.route.js";
import { OtpRouter } from "../modules/otp/otp.route.js";
import { UserRoutes } from "../modules/user/user.route.js";
import { BusinessRoutes } from "../modules/systemOwner/businessManagement/businessManagement.route.js";
import { SubscriptionPlanRoutes } from "../modules/systemOwner/subscriptionPlan/subscriptionPlan.route.js";
import { ActivityLogRoutes } from "../modules/systemOwner/activityLog/activityLog.route.js";

export const router = Router();
const moduleRoutes = [
  {
    path: "/user",
    route: UserRoutes,
  },
  {
    path: "/auth",
    route: AuthRouter,
  },
  {
    path: "/otp",
    route: OtpRouter,
  },
  {
    path: "/system-owner/businesses",
    route: BusinessRoutes,
  },
  {
    path: "/system-owner/subscription-plans",
    route: SubscriptionPlanRoutes,
  },
  {
    path: "/system-owner/activity-logs",
    route: ActivityLogRoutes,
  }
];

moduleRoutes.forEach((route) => {
  router.use(route.path, route.route);
});