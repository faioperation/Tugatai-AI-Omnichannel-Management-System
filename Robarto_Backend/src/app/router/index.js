import { Router } from "express";
import { AuthRouter } from "../modules/auth/auth.route.js";
import { OtpRouter } from "../modules/otp/otp.route.js";
import { UserRoutes } from "../modules/user/user.route.js";
import { BusinessRoutes } from "../modules/systemOwner/businessManagement/businessManagement.route.js";
import { SubscriptionPlanRoutes } from "../modules/systemOwner/subscriptionPlan/subscriptionPlan.route.js";
import { ActivityLogRoutes } from "../modules/systemOwner/activityLog/activityLog.route.js";
import { BranchManagerRoutes } from "../modules/businessOwner/branchManager/branchManager.route.js";
import { BranchRoutes } from "../modules/businessOwner/branch/branch.route.js";
import { OrderBookingRoutes } from "../modules/businessOwner/orderBooking/orderBooking.route.js";
import { PricingRoutes } from "../modules/businessOwner/pricing/pricing.route.js";

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
  },
  {
    path: "/business-owner/branch-managers",
    route: BranchManagerRoutes,
  },
  {
    path: "/business-owner/branches",
    route: BranchRoutes,
  },
  {
    path: "/business-owner/order-bookings",
    route: OrderBookingRoutes,
  },
  {
    path: "/business-owner/pricings",
    route: PricingRoutes,
  }
];

moduleRoutes.forEach((route) => {
  router.use(route.path, route.route);
});