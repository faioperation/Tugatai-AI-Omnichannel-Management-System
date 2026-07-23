from collections import defaultdict

import httpx

from core.config import ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC, ROBERTO_API_TOKEN
from agent.tools.http_fallback import build_candidates, get_with_fallback

_memory = defaultdict(list)
_conversation_ids = {}

# Stores the real subject per conversation so the summary job can analyse each
# conversation with the correct business context (instead of hardcoded "cargo").
_subjects = {}


def get_history(business_id: str, recipient_id: str) -> list:
    key = f"{business_id}_{recipient_id}"
    return _memory[key]


# ── Backend-sourced conversation history ─────────────────────────────────
# Local in-memory `_memory` is lost on every restart. For building the LLM's
# conversation context (NOT for the summary job — that still uses local
# `_memory` as before), we instead fetch the real history from the backend,
# which persists it in its own database regardless of our process lifetime.

_HISTORY_PLACEHOLDERS = {
    "image": "[Customer shared an image]",
    "audio": "[Customer sent a voice message]",
    "document": "[Customer shared a document]",
}


def _history_candidates(conversation_id: str):
    return build_candidates(
        bases=[ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC],
        suffixes=[
            f"/v1/public/message-history/{conversation_id}",
            f"/public/message-history/{conversation_id}",
            f"/message-history/{conversation_id}",
        ],
    )


def _media_placeholder(msg_type: str) -> str:
    return _HISTORY_PLACEHOLDERS.get(msg_type, f"[Customer shared a {msg_type} message]")


async def fetch_conversation_history(conversation_id: str) -> list:
    """
    Fetches this conversation's message history from the backend (the real
    source of truth — persisted in its own database), instead of relying on
    the local `_memory` dict that's lost on every restart.

    Returns a LangChain-style messages list: [{"role": "user"/"assistant",
    "content": "..."}, ...], oldest first.

    NOTE: past image/voice/document messages only get a short placeholder
    here — the backend stores the raw media (type + mediaUrl) but not the
    transcription/description text we generate at the time. Only the
    CURRENT turn's media gets fully parsed (transcribed/described) by
    message_parser.py; this is an accepted trade-off for persistent memory
    across restarts.

    Returns an empty list (never raises) if there's no conversation_id yet,
    or if the backend call fails — callers should fall back to local
    `get_history()` in that case.
    """
    if not conversation_id:
        return []

    try:
        resp = await get_with_fallback(
            candidates=_history_candidates(conversation_id),
            headers={
                "x-api-token": ROBERTO_API_TOKEN,
                "Content-Type": "application/json",
            },
            log_tag="HISTORY",
        )

        if resp is None or resp.status_code != 200:
            print(f"[HISTORY] No history found for conversation {conversation_id} "
                  f"(status: {resp.status_code if resp is not None else 'no response'})")
            return []

        payload = resp.json()
        raw_messages = payload.get("data", {}).get("messages", [])

        history = []
        for msg in raw_messages:
            sender_type = msg.get("senderType")
            role = "user" if sender_type == "customer" else "assistant"

            text = msg.get("text")
            if not text:
                text = _media_placeholder(msg.get("type", "message"))

            history.append({"role": role, "content": text})

        print(f"[HISTORY] Fetched {len(history)} messages for conversation {conversation_id}")
        return history

    except Exception as e:
        print(f"[HISTORY ERROR] {e}")
        return []


def save_message(business_id: str, recipient_id: str, role: str, content: str):
    key = f"{business_id}_{recipient_id}"
    _memory[key].append({"role": role, "content": content})


def save_conversation_id(business_id: str, recipient_id: str, conversation_id: str):
    key = f"{business_id}_{recipient_id}"
    _conversation_ids[key] = conversation_id


def get_conversation_id(business_id: str, recipient_id: str):
    """
    Returns the real backend conversation UUID if we have one, otherwise None.

    IMPORTANT: we deliberately return None (not recipient_id) when unknown.
    The recipient_id is a phone/channel id, NOT a conversation UUID, so using it
    as conversationId made summary upserts target a non-existent conversation and
    silently fail. Callers must handle None (skip push / log) instead.
    """
    key = f"{business_id}_{recipient_id}"
    return _conversation_ids.get(key)


def save_subject(business_id: str, recipient_id: str, subject: str):
    key = f"{business_id}_{recipient_id}"
    if subject:
        _subjects[key] = subject


def get_subject(business_id: str, recipient_id: str) -> str:
    key = f"{business_id}_{recipient_id}"
    return _subjects.get(key, "")


def clear_history(business_id: str, recipient_id: str):
    key = f"{business_id}_{recipient_id}"
    _memory[key] = []