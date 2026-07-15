from datetime import datetime

from fastapi import APIRouter, Depends
from core.security import verify_token
from webhooks.incoming import handle_incoming, paused_conversations
from agent.reply_suggester import generate_reply_suggestion

router = APIRouter()

# ── Debug capture ──────────────────────────────────────────────────────
# Stores the last N raw payloads received on /agent/message, so they can be
# inspected via Postman/GET even when console logs are off (e.g. in a
# production deployment). This is purely for debugging — it lives in memory
# only, resets on restart, and is capped so it never grows unbounded.
_DEBUG_LOG_MAX = 50
_debug_log = []


def _record_debug(payload: dict, response=None):
    _debug_log.append({
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "payload": payload,
        "response": response,
    })
    if len(_debug_log) > _DEBUG_LOG_MAX:
        _debug_log.pop(0)


# Main message endpoint — Roberto sends messages here
@router.post("/agent/message")
async def agent_message(payload: dict, _=Depends(verify_token)):
    business_id = payload.get("business_id")
    recipient_id = payload.get("recipient_id")

    # Check if AI is paused for this conversation
    key = f"{business_id}:{recipient_id}"
    if key in paused_conversations:
        result = {"status": "ok", "paused": True, "response": None, "continueAi": False}
        _record_debug(payload, result)
        return result

    # Process message and get AI response. handle_incoming() (via
    # run_agent()) returns {"response": ..., "continue_ai": ...} —
    # continue_ai is False whenever the AI called handoff_human this turn,
    # signalling the backend that a human should take over from here.
    agent_result = await handle_incoming(payload)
    ai_response = agent_result.get("response") if agent_result else None
    continue_ai = agent_result.get("continue_ai", True) if agent_result else True

    result = {
        "status": "ok",
        "paused": False,
        "response": ai_response,
        "continueAi": continue_ai,
    }
    _record_debug(payload, result)
    return result


# Debug endpoint — GET this via Postman (with x-api-token header) right
# after sending a test message on WhatsApp/Messenger/Instagram, to see
# EXACTLY what raw payload the backend posted to /agent/message and what
# the agent replied — no console/terminal access needed.
@router.get("/agent/debug/last-messages")
async def debug_last_messages(_=Depends(verify_token)):
    return {
        "count": len(_debug_log),
        # Most recent first
        "messages": list(reversed(_debug_log)),
    }


# Handoff control endpoint — Roberto calls this to pause or resume AI
@router.post("/agent/handoff")
async def agent_handoff(payload: dict, _=Depends(verify_token)):
    business_id = payload.get("business_id")
    recipient_id = payload.get("recipient_id")
    action = payload.get("action")  # "pause" or "resume"

    key = f"{business_id}:{recipient_id}"

    if action == "pause":
        paused_conversations.add(key)
        return {"status": "paused"}

    elif action == "resume":
        paused_conversations.discard(key)
        return {"status": "resumed"}

    return {"status": "error", "message": "action must be pause or resume"}


# AI-assisted reply for human agents — the frontend's "Reply" (sparkle)
# button calls this when a human wants AI help drafting a response while
# they're the one handling the conversation (e.g. after a handoff). This
# ONLY returns suggested text — it does NOT send anything to the customer,
# does NOT save anything to conversation memory, and does NOT let the model
# call collect_lead / create_booking / handoff_human. The frontend should
# place the returned text into the reply box, editable, and only send it
# through the normal send flow once the human agent confirms/edits it.
@router.post("/agent/suggest-reply")
async def suggest_reply(payload: dict, _=Depends(verify_token)):
    business_id = payload.get("business_id") or payload.get("businessId")
    subject = payload.get("subject")
    conversation_id = payload.get("conversation_id") or payload.get("conversationId")
    # recipient_id is OPTIONAL here — it's only used as a local in-memory
    # fallback if the backend's own conversation_id-based history lookup
    # comes back empty. The primary lookup is entirely conversation_id
    # based, so this endpoint works off business_id + subject +
    # conversation_id alone.
    recipient_id = payload.get("recipient_id") or payload.get("recipientId")
    branch_id = payload.get("branch_id") or payload.get("branchId")

    if not business_id or not conversation_id:
        result = {
            "status": "error",
            "message": "business_id and conversation_id are required",
            "suggestedReply": None,
        }
        _record_debug(payload, result)
        return result

    draft = await generate_reply_suggestion(
        business_id=business_id,
        subject=subject,
        conversation_id=conversation_id,
        recipient_id=recipient_id,
        branch_id=branch_id,
    )

    result = {"status": "ok", "suggestedReply": draft}
    _record_debug(payload, result)
    return result