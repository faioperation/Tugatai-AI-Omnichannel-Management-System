

import jwt from "jsonwebtoken";
import prisma from "../prisma/client.js";
import { envVars } from "../config/env.js";
import { NotificationService } from "../modules/notification/notification.service.js";

export const checkAuthMiddleware =
  (...allowedRoles) =>
    async (req, res, next) => {
      console.log("🔥 Auth middleware hit:", req.originalUrl);

      try {
        let token = req.headers.authorization || req.query.token;

        if (!token) {
          return res.status(401).json({
            success: false,
            message: "No token provided",
          });
        }

        const jwtToken = String(token).replace(/^Bearer\s*/i, "");
        const decoded = jwt.verify(jwtToken, envVars.JWT_SECRET_TOKEN);

        // Determine which table to search based on the role or route
        const user = await prisma.user.findUnique({
          where: { id: decoded.id },
          include: { roles: { include: { role: true } } }
        });


        if (!user) {
          return res.status(401).json({
            success: false,
            message: "User not found",
          });
        }

        const userRoleNames = user.roles?.map(r => r.role.name) || [];
        if (allowedRoles.length && !userRoleNames.some(r => allowedRoles.includes(r))) {
          return res.status(403).json({
            success: false,
            message: "Forbidden",
          });
        }

        const isResetRoute = req.originalUrl.includes("/reset-password");

        if (!user.isVerified && !isResetRoute) {
          return res.status(403).json({
            success: false,
            message: "User is not verified. Please verify your email.",
          });
        }

        // Check subscription status for Business Owners and Branch Managers
        const isBusinessOwner = userRoleNames.includes("BUSINESS_OWNER");
        const isBranchManager = userRoleNames.includes("BRANCH_MANAGER");

        if (isBusinessOwner || isBranchManager) {
          let business = null;
          if (isBusinessOwner) {
            business = await prisma.business.findFirst({
              where: { ownerId: user.id }
            });
          } else if (isBranchManager) {
            const managerRecord = await prisma.branchManager.findUnique({
              where: { email: user.email }
            });
            if (managerRecord) {
              business = await prisma.business.findUnique({
                where: { id: managerRecord.businessId }
              });
            }
          }

          if (business) {
            // Check if subscription has expired (current date > endDate of active subscription)
            const activeSubscription = await prisma.businessSubscription.findFirst({
              where: {
                businessId: business.id,
                status: "ACTIVE",
              }
            });

            if (activeSubscription && new Date() > new Date(activeSubscription.endDate)) {
              // Expire subscription in DB
              await prisma.businessSubscription.update({
                where: { id: activeSubscription.id },
                data: { status: "INACTIVE" }
              });

              // Set business status to INACTIVE in DB
              const updatedBusiness = await prisma.business.update({
                where: { id: business.id },
                data: { status: "INACTIVE" }
              });

              // Trigger notification to System Owners
              NotificationService.createAndSendNotification({
                title: "Subscription Ended",
                message: `Subscription for business "${business.name}" has ended.`,
                type: "SUBSCRIPTION_END",
                businessId: business.id,
              }).catch(err => console.error("Error sending subscription end notification:", err));

              // Update business reference in local memory
              business = updatedBusiness;
            }
          }

          // If the business is deleted or suspended, completely block access to all routes
          if (!business || business.deletedAt || business.status === "SUSPENDED") {
            return res.status(403).json({
              success: false,
              message: "Your business account is suspended or inactive. Please contact the administrator.",
            });
          }

          const isAllowedWithoutActiveSubscription =
            req.originalUrl.includes("/payment/create-checkout-session") ||
            req.originalUrl.includes("/payment/my-subscription") ||
            req.originalUrl.includes("/user/profile/me") ||
            req.originalUrl.includes("/auth/");

          if (!isAllowedWithoutActiveSubscription) {
            if (business.status !== "ACTIVE") {
              return res.status(403).json({
                success: false,
                message: "Subscription required. Please purchase a subscription to access this resource.",
              });
            }
          }

          // Attach business to req so controllers can use it directly
          req.business = business;
        }

        req.user = user;
        next();
      } catch (error) {
        return res.status(401).json({
          success: false,
          message: "Invalid or expired token",
        });
      }
    };

export const checkPermission = (...requiredPermissions) => async (req, res, next) => {
  // First run authentication check to ensure valid token & populate req.user
  return checkAuthMiddleware()(req, res, async () => {
    try {
      const user = req.user;
      if (!user) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const userRoleNames = user.roles?.map((r) => r.role.name) || [];

      // SYSTEM_OWNER automatically has full access
      if (userRoleNames.includes("SYSTEM_OWNER")) {
        return next();
      }

      // SYSTEM_STAFF requires dynamic permission check against UserPermission table
      if (userRoleNames.includes("SYSTEM_STAFF")) {
        const userPermissions = await prisma.userPermission.findMany({
          where: { userId: user.id },
          include: { permission: true },
        });

        const assignedPermNames = userPermissions.map((up) => up.permission.name);

        const hasPermission = requiredPermissions.some((perm) =>
          assignedPermNames.includes(perm)
        );

        if (!hasPermission) {
          return res.status(403).json({
            success: false,
            message: "You do not have permission for this action",
          });
        }

        return next();
      }

      // If user is neither SYSTEM_OWNER nor SYSTEM_STAFF
      return res.status(403).json({
        success: false,
        message: "You do not have permission for this action",
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: "Permission check failed",
      });
    }
  });
};

