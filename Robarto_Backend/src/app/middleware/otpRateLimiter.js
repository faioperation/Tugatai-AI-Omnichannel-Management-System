import { redisClient } from "../config/redis.config.js";
import DevBuildError from "../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";
import { getClientIp } from "./loginRateLimiter.js";

export const OTP_SEND_COOLDOWN_SECONDS = 60; // 1 minute between OTP requests
export const OTP_MAX_HOURLY_SENDS = 5; // Max 5 sends per hour
export const OTP_HOURLY_WINDOW_SECONDS = 60 * 60; // 1 hour window

export const OTP_MAX_VERIFY_ATTEMPTS = 5; // Max 5 failed attempts
export const OTP_VERIFY_LOCKOUT_SECONDS = 15 * 60; // 15 minutes lockout

/**
 * Generates uniform Redis keys for OTP rate limiting
 */
const getOtpKeys = (email, ip) => {
  const normalizedEmail = (email || "anonymous").trim().toLowerCase();
  const normalizedIp = (ip || "unknown_ip").trim();
  return {
    sendCooldownKey: `rate_limit:otp_send:cooldown:${normalizedEmail}:${normalizedIp}`,
    sendHourlyKey: `rate_limit:otp_send:hourly:${normalizedEmail}:${normalizedIp}`,
    verifyAttemptsKey: `rate_limit:otp_verify:attempts:${normalizedEmail}:${normalizedIp}`,
    verifyBlockKey: `rate_limit:otp_verify:blocked:${normalizedEmail}:${normalizedIp}`,
  };
};

/**
 * Middleware: Rate limit sending OTPs (Cooldown: 60s, Hourly Limit: 5 per hour)
 */
