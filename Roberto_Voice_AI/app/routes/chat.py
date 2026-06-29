"""
Chat Route — Text-based testing interface for VAPI voice agents.
Allows sending a text message to a VAPI assistant and getting back a text reply.
Useful for local testing without an actual phone call.
"""
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx

from app.config import OPENAI_API_KEY
from app.vapi_client import get_assistant_from_vapi

router = APIRouter()
logger = logging.getLogger(__name__)


class ChatRequest(BaseModel):
    assistant_id: str
    message: str
    session_id: str | None = None  # optional, for future multi-turn memory


class ChatResponse(BaseModel):
    assistant_id: str
    user_message: str
    response: str
    agent_name: str | None = None


@router.post("/api/chat-with-agent", response_model=ChatResponse)
async def chat_with_agent(req: ChatRequest):
    """
    Send a text message to a VAPI assistant and get a reply.
    This fetches the assistant's system prompt from VAPI and calls
    OpenAI directly to simulate a conversation — no phone call needed.

    Body:
      assistant_id: The VAPI assistant ID
      message: The user's text message
    """
    if not req.assistant_id:
        raise HTTPException(status_code=400, detail="assistant_id is required")
    if not req.message:
        raise HTTPException(status_code=400, detail="message is required")
    if not OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not configured")

    # ── Fetch assistant's system prompt from VAPI ─────────────────────────────
    try:
        assistant = await get_assistant_from_vapi(req.assistant_id)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to fetch assistant from VAPI: {e}")

    if not assistant:
        raise HTTPException(status_code=404, detail=f"Assistant {req.assistant_id} not found in VAPI")

    agent_name = assistant.get("name", "Assistant")
    model_config = assistant.get("model", {})
    messages_list = model_config.get("messages", [])

    # Extract the system prompt
    system_prompt = ""
    for msg in messages_list:
        if msg.get("role") == "system":
            system_prompt = msg.get("content", "")
            break

    if not system_prompt:
        system_prompt = f"You are {agent_name}, a professional AI voice agent."

    # ── Call OpenAI with the assistant's system prompt ───────────────────────
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "gpt-4o-mini",  # Fast, cost-efficient for text tests
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": req.message}
        ],
        "temperature": 0.3,
        "max_tokens": 300
    }

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers=headers,
                json=payload
            )
        if resp.status_code != 200:
            raise HTTPException(status_code=502, detail=f"OpenAI error: {resp.text}")

        result = resp.json()
        agent_reply = result["choices"][0]["message"]["content"].strip()

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[CHAT] OpenAI call failed: {e}", exc_info=True)
        raise HTTPException(status_code=502, detail=f"LLM call failed: {e}")

    logger.info(f"[CHAT] assistant={req.assistant_id} | user={req.message[:60]} | reply={agent_reply[:60]}")

    return ChatResponse(
        assistant_id=req.assistant_id,
        user_message=req.message,
        response=agent_reply,
        agent_name=agent_name
    )
