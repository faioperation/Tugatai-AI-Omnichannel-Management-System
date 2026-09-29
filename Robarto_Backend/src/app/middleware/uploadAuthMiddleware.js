import jwt from "jsonwebtoken";
import { envVars } from "../config/env.js";
import { StatusCodes } from "http-status-codes";

/**
 * Middleware to secure static file endpoints (/uploads and /api/uploads).
 *
 * Supports multiple authorization sources:
 * 1. HTTP Cookie: `req.cookies.accessToken` (Used automatically by Web Dashboard)
 * 2. Authorization Header: `Bearer <jwt_token>`
 * 3. Custom Header: `x-api-token: <PUBLIC_API_TOKEN>` (Used by Python AI Chatbot / Voice AI)
 * 4. Query Parameter: `?token=<jwt_token_or_api_token>` or `?api_token=...` or `?apiKey=...` (Used for <img>, <a>, and Meta Webhook media fetches)
 */
export const uploadAuthMiddleware = (req, res, next) => {
  try {
    // 1. Extract token from header, cookies, or query parameters
    const cookieToken = req.cookies?.accessToken;
    const authHeader = req.headers.authorization;
    const bearerToken = authHeader?.startsWith("Bearer ")
      ? authHeader.slice(7).trim()
      : authHeader?.trim();
    const xApiToken = req.headers["x-api-token"];
    const queryToken =
      req.query?.token ||
      req.query?.api_token ||
      req.query?.apiKey ||
      req.query?.x_api_token;

    const token = bearerToken || cookieToken || queryToken || xApiToken;

    if (!token) {
      return res.status(StatusCodes.UNAUTHORIZED).json({
        success: false,
        message: "Unauthorized: An authentication token (Cookie, Bearer header, or ?token=) is required to access uploaded files.",
      });
    }

    // 2. Validate API Tokens (for internal AI services & Meta webhook downloads)
    const validApiTokens = [
      envVars.PUBLIC_API_TOKEN,
      envVars.AI_AGENT_API_TOKEN,
    ].filter(Boolean);

    if (
      validApiTokens.includes(token) ||
      (xApiToken && validApiTokens.includes(xApiToken))
    ) {
      return next();
    }

    // 3. Validate User JWT Access Token
    try {
      const decoded = jwt.verify(token, envVars.JWT_SECRET_TOKEN);
      req.user = decoded;
      return next();
    } catch (jwtError) {
      return res.status(StatusCodes.FORBIDDEN).json({
        success: false,
        message: "Forbidden: The provided authentication token is invalid or expired.",
      });
    }
  } catch (error) {
    console.error("Error in uploadAuthMiddleware:", error);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: "Internal server error during file authentication.",
    });
  }
};
