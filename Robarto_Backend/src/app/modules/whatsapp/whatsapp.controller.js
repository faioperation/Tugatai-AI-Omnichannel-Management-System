import { envVars } from "../../config/env.js";
import { WhatsappService } from "./whatsapp.service.js";
import { handleWebhookEvent, handleEvolutionWebhookEvent } from "./whatsapp.webhook.js";
import prisma from "../../prisma/client.js";
import { getBusinessAndBranchForUser } from "../../utils/workflowHelpers.js";

export const WhatsappController = {
  verifyWebhook: (req, res) => {
    const mode = req.query["hub.mode"];
    const token = req.query["hub.verify_token"];
    const challenge = req.query["hub.challenge"];

    if (mode === "subscribe" && token === envVars.WHATSAPP_VERIFY_TOKEN) {
      res.status(200).send(challenge);
    } else {
      res.sendStatus(403);
    }
  },

  receiveWebhook: async (req, res) => {
    const body = req.body;
    try {
      await handleWebhookEvent(body);
      res.status(200).send("EVENT_RECEIVED");
    } catch (error) {
      console.error("Webhook processing error:", error);
      res.status(200).send("EVENT_RECEIVED"); // Always return 200 to Meta
    }
  },

  receiveEvolutionWebhook: async (req, res) => {
    try {
      await handleEvolutionWebhookEvent(req.body);
      res.status(200).send("OK");
    } catch (error) {
      console.error("[Evolution Webhook] Error:", error);
      res.status(200).send("OK");
    }
  },

  connectAccount: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const account = await WhatsappService.connectAccount(businessId, req.body);
      res.json({ success: true, data: account });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  connectQrAccount: async (req, res) => {
    try {
      const { businessId, branchId: userBranchId, isOwner } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });

      const branchId = isOwner ? (req.body.branchId || null) : userBranchId;
      const data = await WhatsappService.connectQrAccount(businessId, branchId);
      res.json({ success: true, data });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  getQrCodeStatus: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });

      const { instanceName } = req.query;
      if (!instanceName) return res.status(400).json({ success: false, message: "instanceName query parameter is required" });

      const data = await WhatsappService.getQrCodeStatus(businessId, instanceName);
      res.json({ success: true, data });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  checkConnectionStatus: async (req, res) => {
    try {
      const { businessId, branchId: userBranchId, isOwner } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const branchId = isOwner ? (req.query.branchId || null) : userBranchId;

      const whereClause = { businessId, status: "ACTIVE" };
      if (branchId) {
        whereClause.branchId = branchId;
      }

      const account = await prisma.whatsappAccount.findFirst({
        where: whereClause,
      });

      if (account) {
        const { accessToken, ...safeAccount } = account;
        res.json({ success: true, connected: true, data: safeAccount });
      } else {
        res.json({ success: true, connected: false });
      }
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  getConversations: async (req, res) => {
    try {
      const { businessId, branchId: userBranchId, isOwner } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const branchId = isOwner ? (req.query.branchId || null) : userBranchId;
      const data = await WhatsappService.getConversations(businessId, branchId);
      res.json({ success: true, data });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  getMessages: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const { id: conversationId } = req.params;
      const data = await WhatsappService.getMessages(businessId, conversationId);
      res.json({ success: true, data });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  sendTextMessage: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const { conversationId, message, continueAi } = req.body;
      const data = await WhatsappService.sendTextMessage(businessId, conversationId, message, continueAi);
      res.json({ success: true, data });
    } catch (error) {
      const errorMsg = error.response?.data?.error?.message || error.message;
      res.status(error.response?.status || 500).json({ 
        success: false, 
        message: errorMsg,
        details: error.response?.data || null
      });
    }
  },

  sendMediaMessage: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });
      
      const { conversationId, type } = req.body;
      
      let finalUrl = req.body.url;

      if (req.file) {
        // Construct the URL using BACKEND_URL, appending token for external Meta download access
        const tokenQuery = envVars.PUBLIC_API_TOKEN ? `?token=${envVars.PUBLIC_API_TOKEN}` : "";
        finalUrl = `${envVars.BACKEND_URL}/uploads/whatsapp/${req.file.filename}${tokenQuery}`;
      }

      if (!finalUrl) {
        return res.status(400).json({ success: false, message: "Either a 'file' (multipart/form-data) or a valid 'url' must be provided." });
      }

      const data = await WhatsappService.sendMediaMessage(businessId, conversationId, type, finalUrl);
      res.json({ success: true, data });
    } catch (error) {
      const errorMsg = error.response?.data?.error?.message || error.message;
      res.status(error.response?.status || 500).json({ 
        success: false, 
        message: errorMsg,
        details: error.response?.data || null
      });
    }
  },

  disconnectAccount: async (req, res) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) return res.status(404).json({ success: false, message: "Business not found for this user" });

      const { accountId } = req.body;
      if (!accountId) {
        return res.status(400).json({ success: false, message: "Account ID is required" });
      }

      await WhatsappService.disconnectAccount(businessId, accountId);
      res.json({ success: true, message: "WhatsApp account disconnected successfully" });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  authWhatsApp: async (req, res, next) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) {
        return res.status(404).json({ success: false, message: "Business not found for this user" });
      }
      const branchId = req.query.branchId || null;

      const redirectUri = envVars.WHATSAPP_REDIRECT_URI;
      const appId = envVars.META_APP_ID;
      const permissions = "whatsapp_business_management,whatsapp_business_messaging";
      
      const state = JSON.stringify({ businessId, branchId });
      const graphVersion = envVars.META_GRAPH_VERSION || "v23.0";
      const extras = JSON.stringify({ setup: { setup_program: "whatsapp" } });

      const configIdParam = envVars.WHATSAPP_CONFIG_ID ? `&config_id=${envVars.WHATSAPP_CONFIG_ID}` : '';
      const authUrl = `https://www.facebook.com/${graphVersion}/dialog/oauth?client_id=${appId}&redirect_uri=${encodeURIComponent(redirectUri)}&response_type=code&scope=${permissions}&state=${encodeURIComponent(state)}&extras=${encodeURIComponent(extras)}${configIdParam}`;

      res.json({
        success: true,
        message: "WhatsApp Embedded Signup URL generated successfully.",
        data: { url: authUrl },
      });
    } catch (error) {
      next(error);
    }
  },

  authWhatsAppCallback: async (req, res, next) => {
    try {
      const { code, state, error, error_description } = req.query;

      if (error) {
        return res.status(400).json({ success: false, message: `WhatsApp OAuth Error: ${error_description}` });
      }

      if (!code || !state) {
        return res.status(400).json({ success: false, message: "Missing code or state from WhatsApp OAuth" });
      }

      const parsedState = JSON.parse(state);
      const businessId = parsedState.businessId;
      const branchId = parsedState.branchId || null;
      const redirectUri = envVars.WHATSAPP_REDIRECT_URI;

      const accounts = await WhatsappService.connectOAuthAccount(businessId, branchId, code, redirectUri);

      res.json({
        success: true,
        message: "WhatsApp account connected successfully.",
        data: { accounts },
      });
    } catch (error) {
      next(error);
    }
  },

  getMedia: async (req, res, next) => {
    try {
      const { businessId } = await getBusinessAndBranchForUser(req.user);
      if (!businessId) {
        return res.status(404).json({ success: false, message: "Business not found for this user" });
      }

      const { mediaId } = req.params;
      const { stream, mimeType, fileSize } = await WhatsappService.getMediaStream(businessId, mediaId);

      res.setHeader("Content-Type", mimeType);
      if (fileSize) {
        res.setHeader("Content-Length", fileSize);
      }
      
      if (req.query.download === "true") {
        res.setHeader("Content-Disposition", `attachment; filename="${mediaId}"`);
      } else {
        res.setHeader("Content-Disposition", `inline; filename="${mediaId}"`);
      }

      stream.pipe(res);
    } catch (error) {
      console.error("Error streaming WhatsApp media:", error);
      res.status(500).json({ success: false, message: error.message });
    }
  },
};
