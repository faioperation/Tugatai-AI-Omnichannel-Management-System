import logging
import httpx
from fastapi import APIRouter, HTTPException, Form
from pydantic import BaseModel

from app.config import VAPI_API_KEY, VAPI_BASE
from app.vapi_client import vapi_headers

router = APIRouter()
logger = logging.getLogger(__name__)


class TelephonyLinkRequest(BaseModel):
    phone_number_id: str
    assistant_id: str


class TelephonyTeardownRequest(BaseModel):
    phone_number_id: str | None = None
    transfer_tool_id: str | None = None
    assistant_id: str | None = None


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


@router.post("/api/telephony/setup-twilio")
async def setup_twilio(
    twilio_sid: str = Form(...),
    twilio_auth_token: str = Form(...),
    twilio_number: str = Form(...),
    transfer_number: str = Form(...),
    assistant_id: str = Form(...)
):
    """
    All-in-one endpoint to setup Twilio number and transfer routing for a specific agent.
    1. Imports the Twilio number to Vapi and binds it to the assistant.
    2. Creates a transferCall tool pointing to the transfer_number and attaches it to the assistant.
    """
    from app.vapi_client import import_twilio_number, attach_transfer_tool
    
    try:
        # 1. Import and bind the Twilio number
        phone_result = await import_twilio_number(
            twilio_sid=twilio_sid,
            twilio_auth_token=twilio_auth_token,
            twilio_number=twilio_number,
            assistant_id=assistant_id
        )
        
        # 2. Setup the native transfer call tool
        tool_id = await attach_transfer_tool(
            assistant_id=assistant_id,
            transfer_number=transfer_number,
            twilio_number=twilio_number
        )
        
        return {
            "status": "success",
            "message": "Twilio number imported and transfer tool attached successfully.",
            "phone_number_id": phone_result.get("id"),
            "transfer_tool_id": tool_id,
            "assistant_id": assistant_id,
            "twilio_number": twilio_number,
            "transfer_destination": transfer_number
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/api/telephony/teardown")
async def teardown_telephony(data: TelephonyTeardownRequest):
    """
    Deletes a phone number and/or transfer tool from VAPI, and detaches the tool from the assistant.
    Body JSON:
      - phone_number_id: ID of the Vapi phone number to delete (optional)
      - transfer_tool_id: ID of the transfer tool to delete (optional)
      - assistant_id: ID of the assistant to detach the tool from (optional)
    """
    from app.vapi_client import delete_phone_number, delete_tool, detach_tool_from_assistant

    if not data.phone_number_id and not data.transfer_tool_id:
        raise HTTPException(status_code=400, detail="At least one of phone_number_id or transfer_tool_id must be provided.")

    deleted_phone = False
    deleted_tool = False

    if data.transfer_tool_id:
        if data.assistant_id:
            try:
                await detach_tool_from_assistant(data.assistant_id, data.transfer_tool_id)
            except Exception as e:
                logger.warning(f"Failed to detach tool from assistant: {e}")
        try:
            await delete_tool(data.transfer_tool_id)
            deleted_tool = True
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to delete transfer tool {data.transfer_tool_id}: {e}")

    if data.phone_number_id:
        try:
            await delete_phone_number(data.phone_number_id)
            deleted_phone = True
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to delete phone number {data.phone_number_id}: {e}")

    return {
        "status": "success",
        "message": "Telephony resources deleted successfully.",
        "phone_number_deleted": deleted_phone,
        "transfer_tool_deleted": deleted_tool,
        "phone_number_id": data.phone_number_id,
        "transfer_tool_id": data.transfer_tool_id
    }

