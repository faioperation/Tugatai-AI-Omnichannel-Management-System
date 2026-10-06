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
import { verifyWebhook as verifyIgWebhook, handleWebhookEvent as handleIgWebhookEvent, authFacebookCallback as igOAuthCallback } from "./app/modules/instagram/instagram.controller.js";
import { verifyWebhook as verifyFbWebhook, handleWebhookEvent as handleFbWebhookEvent, authFacebookCallback as fbOAuthCallback } from "./app/modules/messenger/messenger.controller.js";
import { WhatsappController } from "./app/modules/whatsapp/whatsapp.controller.js";

// Dedicated top-level Webhook endpoints (Accessible publicly without auth)
const igWebhookPaths = [
  "/webhook/instagram",
  "/instagram/webhook",
  "/api/webhook/instagram",
  "/api/instagram/webhook",
  "/api/v1/webhook/instagram",
  "/api/v1/instagram/webhook",
];

const fbWebhookPaths = [
  "/webhook/facebook",
  "/facebook/webhook",
  "/webhook/messenger",
  "/messenger/webhook",
  "/api/webhook/facebook",
  "/api/facebook/webhook",
  "/api/webhook/messenger",
  "/api/messenger/webhook",
  "/api/v1/webhook/facebook",
  "/api/v1/facebook/webhook",
  "/api/v1/webhook/messenger",
  "/api/v1/messenger/webhook",
];

const waWebhookPaths = [
  "/webhook/whatsapp",
  "/whatsapp/webhook",
  "/webhooks/whatsapp",
  "/api/webhook/whatsapp",
  "/api/whatsapp/webhook",
  "/api/v1/webhook/whatsapp",
  "/api/v1/whatsapp/webhook",
];

const evoWebhookPaths = [
  "/webhook/evolution",
  "/webhooks/evolution",
  "/whatsapp/webhook/evolution",
  "/api/webhook/evolution",
  "/api/v1/webhook/evolution",
];

igWebhookPaths.forEach((p) => {
  app.get(p, verifyIgWebhook);
  app.post(p, handleIgWebhookEvent);
});

fbWebhookPaths.forEach((p) => {
  app.get(p, verifyFbWebhook);
  app.post(p, handleFbWebhookEvent);
});

waWebhookPaths.forEach((p) => {
  app.get(p, WhatsappController.verifyWebhook);
  app.post(p, WhatsappController.receiveWebhook);
});

evoWebhookPaths.forEach((p) => {
  app.post(p, WhatsappController.receiveEvolutionWebhook);
});

// Top-level Public OAuth Callback paths
app.get(["/auth/instagram/callback", "/api/v1/auth/instagram/callback", "/api/auth/instagram/callback"], igOAuthCallback);
app.get(["/auth/facebook/callback", "/api/v1/auth/facebook/callback", "/api/auth/facebook/callback"], fbOAuthCallback);
app.get(["/auth/whatsapp/callback", "/api/v1/auth/whatsapp/callback", "/api/auth/whatsapp/callback"], WhatsappController.authWhatsAppCallback);

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


