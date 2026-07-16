import logging
import json
import httpx
from fastapi import APIRouter, Request, HTTPException

from app.config import BACKEND_URL

router = APIRouter()
logger = logging.getLogger(__name__)


def _extract_call_info(data: dict) -> tuple[str | None, str | None, dict]:
    """Extract (call_id, assistant_id, call_obj) from a VAPI webhook payload."""
    message = data.get("message", {})
    call_obj = message.get("call") or data.get("call") or {}
    call_id = call_obj.get("id")
    assistant_id = call_obj.get("assistantId")
    return call_id, assistant_id, call_obj


def _parse_arguments(raw) -> dict:
    """VAPI sends tool arguments as a JSON string. Parse it into a dict."""
    if isinstance(raw, dict):
        return raw
    if isinstance(raw, str):
        try:
            parsed = json.loads(raw)
            if isinstance(parsed, dict):
                return parsed
        except (json.JSONDecodeError, ValueError):
            pass
    return {}


def _determine_lead_status(collected: dict) -> str:
    """Determine final lead status from collected tool tags and data keys."""
    tool_statuses = [v for k, v in collected.items() if k.startswith("_tool_")]

    # Priority order
    for priority_status in ("booked", "ordered", "escalated", "scheduled", "quoted"):
        if priority_status in tool_statuses:
            return priority_status

    # Fallback: infer from data keys
    keys_str = " ".join(collected.keys()).lower()
    if any(w in keys_str for w in ["booking", "booking_ref", "reservation"]):
        return "booked"
    if any(w in keys_str for w in ["order", "order_items"]):
        return "ordered"
    if any(w in keys_str for w in ["escalate", "reason"]):
        return "escalated"

    data_fields = [k for k in collected.keys() if not k.startswith("_tool_")]
    if len(data_fields) >= 2:
        return "warm"
    if len(data_fields) == 1:
        return "cold"
    return "abandoned"


@router.post("/webhook/order")
async def handle_order(payload: dict):
    """
    Receives and logs order details, then forwards them to the configured backend.
    """
    logger.info(f"[ORDER_WEBHOOK] Received order payload: {json.dumps(payload)}")
    if BACKEND_URL:
        # Forward to the user's primary backend
        await _post_to_backend(f"{BACKEND_URL.rstrip('/')}/order", payload)
    return {"status": "order_processed"}


@router.post("/webhook/summary")
async def handle_summary(payload: dict):
    """
    Receives and logs call summary details, then forwards them to the configured backend.
    """
    logger.info(f"[SUMMARY_WEBHOOK] Received summary payload: {json.dumps(payload)}")
    if BACKEND_URL:
        # Forward to the user's primary backend
        await _post_to_backend(f"{BACKEND_URL.rstrip('/')}/summary", payload)
    return {"status": "summary_processed"}


