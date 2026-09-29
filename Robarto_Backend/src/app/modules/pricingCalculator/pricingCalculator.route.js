import express from "express";
import { PricingCalculatorController } from "./pricingCalculator.controller.js";
import { checkAuthMiddleware } from "../../middleware/checkAuthMiddleware.js";
import { Role } from "../../utils/role.js";
import { envVars } from "../../config/env.js";

const router = express.Router();

/**
 * Dual Authentication Middleware:
 * Allows either authenticated dashboard users (via JWT Bearer / Cookie)
 * OR internal microservices / AI services (via x-api-token header)
 */
const calculatorAuth = (req, res, next) => {
  const xApiToken = req.headers["x-api-token"] || req.query?.api_token;
  if (xApiToken && envVars.PUBLIC_API_TOKEN && xApiToken === envVars.PUBLIC_API_TOKEN) {
    return next();
  }
  return checkAuthMiddleware(...Object.values(Role))(req, res, next);
};

router.get("/calculate", calculatorAuth, PricingCalculatorController.calculatePricing);

export const PricingCalculatorRoutes = router;
