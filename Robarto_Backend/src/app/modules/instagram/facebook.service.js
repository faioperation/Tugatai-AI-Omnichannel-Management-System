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

export const getInstagramAccountForPage = async (pageId, pageAccessToken, userAccessToken) => {
  // 1. Try querying page node with userAccessToken (since user authorized the Instagram account)
  if (userAccessToken) {
    try {
      const userLevelRes = await axios.get(`${getGraphUrl()}/${pageId}`, {
        params: {
          access_token: userAccessToken,
          fields: "id,name,instagram_business_account",
        },
      });
      console.log(`🔎 [User-Token Page Inspection] Page ${pageId}:`, JSON.stringify(userLevelRes.data, null, 2));
      if (userLevelRes.data?.instagram_business_account) {
        return userLevelRes.data.instagram_business_account;
      }
    } catch (uErr) {
      console.warn(`[User-Token Page Inspection] Warning:`, uErr.response?.data?.error?.message || uErr.message);
    }
  }

  // 2. Try querying page node with pageAccessToken
  try {
    const response = await axios.get(`${getGraphUrl()}/${pageId}`, {
      params: {
        access_token: pageAccessToken,
        fields: "id,name,instagram_business_account,instagram_accounts{id,username,name},connected_instagram_account{id,username,name}",
      },
    });
    console.log(`🔎 [Page Inspection] Page ${pageId} details:`, JSON.stringify(response.data, null, 2));
    
    // Check if instagram_business_account or instagram_accounts array exists
    if (response.data?.instagram_business_account) {
      return response.data.instagram_business_account;
    }
    if (response.data?.instagram_accounts?.data && response.data.instagram_accounts.data.length > 0) {
      return response.data.instagram_accounts.data[0];
    }
    if (response.data?.connected_instagram_account) {
      return response.data.connected_instagram_account;
    }
  } catch (err) {
    console.error(`❌ [Page Inspection] Error inspecting page ${pageId}:`, err.response?.data?.error?.message || err.message);
  }

  // 3. Edge query: GET /{pageId}/instagram_accounts
  try {
    const igRes = await axios.get(`${getGraphUrl()}/${pageId}/instagram_accounts`, {
      params: {
        access_token: pageAccessToken,
        fields: "id,username,name",
      },
    });
    console.log(`🔎 [Page Edge] Page ${pageId} /instagram_accounts:`, JSON.stringify(igRes.data, null, 2));
    if (igRes.data?.data && igRes.data.data.length > 0) {
      return igRes.data.data[0];
    }
  } catch (edgeErr) {
    // Edge query failed, continue
  }

  return null;
};

export const getAuthorizedInstagramAccountsFromToken = async (userAccessToken) => {
  try {
    const appAccessToken = `${envVars.META_APP_ID}|${envVars.META_APP_SECRET}`;
    const debugRes = await axios.get(`${getGraphUrl()}/debug_token`, {
      params: {
        input_token: userAccessToken,
        access_token: appAccessToken,
      },
    });
    console.log("🔎 [Debug Token Inspection]:", JSON.stringify(debugRes.data, null, 2));
    const granularScopes = debugRes.data?.data?.granular_scopes || [];
    const igScope = granularScopes.find((s) => s.scope === "instagram_manage_messages" || s.scope === "instagram_basic" || s.scope === "instagram_business_basic");
    if (igScope && igScope.target_ids && igScope.target_ids.length > 0) {
      return igScope.target_ids;
    }
  } catch (err) {
    console.warn("Could not inspect debug_token:", err.response?.data?.error?.message || err.message);
  }
  return [];
};

export const getPageTokens = async (userAccessToken) => {
  // Fetch pages managed by the user, requesting instagram_business_account
  const response = await axios.get(`${getGraphUrl()}/me/accounts`, {
    params: {
      access_token: userAccessToken,
      fields: "id,name,access_token,instagram_business_account"
    },
  });
  
  const pages = response.data.data || [];
  
  // Inspect each page with its own Page Access Token if instagram_business_account was not returned on /me/accounts
  for (const page of pages) {
    if (!page.instagram_business_account) {
      const igAccount = await getInstagramAccountForPage(page.id, page.access_token, userAccessToken);
      if (igAccount) {
        page.instagram_business_account = igAccount;
      }
    }
  }

  // Fallback 1: Check /me?fields=accounts{...}
  if (pages.length > 0 && !pages.some((p) => p.instagram_business_account)) {
    try {
      const meRes = await axios.get(`${getGraphUrl()}/me`, {
        params: {
          access_token: userAccessToken,
          fields: "id,name,accounts{id,name,access_token,instagram_business_account}",
        },
      });
      console.log("🔎 [Me Inspection] Accounts:", JSON.stringify(meRes.data, null, 2));
      const accs = meRes.data?.accounts?.data || [];
      for (const acc of accs) {
        if (acc.instagram_business_account) {
          const matched = pages.find((p) => p.id === acc.id);
          if (matched) {
            matched.instagram_business_account = acc.instagram_business_account;
          } else {
            pages.push(acc);
          }
        }
      }
    } catch (meErr) {
      console.warn("Could not fetch /me accounts:", meErr.response?.data?.error?.message || meErr.message);
    }
  }

  // Fallback 2: Check Business Manager for linked instagram accounts
  if (pages.length > 0 && !pages.some((p) => p.instagram_business_account)) {
    try {
      const bizRes = await axios.get(`${getGraphUrl()}/me/businesses`, {
        params: {
          access_token: userAccessToken,
          fields: "id,name,instagram_accounts{id,username,name}",
        },
      });
      const businesses = bizRes.data?.data || [];
      console.log("🔎 [Business Inspection] Businesses returned:", JSON.stringify(businesses, null, 2));
      for (const biz of businesses) {
        if (biz.instagram_accounts?.data && biz.instagram_accounts.data.length > 0) {
          const ig = biz.instagram_accounts.data[0];
          pages[0].instagram_business_account = ig;
          console.log(`✅ [Business Inspection] Attached Instagram account via Business Manager ${biz.id}:`, ig);
          break;
        }
      }
    } catch (bizErr) {
      console.warn("Could not fetch /me/businesses:", bizErr.response?.data?.error?.message || bizErr.message);
    }
  }

  // Fallback 3: Check debug_token granular_scopes for directly selected Instagram Accounts
  if (pages.length > 0 && !pages.some((p) => p.instagram_business_account)) {
    const targetIgIds = await getAuthorizedInstagramAccountsFromToken(userAccessToken);
    for (const targetId of targetIgIds) {
      try {
        const igInfo = await axios.get(`${getGraphUrl()}/${targetId}`, {
          params: {
            access_token: userAccessToken,
            fields: "id,username,name",
          },
        });
        console.log(`✅ [Token Direct Discovery] Found Instagram Account ${targetId}:`, igInfo.data);
        pages[0].instagram_business_account = igInfo.data;
        break;
      } catch (igErr) {
        console.warn(`Could not fetch details for Instagram Account ${targetId}:`, igErr.response?.data?.error?.message || igErr.message);
        pages[0].instagram_business_account = { id: targetId, username: "Instagram User" };
        break;
      }
    }
  }

  return pages;
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
    console.log(`✅ [Instagram] Successfully subscribed app to page ${pageId}:`, response.data);
    return response.data;
  } catch (error) {
    console.error(`❌ [Instagram] Error subscribing app to page ${pageId}:`, error.response?.data || error.message);
    return null;
  }
};
