import { redisClient } from "../config/redis.config.js";
import DevBuildError from "../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";

export const MAX_LOGIN_ATTEMPTS = 5;
export const BLOCK_DURATION_SECONDS = 15 * 60; // 15 minutes (900 seconds)
export const ATTEMPT_WINDOW_SECONDS = 15 * 60; // 15 minutes window

/**
 * Extracts client IP address safely from request headers or socket
 */
export const getClientIp = (req) => {
  const forwarded = req.headers["x-forwarded-for"];
  if (forwarded) {
    return forwarded.split(",")[0].trim();
  }
  return req.ip || req.socket?.remoteAddress || "unknown_ip";
};

/**
 * Generates uniform Redis keys based on email and IP
 */
export const getRateLimitKeys = (email, ip) => {
  const normalizedEmail = (email || "anonymous").trim().toLowerCase();
  const normalizedIp = (ip || "unknown_ip").trim();
  return {
    attemptKey: `rate_limit:login:attempts:${normalizedEmail}:${normalizedIp}`,
    blockKey: `rate_limit:login:blocked:${normalizedEmail}:${normalizedIp}`,
  };
};

/**
 * Middleware: Checks if the IP + Email combination is currently blocked
 */
export const checkLoginBlock = async (req, res, next) => {
  try {
    if (!redisClient || !redisClient.isOpen) {
      return next();
    }

    const email = req.body?.email;
    const ip = getClientIp(req);

    if (!email) {
      return next();
    }

    const { blockKey, attemptKey } = getRateLimitKeys(email, ip);

    // 1. Check if explicitly marked as blocked
    const isBlocked = await redisClient.get(blockKey);
    if (isBlocked) {
      const ttl = await redisClient.ttl(blockKey);
      const remainingMinutes = Math.max(1, Math.ceil(ttl / 60));
      return next(
        new DevBuildError(
          `Too many failed login attempts. Your account and IP are temporarily blocked. Please try again after ${remainingMinutes} minute(s).`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    // 2. Check if attempts already reached limit
    const attempts = await redisClient.get(attemptKey);
    if (attempts && parseInt(attempts, 10) >= MAX_LOGIN_ATTEMPTS) {
      const ttl = await redisClient.ttl(attemptKey);
      const remainingMinutes = Math.max(1, Math.ceil(ttl > 0 ? ttl / 60 : BLOCK_DURATION_SECONDS / 60));
      // Ensure block key is also synced
      await redisClient.set(blockKey, "blocked", { EX: ttl > 0 ? ttl : BLOCK_DURATION_SECONDS });
      return next(
        new DevBuildError(
          `Too many failed login attempts. Your account and IP are temporarily blocked. Please try again after ${remainingMinutes} minute(s).`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    next();
  } catch (error) {
    console.error("Error in checkLoginBlock middleware:", error);
    // Do not block normal login if Redis check encounters an error
    next();
  }
};

/**
 * Records a failed login attempt in Redis and handles blocking when limit is reached
 */
export const recordFailedLogin = async (email, ip) => {
  try {
    if (!redisClient || !redisClient.isOpen) {
      return { isBlocked: false, remainingAttempts: MAX_LOGIN_ATTEMPTS - 1 };
    }

    const { attemptKey, blockKey } = getRateLimitKeys(email, ip);

    const attempts = await redisClient.incr(attemptKey);

    // If first failed attempt, set initial expiration window
    if (attempts === 1) {
      await redisClient.expire(attemptKey, ATTEMPT_WINDOW_SECONDS);
    }

    if (attempts >= MAX_LOGIN_ATTEMPTS) {
      // Set 15-minute block
      await redisClient.set(blockKey, "blocked", { EX: BLOCK_DURATION_SECONDS });
      await redisClient.expire(attemptKey, BLOCK_DURATION_SECONDS);

      return {
        isBlocked: true,
        remainingAttempts: 0,
        message: "Too many failed login attempts. Your account and IP have been blocked for 15 minutes.",
      };
    }

    const remainingAttempts = Math.max(0, MAX_LOGIN_ATTEMPTS - attempts);
    return {
      isBlocked: false,
      remainingAttempts,
      message: `${remainingAttempts} attempt(s) remaining before a 15-minute lockout.`,
    };
  } catch (error) {
    console.error("Error recording failed login attempt:", error);
    return { isBlocked: false, remainingAttempts: MAX_LOGIN_ATTEMPTS };
  }
};

/**
 * Clears failed login attempts and unblocks on successful authentication
 */
export const clearLoginRateLimit = async (email, ip) => {
  try {
    if (!redisClient || !redisClient.isOpen) {
      return;
    }

    const { attemptKey, blockKey } = getRateLimitKeys(email, ip);
    await redisClient.del([attemptKey, blockKey]);
  } catch (error) {
    console.error("Error clearing login rate limit:", error);
  }
};
