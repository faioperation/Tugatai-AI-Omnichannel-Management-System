import httpx
from langchain_core.tools import tool
from core.config import ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC, ROBERTO_API_TOKEN
from agent.tools.http_fallback import build_candidates, post_with_fallback


def _lead_candidates():
    return build_candidates(
        bases=[ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC],
        suffixes=[
            "/leads/create",
            "/public/leads/create",
            "/v1/public/leads/create",
        ],
    )


# Channel → source mapping
CHANNEL_SOURCE_MAP = {
    "whatsapp": "WHATSAPP",
    "facebook": "MESSENGER",
    "instagram": "INSTAGRAM",
}


def make_collect_lead(branch_id: str = None, channel: str = None, conversation_id: str = None):

    @tool
    async def collect_lead(
        business_id: str,
        name: str,
        phone: str,
        inquiry: str,
        status: str = "warm",
        email: str = None,
        address: str = None,
        extra_fields: dict = None
    ) -> str:
        """
        IMPORTANT: Call this tool ONLY ONCE per conversation — the FIRST TIME the
        customer shares their name and phone number. Do NOT call this tool again
        if the lead has already been saved in this conversation. If the customer
        sends follow-up messages (like 'thanks', 'okay', 'got it') after the lead
        has been collected, do NOT call this tool again.

        Saves the customer's contact information as a CRM lead.

        Parameters:
        - business_id: The business ID from the conversation (required)
        - name: Customer full name (required)
        - phone: Customer phone number (required)
        - inquiry: One short line describing what the customer is asking about (required)
        - status: The lead's interest level, which YOU decide from the conversation.
          Use exactly one of: "cold", "warm", "hot".
            * cold  - just browsing / general questions, no real intent yet
            * warm  - interested, asking about price/details, not committed
            * hot   - ready to buy/book, gave most details, or confirmed
          Default is "warm" if you are unsure.
        - email: Customer email if provided (optional)
        - address: Customer address if provided (optional)
        - extra_fields: A dict of ANY other useful info you learned about the
          customer that does not fit the named fields above. The backend stores
          these automatically as custom metadata. Use clear camelCase keys, e.g.
          {"companyName": "Innovation Corp", "employeeCount": "150",
           "preferredLanguage": "English"}.
          For PARCEL_DELIVERY and ORDER_BOOKING conversations, if you already
          know the destination and/or the product at this point, include them
          here too, e.g. {"country": "Kenya", "productName": "Refrigerator"} —
          infer the country from a city name if the customer only gave a city
          (e.g. Nairobi -> Kenya).
          Only include what the customer actually told you - never invent values.

        NOTE ON THE RETURN VALUE:
        This tool's return string tells YOU (the agent) whether the lead was
        actually saved on the backend or not:
        - If it starts with "✅" → the lead was genuinely saved. You can tell the
          customer their information has been recorded.
        - If it starts with "⚠️" → the lead was NOT saved (backend rejected it or
          was unreachable). Do NOT tell the customer their info was saved. Instead
          acknowledge you have their details, apologize briefly for a system
          hiccup, and let them know the team will confirm shortly (or use
          handoff_human if this keeps failing).
        """
        # Channel থেকে source map করো — code-এ inject, LLM থেকে না
        source = CHANNEL_SOURCE_MAP.get((channel or "").lower(), "WHATSAPP")

        # --- Required + standard named fields ---
        payload = {
            "businessId": business_id,
            "name": name,
            "phone": phone,
            "note": inquiry,
            "source": source,
            "status": (status or "warm").lower(),
        }

        # conversation_id force-injected by code, never by the LLM
        if conversation_id:
            payload["conversationId"] = conversation_id

        # branch_id force-injected by code, never by the LLM
        if branch_id:
            payload["branchId"] = branch_id

        if email:
            payload["email"] = email
        if address:
            payload["address"] = address

        # --- Dynamic / custom fields (never overwrite standard keys) ---
        if extra_fields:
            for k, v in extra_fields.items():
                if k not in payload and v is not None:
                    payload[k] = v

        print(f"[LEAD] Payload: {payload}")

        try:
            resp = await post_with_fallback(
                candidates=_lead_candidates(),
                json=payload,
                headers={
                    "x-api-token": ROBERTO_API_TOKEN,
                    "Content-Type": "application/json",
                },
                log_tag="LEAD",
            )

            if resp is not None:
                print(f"[LEAD] Final status: {resp.status_code}")
                print(f"[LEAD] Response: {resp.text[:500]}")

                if resp.status_code in (200, 201):
                    return f"✅ Lead saved successfully for {name}."

                # Backend reached but REJECTED the lead (400/401/422/500/...).
                # This is a REAL failure — never tell the LLM it succeeded.
                print(f"[LEAD ERROR] Backend rejected lead: "
                      f"{resp.status_code} - {resp.text[:300]}")
                return (
                    f"⚠️ Lead was NOT saved. Backend rejected the request "
                    f"(status {resp.status_code}): {resp.text[:200]}. "
                    f"Do not tell the customer it was saved — acknowledge their "
                    f"details and let them know the team will confirm shortly."
                )

            # resp is None → every candidate 404'd or was unreachable
            print(f"[LEAD ERROR] No route responded for business_id={business_id}")
            return (
                f"⚠️ Lead was NOT saved — could not reach the backend. "
                f"Do not tell the customer it was saved — acknowledge their "
                f"details and let them know the team will confirm shortly."
            )

        except Exception as e:
            print(f"[LEAD ERROR] {e}")
            return (
                f"⚠️ Lead was NOT saved due to an internal error ({e}). "
                f"Do not tell the customer it was saved — acknowledge their "
                f"details and let them know the team will confirm shortly."
            )

    return collect_lead