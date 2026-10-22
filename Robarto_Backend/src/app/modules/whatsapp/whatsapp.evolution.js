import axios from "axios";
import { envVars } from "../../config/env.js";

const getClient = () => {
  const baseURL = envVars.EVOLUTION_API_URL.replace(/\/$/, "");
  return axios.create({
    baseURL,
    headers: {
      apikey: envVars.EVOLUTION_API_KEY,
      "Content-Type": "application/json",
    },
    timeout: 15000,
  });
};

export const EvolutionAPI = {
  createInstance: async (instanceName, webhookUrl) => {
    const client = getClient();
    try {
      // 1. Create instance (Clean DTO matching Evolution API specification)
      const response = await client.post("/instance/create", {
        instanceName,
        qrcode: true,
        integration: "WHATSAPP-BAILEYS",
      });

      // 2. Configure Webhook for this instance
      if (webhookUrl) {
        try {
          const eventsList = [
            "APPLICATION_STARTUP",
            "QRCODE_UPDATED",
            "CONNECTION_UPDATE",
            "MESSAGES_SET",
            "MESSAGES_UPSERT",
            "MESSAGES_UPDATE",
            "MESSAGES_DELETE",
            "SEND_MESSAGE",
            "CONTACTS_SET",
            "CONTACTS_UPSERT",
            "CHATS_SET",
            "CHATS_UPSERT",
          ];

          await client.post(`/webhook/set/${instanceName}`, {
            webhook: {
              enabled: true,
              url: webhookUrl,
              byEvents: false,
              base64: false,
              events: eventsList,
            },
          });
        } catch (webhookErr) {
          console.warn(`[EvolutionAPI] Webhook setup warning for ${instanceName}:`, webhookErr.response?.data || webhookErr.message);
        }
      }

      return response.data;
    } catch (error) {
      // If instance already exists, return current connection state / QR
      if (error.response?.status === 403 || error.response?.data?.error?.includes("already in use")) {
        return await EvolutionAPI.connectInstance(instanceName);
      }
      throw error;
    }
  },

  connectInstance: async (instanceName) => {
    const client = getClient();
    const response = await client.get(`/instance/connect/${instanceName}`);
    return response.data;
  },

  getConnectionState: async (instanceName) => {
    const client = getClient();
    try {
      const response = await client.get(`/instance/connectionState/${instanceName}`);
      return response.data?.instance?.state || "close";
    } catch (error) {
      return "close";
    }
  },

  sendMessage: async (instanceName, to, text) => {
    const client = getClient();
    // Normalize phone number (remove JID suffix, +, spaces, non-digits)
    const cleanNumber = (to || "").replace(/@.*$/, "").replace(/\D/g, "");
    try {
      const response = await client.post(`/message/sendText/${instanceName}`, {
        number: cleanNumber,
        text,
      });
      return response.data;
    } catch (error) {
      // If instance socket is not in memory or restarting, trigger connect and retry once
      const errMsg = error.response?.data?.response?.message || error.response?.data?.message || "";
      if (errMsg.includes("onWhatsApp") || error.response?.status === 500) {
        console.log(`[EvolutionAPI] Re-triggering connection for "${instanceName}" and retrying send...`);
        try {
          await client.get(`/instance/connect/${instanceName}`);
          await new Promise((resolve) => setTimeout(resolve, 1500));
          const retryRes = await client.post(`/message/sendText/${instanceName}`, {
            number: cleanNumber,
            text,
          });
          return retryRes.data;
        } catch (retryErr) {
          console.error(`[EvolutionAPI] Retry failed for "${instanceName}":`, retryErr.response?.data || retryErr.message);
          throw retryErr;
        }
      }
      throw error;
    }
  },

  sendMedia: async (instanceName, to, type, mediaUrl, caption = "") => {
    const client = getClient();
    const cleanNumber = (to || "").replace(/@.*$/, "").replace(/\D/g, "");
    
    // mediatype: 'image' | 'document' | 'video' | 'audio'
    let mediatype = "image";
    if (type === "document" || type === "pdf") mediatype = "document";
    else if (type === "video") mediatype = "video";
    else if (type === "audio") mediatype = "audio";

    try {
      const response = await client.post(`/message/sendMedia/${instanceName}`, {
        number: cleanNumber,
        mediatype,
        media: mediaUrl,
        caption: caption || undefined,
      });
      return response.data;
    } catch (error) {
      const errMsg = error.response?.data?.response?.message || error.response?.data?.message || "";
      if (errMsg.includes("onWhatsApp") || error.response?.status === 500) {
        try {
          await client.get(`/instance/connect/${instanceName}`);
          await new Promise((resolve) => setTimeout(resolve, 1500));
          const retryRes = await client.post(`/message/sendMedia/${instanceName}`, {
            number: cleanNumber,
            mediatype,
            media: mediaUrl,
            caption: caption || undefined,
          });
          return retryRes.data;
        } catch (retryErr) {
          throw retryErr;
        }
      }
      throw error;
    }
  },

  fetchInstances: async () => {
    const client = getClient();
    try {
      const response = await client.get("/instance/fetchInstances");
      return response.data || [];
    } catch (error) {
      console.warn("[EvolutionAPI] Failed to fetch instances:", error.message);
      return [];
    }
  },

  deleteInstance: async (instanceName) => {
    const client = getClient();
    try {
      const response = await client.delete(`/instance/delete/${instanceName}`);
      return response.data;
    } catch (error) {
      console.warn(`[EvolutionAPI] Failed to delete instance ${instanceName}:`, error.message);
      return null;
    }
  },

  logoutInstance: async (instanceName) => {
    const client = getClient();
    try {
      const response = await client.delete(`/instance/logout/${instanceName}`);
      return response.data;
    } catch (error) {
      console.warn(`[EvolutionAPI] Failed to logout instance ${instanceName}:`, error.message);
      return null;
    }
  },

  getBase64FromMediaMessage: async (instanceName, messageKey, convertToMp4 = false) => {
    const client = getClient();
    try {
      const response = await client.post(`/chat/getBase64FromMediaMessage/${instanceName}`, {
        message: {
          key: messageKey,
        },
        convertToMp4,
      });
      return response.data; // { base64: "...", mimetype: "..." }
    } catch (error) {
      console.warn(`[EvolutionAPI] Failed to get base64 media for ${instanceName}:`, error.response?.data || error.message);
      return null;
    }
  },
};
