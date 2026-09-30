import axios from "axios";
import { envVars } from "../../config/env.js";

const getGraphUrl = () => `https://graph.facebook.com/${envVars.META_GRAPH_VERSION || "v23.0"}`;

export const getLongLivedToken = async (shortLivedToken) => {
  const response = await axios.get(`${getGraphUrl()}/oauth/access_token`, {
    params: {
      grant_type: "fb_exchange_token",
      client_id: envVars.META_APP_ID,
      client_secret: envVars.META_APP_SECRET,
      fb_exchange_token: shortLivedToken,
    },
  });
  return response.data.access_token;
};

export const getPageTokens = async (userAccessToken) => {
  // Fetch pages managed by the user
  const response = await axios.get(`${getGraphUrl()}/me/accounts`, {
    params: {
      access_token: userAccessToken,
    },
  });
  return response.data.data; // Array of pages: { id, name, access_token }
};

export const subscribeAppToPage = async (pageId, pageAccessToken) => {
  try {
    // Subscribe the app to the page's webhook events
    const response = await axios.post(
      `${getGraphUrl()}/${pageId}/subscribed_apps`,
      null,
      {
        params: {
          access_token: pageAccessToken,
          subscribed_fields: "messages,messaging_postbacks,messaging_optins",
        },
      }
    );
    console.log(`✅ [Facebook] Successfully subscribed app to page ${pageId}:`, response.data);
    return response.data;
  } catch (error) {
    console.error(`❌ [Facebook] Error subscribing app to page ${pageId}:`, error.response?.data || error.message);
    return null;
  }
};