export const checkOtpSendLimit = async (req, res, next) => {
  try {
    if (!redisClient || !redisClient.isOpen) {
      return next();
    }

    const email = req.body?.email;
    const ip = getClientIp(req);

    if (!email) {
      return next();
    }

    const { sendCooldownKey, sendHourlyKey } = getOtpKeys(email, ip);

    // 1. Check 60-second cooldown
    const isCooldownActive = await redisClient.get(sendCooldownKey);
    if (isCooldownActive) {
      const ttl = await redisClient.ttl(sendCooldownKey);
      const remainingSeconds = Math.max(1, ttl);
      return next(
        new DevBuildError(
          `Please wait ${remainingSeconds} second(s) before requesting another OTP.`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    // 2. Check hourly max limit
    const hourlySends = await redisClient.get(sendHourlyKey);
    if (hourlySends && parseInt(hourlySends, 10) >= OTP_MAX_HOURLY_SENDS) {
      const ttl = await redisClient.ttl(sendHourlyKey);
      const remainingMinutes = Math.max(1, Math.ceil(ttl / 60));
      return next(
        new DevBuildError(
          `You have reached the maximum OTP request limit (${OTP_MAX_HOURLY_SENDS} per hour). Please try again after ${remainingMinutes} minute(s).`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    next();
  } catch (error) {
    console.error("Error in checkOtpSendLimit middleware:", error);
    next();
  }
};

/**
 * Records successful OTP dispatch in Redis (sets 60s cooldown and increments hourly count)
 */
export const recordOtpSend = async (email, ip) => {
  try {
    if (!redisClient || !redisClient.isOpen || !email) {
      return;
    }

    const { sendCooldownKey, sendHourlyKey } = getOtpKeys(email, ip);

    // Set 60-second cooldown
    await redisClient.set(sendCooldownKey, "active", { EX: OTP_SEND_COOLDOWN_SECONDS });

    // Increment hourly count
    const hourlyCount = await redisClient.incr(sendHourlyKey);
    if (hourlyCount === 1) {
      await redisClient.expire(sendHourlyKey, OTP_HOURLY_WINDOW_SECONDS);
    }
  } catch (error) {
    console.error("Error recording OTP send in Redis:", error);
  }
};

/**
 * Middleware: Checks if OTP verification is currently blocked for this IP + Email
 */
export const checkOtpVerifyBlock = async (req, res, next) => {
  try {
    if (!redisClient || !redisClient.isOpen) {
      return next();
    }

    const email = req.body?.email;
    const ip = getClientIp(req);

    if (!email) {
      return next();
    }

    const { verifyBlockKey, verifyAttemptsKey } = getOtpKeys(email, ip);

    // 1. Check if explicitly marked as blocked
    const isBlocked = await redisClient.get(verifyBlockKey);
    if (isBlocked) {
      const ttl = await redisClient.ttl(verifyBlockKey);
      const remainingMinutes = Math.max(1, Math.ceil(ttl / 60));
      return next(
        new DevBuildError(
          `Too many failed OTP verification attempts. Your account and IP are temporarily locked from verifying OTP. Please try again after ${remainingMinutes} minute(s).`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    // 2. Check if attempts already reached limit
    const attempts = await redisClient.get(verifyAttemptsKey);
    if (attempts && parseInt(attempts, 10) >= OTP_MAX_VERIFY_ATTEMPTS) {
      const ttl = await redisClient.ttl(verifyAttemptsKey);
      const remainingMinutes = Math.max(1, Math.ceil(ttl > 0 ? ttl / 60 : OTP_VERIFY_LOCKOUT_SECONDS / 60));
      await redisClient.set(verifyBlockKey, "blocked", { EX: ttl > 0 ? ttl : OTP_VERIFY_LOCKOUT_SECONDS });
      return next(
        new DevBuildError(
          `Too many failed OTP verification attempts. Your account and IP are temporarily locked from verifying OTP. Please try again after ${remainingMinutes} minute(s).`,
          StatusCodes.TOO_MANY_REQUESTS
        )
      );
    }

    next();
  } catch (error) {
    console.error("Error in checkOtpVerifyBlock middleware:", error);
    next();
  }
};

/**
 * Records a failed OTP verification attempt in Redis
 */
export const recordFailedOtpVerify = async (email, ip, otpType = "otp") => {
  try {
    if (!redisClient || !redisClient.isOpen || !email) {
      return { isBlocked: false, remainingAttempts: OTP_MAX_VERIFY_ATTEMPTS - 1 };
    }

    const { verifyAttemptsKey, verifyBlockKey } = getOtpKeys(email, ip);
    const attempts = await redisClient.incr(verifyAttemptsKey);

    if (attempts === 1) {
      await redisClient.expire(verifyAttemptsKey, OTP_VERIFY_LOCKOUT_SECONDS);
    }

    if (attempts >= OTP_MAX_VERIFY_ATTEMPTS) {
      // Set 15-minute block
      await redisClient.set(verifyBlockKey, "blocked", { EX: OTP_VERIFY_LOCKOUT_SECONDS });
      await redisClient.expire(verifyAttemptsKey, OTP_VERIFY_LOCKOUT_SECONDS);

      // Invalidate the active OTP key so brute force is completely stopped
      const otpKey = otpType === "forgot-password" ? `forgot-password:${email}` : `otp:${email}`;
      await redisClient.del(otpKey);

      return {
        isBlocked: true,
        remainingAttempts: 0,
        message: "Too many failed OTP verification attempts. This OTP is now invalidated and your account is locked for 15 minutes.",
      };
    }

    const remainingAttempts = Math.max(0, OTP_MAX_VERIFY_ATTEMPTS - attempts);
    return {
      isBlocked: false,
      remainingAttempts,
      message: `Invalid OTP. ${remainingAttempts} attempt(s) remaining before a 15-minute lock.`,
    };
  } catch (error) {
    console.error("Error recording failed OTP verification:", error);
    return { isBlocked: false, remainingAttempts: OTP_MAX_VERIFY_ATTEMPTS };
  }
};

/**
 * Clears OTP verification attempt counts and blocks upon successful OTP verification
 */
export const clearOtpVerifyLimit = async (email, ip) => {
  try {
    if (!redisClient || !redisClient.isOpen || !email) {
      return;
    }

    const { verifyAttemptsKey, verifyBlockKey } = getOtpKeys(email, ip);
    await redisClient.del([verifyAttemptsKey, verifyBlockKey]);
  } catch (error) {
    console.error("Error clearing OTP verification rate limit:", error);
  }
};