@router.post("/api/webhook/vapi")
async def handle_vapi_webhook(request: Request):
    """
    Vapi Tool Fallback webhook endpoint. Handles all events for active calls.
    """
    try:
        data = await request.json()
        message = data.get("message", {})
        event_type = message.get("type", "unknown")
        logger.info(f"[VAPI_WEBHOOK] Event received: {event_type}")

        call_id, assistant_id, call_obj = _extract_call_info(data)
        if not call_id:
            logger.warning("[VAPI_WEBHOOK] No call_id in webhook — ignoring")
            return {"status": "ignored", "reason": "no call_id"}

        # ─────────────────────────────────────────────────────────────────────
        # CALL STARTED
        # ─────────────────────────────────────────────────────────────────────
        if event_type == "call-started":
            customer = call_obj.get("customer", {})
            phone = customer.get("number") or call_obj.get("phoneNumber", {}).get("number") or ""
            direction = call_obj.get("type", "inbound")
            logger.info(f"[VAPI_WEBHOOK] Call started: {call_id} | phone={phone} | direction={direction}")
            return {"status": "recorded"}

        # ─────────────────────────────────────────────────────────────────────
        # TOOL CALLS
        # ─────────────────────────────────────────────────────────────────────
        elif event_type == "tool-calls":
            tool_calls = message.get("toolCallList") or message.get("toolCalls") or []
            if not tool_calls:
                return {"results": []}

            results = []
            for tc in tool_calls:
                tc_id = tc.get("id", "")
                func = tc.get("function", {})
                tool_name = func.get("name", "")
                raw_args = func.get("arguments", {})
                arguments = _parse_arguments(raw_args)

                logger.info(f"[VAPI_WEBHOOK] Tool call: {tool_name} with args: {arguments}")

                # Determine semantic status and message
                tl = tool_name.lower()
                is_order = any(w in tl for w in ["order", "process", "purchase"])
                
                if any(w in tl for w in ["booking", "confirm", "reserve"]):
                    result_data = {
                        "status": "booked",
                        "lead_status": "booked",
                        "message": "Booking confirmed and registered."
                    }
                elif is_order:
                    result_data = {
                        "status": "ordered",
                        "lead_status": "ordered",
                        "message": "Order successfully processed and created."
                    }
                elif any(w in tl for w in ["quote", "price", "estimate"]):
                    result_data = {
                        "status": "quoted",
                        "lead_status": "warm",
                        "message": "Price quote generated successfully."
                    }
                elif any(w in tl for w in ["escalate", "human", "transfer", "attorney", "manager", "advisor", "agent"]):
                    result_data = {
                        "status": "escalated",
                        "lead_status": "hot",
                        "message": "Call escalated to a human agent."
                    }
                elif any(w in tl for w in ["schedule", "consultation", "viewing", "appointment"]):
                    result_data = {
                        "status": "scheduled",
                        "lead_status": "booked",
                        "message": "Appointment successfully scheduled."
                    }
                elif any(w in tl for w in ["info", "menu", "listing", "details"]):
                    result_data = {
                        "status": "info_provided",
                        "lead_status": "warm",
                        "message": "Information provided to customer."
                    }
                else:
                    result_data = {
                        "status": "completed",
                        "lead_status": "warm",
                        "message": f"Tool '{tool_name}' executed successfully."
                    }

                # Forward order tool calls to /webhook/order locally
                if is_order:
                    order_payload = {
                        "call_id": call_id,
                        "assistant_id": assistant_id,
                        "tool_name": tool_name,
                        "arguments": arguments,
                        "result": result_data
                    }
                    try:
                        await handle_order(order_payload)
                    except Exception as e:
                        logger.error(f"Failed to forward local order webhook: {e}")

                results.append({
                    "toolCallId": tc_id,
                    "result": json.dumps(result_data)
                })

            return {"results": results}

        # ─────────────────────────────────────────────────────────────────────
        # TRANSCRIPT
        # ─────────────────────────────────────────────────────────────────────
        elif event_type == "transcript":
            role = message.get("role", "")
            content = message.get("transcript", "") or message.get("content", "")
            if content:
                logger.info(f"[VAPI_WEBHOOK] Transcript - {role.capitalize()}: {content}")
            return {"status": "recorded"}

        # ─────────────────────────────────────────────────────────────────────
        # END OF CALL REPORT
        # ─────────────────────────────────────────────────────────────────────
        elif event_type == "end-of-call-report":
            artifact = message.get("artifact", {})
            full_transcript = artifact.get("transcript", "")
            
            # Parse message history to extract collected tool call parameters
            msg_list = artifact.get("messages", []) or []
            collected = {}
            
            for msg in msg_list:
                if msg.get("role") == "assistant" and msg.get("toolCalls"):
                    for tc in msg["toolCalls"]:
                        func = tc.get("function", {})
                        func_name = func.get("name", "")
                        raw_args = func.get("arguments", {})
                        args = _parse_arguments(raw_args)
                        
                        collected.update(args)
                        
                        # Tag tool status
                        tl = func_name.lower()
                        if any(w in tl for w in ["booking", "confirm", "reserve"]):
                            collected[f"_tool_{func_name}"] = "booked"
                        elif any(w in tl for w in ["order", "process", "purchase"]):
                            collected[f"_tool_{func_name}"] = "ordered"
                        elif any(w in tl for w in ["escalate", "human", "transfer"]):
                            collected[f"_tool_{func_name}"] = "escalated"
                        elif any(w in tl for w in ["schedule", "consultation", "viewing", "appointment"]):
                            collected[f"_tool_{func_name}"] = "scheduled"
                        else:
                            collected[f"_tool_{func_name}"] = "completed"

            # Merge structured data if available in message, analysis or artifact
            structured_data = {}
            for source in [
                message.get("analysis", {}),
                message,
                artifact,
                data.get("analysis", {})
            ]:
                if isinstance(source, dict):
                    sdata = source.get("structuredData")
                    if isinstance(sdata, dict):
                        structured_data.update(sdata)

            if structured_data:
                logger.info(f"[VAPI_WEBHOOK] Found structured data from Vapi analysis: {structured_data}")
                collected.update(structured_data)

            # Determine lead status
            final_status = collected.get("lead_status") or _determine_lead_status(collected)
            collected["lead_status"] = final_status
            collected_fields = [k for k in collected.keys() if not k.startswith("_tool_")]

            # Duration and recording
            duration = message.get("durationSeconds") or call_obj.get("duration") or 0
            recording_url = (
                message.get("recordingUrl")
                or artifact.get("recordingUrl")
                or call_obj.get("recordingUrl")
                or ""
            )

            # Resolve assistant/business name
            assistant_name = call_obj.get("assistant", {}).get("name")
            if not assistant_name and assistant_id:
                try:
                    from app.vapi_client import get_assistant_from_vapi
                    asst = await get_assistant_from_vapi(assistant_id)
                    if asst:
                        assistant_name = asst.get("name")
                except Exception:
                    pass
            if not assistant_name:
                assistant_name = "Valued Business"

            summary_payload = {
                "call_id": call_id,
                "assistant_id": assistant_id,
                "business_name": assistant_name,
                "lead_status": final_status,
                "duration_seconds": int(duration) if duration else 0,
                "collected_fields": collected_fields,
                "collected_data": {k: v for k, v in collected.items() if not k.startswith("_tool_")},
                "recording_url": recording_url,
                "transcript": full_transcript
            }

            # Forward summary details to `/webhook/summary` locally
            try:
                await handle_summary(summary_payload)
            except Exception as e:
                logger.error(f"Failed to forward local summary webhook: {e}")

            return {
                "status": "completed",
                "lead_status": final_status,
                "duration_seconds": duration,
                "collected_fields": collected_fields
            }

        elif event_type in ("status-update", "call-ended"):
            status = message.get("status", "")
            logger.info(f"[VAPI_WEBHOOK] Status update for {call_id}: {status}")
            return {"status": "noted"}

        elif event_type == "assistant-request":
            logger.info(f"[VAPI_WEBHOOK] Handling assistant-request for {call_id}")
            # Vapi expects a valid assistant configuration or empty object for overrides
            return {"assistant": {}}

        else:
            return {"status": "ignored"}

    except json.JSONDecodeError:
        logger.error("[VAPI_WEBHOOK] Invalid JSON payload")
        raise HTTPException(status_code=400, detail="Invalid JSON")
    except Exception as exc:
        logger.error(f"[VAPI_WEBHOOK] Unhandled error: {exc}", exc_info=True)
        return {"status": "error", "message": str(exc)}


async def _post_to_backend(webhook_url: str, payload: dict):
    """Post payload asynchronously to external backend webhook."""
    try:
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.post(webhook_url, json=payload)
            logger.info(f"[BACKEND_POST] {webhook_url} → {resp.status_code}")
    except Exception as exc:
        logger.error(f"[BACKEND_POST] Failed to post to {webhook_url}: {exc}")