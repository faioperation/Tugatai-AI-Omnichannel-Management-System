import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.config import VAPI_API_KEY, VAPI_BASE
from app.vapi_client import vapi_headers

router = APIRouter()


class TelephonyLinkRequest(BaseModel):
    phone_number_id: str
    assistant_id: str


@router.post("/api/telephony/link")
async def link_phone(data: TelephonyLinkRequest):
    """
    Links a Vapi phone number (Twilio or Vonage) to a specific assistant/agent.
    """
    url = f"{VAPI_BASE}/phone-number/{data.phone_number_id}"
    payload = {
        "assistantId": data.assistant_id
    }

    async with httpx.AsyncClient(timeout=20) as client:
        try:
            resp = await client.patch(url, json=payload, headers=vapi_headers())
            if resp.status_code in (200, 201, 204):
                return resp.json()
            raise HTTPException(resp.status_code, f"Failed linking phone number in Vapi: {resp.text}")
        except httpx.ReadTimeout:
            raise HTTPException(504, "Vapi timed out while linking phone number")
