from core.config import ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC, ROBERTO_API_TOKEN
from agent.tools.http_fallback import build_candidates, post_with_fallback


def _whatsapp_candidates():
    return build_candidates(
        bases=[ROBERTO_API_BASE_PUBLIC, ROBERTO_API_BASE],
        suffixes=[
            "/public/whatsapp/messages/send",
            "/v1/public/whatsapp/messages/send",
            "/whatsapp/messages/send",
        ],
    )


async def send_whatsapp(
    business_id: str,
    recipient_id: str,
    conversation_id: str,
    message: str,
    branch_id: str = None,
    continue_ai: bool = True
):
    payload = {
        "businessId": business_id,
        "conversationId": conversation_id,
        "recipientId": recipient_id,
        "message": message,
        # NOTE: without this, the backend stores every OUTGOING message
        # record with continueAi defaulted to true, even on the exact
        # message where the agent called handoff_human this turn — so a
        # human handoff never actually shows up on the message that
        # triggered it. This must travel with the SEND call, not just the
        # /api/agent/message HTTP response, because the send call is what
        # creates the persisted outgoing message record on the backend.
        "continueAi": continue_ai,
    }
    if branch_id:
        payload["branchId"] = branch_id

    await post_with_fallback(
        candidates=_whatsapp_candidates(),
        json=payload,
        headers={"x-api-token": ROBERTO_API_TOKEN},
        log_tag="WHATSAPP",
    )