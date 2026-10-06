import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import path from "path";
import { fileURLToPath } from "url";

import { notFound } from "./app/middleware/notFound.js";
import { globalErrorHandler } from "./app/middleware/globalErrorHandeler.js";
import { router } from "./app/router/index.js";
import passport from "passport";
import "./app/config/passport.config.js";



dotenv.config();

const app = express();
app.set("trust proxy", 1);

// Global middlewares
const allowedOrigins = [
  "http://localhost:3000",
  "http://localhost:5173",
  "http://localhost:5174",
  "https://matrix-ai-app.vercel.app",
  "https://matrix-ai-landing-page.vercel.app",
  "https://test8.fireai.agency",
  "https://omnirraai.com",
  "https://dashboard.omnirraai.com",
  "https://chatbot.omnirraai.com",
  "https://voice-agent.omnirraai.com"
];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps, postman, curl)
    if (!origin) return callback(null, true);

    const isAllowed = allowedOrigins.includes(origin) ||
      /^http:\/\/localhost:\d+$/.test(origin);

    if (isAllowed) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true
}));
app.use(cookieParser());
app.use(express.json({
  verify: (req, res, buf) => {
    req.rawBody = buf.toString("utf8");
  }
}));
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());


import { uploadAuthMiddleware } from "./app/middleware/uploadAuthMiddleware.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadsPath = path.join(__dirname, "..", "uploads");

// Debug logger for all incoming requests
app.use((req, res, next) => {
  if (req.originalUrl.includes("webhook") || req.originalUrl.includes("callback") || req.originalUrl.includes("messenger") || req.originalUrl.includes("instagram")) {
    console.log(`📡 [Incoming Webhook Request] ${req.method} ${req.originalUrl}`);
    if (req.method === "POST" && req.body) {
      // Don't dump huge binary sync payloads
      if (req.body.event?.includes("messages.edited") || req.body.event?.includes("chats.set") || req.body.event?.includes("contacts.")) {
        console.log(`📦 [Evolution Event] ${req.body.event} for instance ${req.body.instance || "default"}`);
      } else {
        const preview = JSON.stringify(req.body);
        console.log("📦 Payload:", preview.length > 500 ? `${preview.substring(0, 500)}... (truncated)` : preview);
      }
    }
  }
  next();
});

import { MessengerRoutes } from "./app/modules/messenger/messenger.route.js";
import { InstagramRoutes } from "./app/modules/instagram/instagram.route.js";
import { WhatsappRoutes } from "./app/modules/whatsapp/whatsapp.routes.js";

// Root-level Webhook fallbacks in case Meta is configured without /api or /v1 prefix
app.use("/webhook", MessengerRoutes);
app.use("/webhook", InstagramRoutes);
app.use("/webhook", WhatsappRoutes);
app.use("/api/v1", MessengerRoutes);
app.use("/api/v1", InstagramRoutes);
app.use("/api/v1", WhatsappRoutes);

// Routes
app.use("/api", router);
app.use("/uploads", uploadAuthMiddleware, express.static(uploadsPath));
app.use("/api/uploads", uploadAuthMiddleware, express.static(uploadsPath));

// Health check (Liveness / Readiness)
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    services: {
      backend: "UP",
      database: "CONNECTED"
    }
  });
});

app.get("/", (req, res) => {
  res.send("Robarto Backend is running > >> ✅🚀");
});

// 404 handler (must be after routes)
app.use(notFound);

// Global error handler (always last)
app.use(globalErrorHandler);

export default app;


