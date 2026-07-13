"""
VAPI Client — all VAPI API helpers in one place.

Covers:
  - Auth headers
  - File upload / delete
  - Tool creation (webhook tools + RAG query tool)
  - Tool attachment to assistant
  - Assistant CRUD helpers
"""
import logging
import httpx
from .config import VAPI_API_KEY, VAPI_BASE

logger = logging.getLogger(__name__)


# Auth

def vapi_headers() -> dict:
    """Standard VAPI auth headers."""
    return {
        "Authorization": f"Bearer {VAPI_API_KEY}",
        "Content-Type": "application/json",
    }


# File Management

async def upload_file_to_vapi(content: bytes, filename: str) -> str:
    """
    Upload a file (PDF/TXT/CSV) to VAPI's file store for RAG.
    Returns the VAPI file ID.
    """
    headers = {"Authorization": f"Bearer {VAPI_API_KEY}"}
    files = {"file": (filename, content, _mime_type(filename))}

    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(f"{VAPI_BASE}/file", headers=headers, files=files)

    if resp.status_code not in (200, 201):
        raise RuntimeError(f"VAPI file upload failed ({resp.status_code}): {resp.text}")

    file_id = resp.json().get("id")
    logger.info(f"[VAPI] Uploaded file '{filename}' → {file_id}")
    return file_id


async def delete_file_from_vapi(file_id: str) -> None:
    """Delete a file from VAPI's file store."""
    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.delete(f"{VAPI_BASE}/file/{file_id}", headers=vapi_headers())

    if resp.status_code not in (200, 204):
        logger.warning(f"[VAPI] Could not delete file {file_id}: {resp.status_code} {resp.text}")
    else:
        logger.info(f"[VAPI] Deleted file {file_id}")


def _mime_type(filename: str) -> str:
    ext = filename.lower().rsplit(".", 1)[-1]
    return {
        "pdf": "application/pdf",
        "txt": "text/plain",
        "csv": "text/csv",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "xls": "application/vnd.ms-excel",
    }.get(ext, "application/octet-stream")


# Tool Creation


async def create_query_tool(file_ids: list[str], kb_name: str, kb_description: str) -> str:
    """
    Create a VAPI knowledge-base RAG query tool for large KB files.
    Returns the tool ID.
    """
    payload = {
        "type": "query",
        "knowledgeBases": [{
            "provider": "google",
            "name": kb_name,
            "description": kb_description,
            "fileIds": file_ids,
        }],
        "function": {
            "name": "knowledge_search",
            "description": f"Search the {kb_name} knowledge base for relevant information.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "The search query."}
                },
                "required": ["query"]
            }
        }
    }

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(f"{VAPI_BASE}/tool", json=payload, headers=vapi_headers())

    if resp.status_code not in (200, 201):
        raise RuntimeError(f"VAPI query tool creation failed ({resp.status_code}): {resp.text}")

    tool_id = resp.json().get("id")
    logger.info(f"[VAPI] Created query tool '{kb_name}' → {tool_id}")
    return tool_id


async def create_webhook_tool(
    tool_name: str,
    description: str,
    parameters: dict,
    backend_url: str,
) -> str:
    """
    Create a VAPI webhook function tool.
    When the AI calls this tool, VAPI POSTs to backend_url/api/webhook/vapi.
    Returns the tool ID.
    """
    service_url = backend_url.rstrip("/")

    # Check if a tool with this name already exists; reuse it if so
    existing_id = await _find_existing_tool(tool_name)
    if existing_id:
        # Patch the webhook URL to ensure it's current
        async with httpx.AsyncClient(timeout=20) as client:
            await client.patch(
                f"{VAPI_BASE}/tool/{existing_id}",
                json={"server": {"url": f"{service_url}/api/webhook/vapi", "timeoutSeconds": 20}},
                headers=vapi_headers()
            )
        logger.info(f"[VAPI] Reusing existing tool '{tool_name}' → {existing_id}")
        return existing_id

    payload = {
        "type": "function",
        "function": {
            "name": tool_name,
            "description": description,
            "parameters": parameters,
        },
        "server": {
            "url": f"{service_url}/api/webhook/vapi",
            "timeoutSeconds": 20,
        }
    }

    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.post(f"{VAPI_BASE}/tool", json=payload, headers=vapi_headers())

    if resp.status_code not in (200, 201):
        raise RuntimeError(f"VAPI tool creation failed ({resp.status_code}): {resp.text}")

    tool_id = resp.json().get("id")
    logger.info(f"[VAPI] Created webhook tool '{tool_name}' → {tool_id}")
    return tool_id


async def _find_existing_tool(tool_name: str) -> str | None:
    """Look up a VAPI tool by function name. Returns tool ID or None."""
    try:
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(f"{VAPI_BASE}/tool", headers=vapi_headers())
        if resp.status_code == 200:
            for t in resp.json():
                if t.get("function", {}).get("name") == tool_name:
                    return t["id"]
    except Exception as e:
        logger.warning(f"[VAPI] Could not check existing tools: {e}")
    return None


# Tool Parameter Definitions (used when building business-specific tools)

def _tool_params(tool_name: str) -> tuple[str, dict]:
    """
    Return (description, parameters) for a given tool name.
    These are the schemas the AI uses when deciding which arguments to pass.
    """
    n = tool_name.lower()

    if any(w in n for w in ["booking", "book", "reserve", "reservation", "order", "purchase",
                              "enroll", "consultation", "schedule", "appointment", "viewing", "process"]):
        return (
            "Confirm a booking, order, appointment, enrollment, or service request.",
            {
                "type": "object",
                "properties": {
                    "customer_name":  {"type": "string", "description": "Customer full name."},
                    "customer_phone": {"type": "string", "description": "Customer contact phone number."},
                    "details":        {"type": "string", "description": "What is being booked or ordered."},
                    "address":        {"type": "string", "description": "Delivery, pickup, or meeting address."},
                    "datetime":       {"type": "string", "description": "Preferred date and time."},
                    "package_name":   {"type": "string", "description": "The name or description of the package (if applicable)."},
                    "package_type":   {"type": "string", "description": "The type or category of the package (if applicable)."},
                    "weight_kg":      {"type": "number", "description": "The estimated weight of the package in kilograms (if applicable)."},
                },
                "required": ["customer_name", "customer_phone"],
            }
        )

    if any(w in n for w in ["escalate", "transfer", "human", "agent", "manager",
                              "attorney", "advisor", "specialist", "supervisor"]):
        return (
            "Escalate the call to a human specialist or agent.",
            {
                "type": "object",
                "properties": {
                    "reason":  {"type": "string", "description": "Reason for escalation."},
                    "urgency": {"type": "string", "enum": ["low", "medium", "high"],
                                "description": "Urgency level of the escalation."},
                },
                "required": ["reason"],
            }
        )

    if any(w in n for w in ["menu", "listing", "catalog", "info", "information", "details"]):
        return (
            "Retrieve information, menu items, listings, or catalog details.",
            {
                "type": "object",
                "properties": {
                    "category": {"type": "string", "description": "Category or topic to retrieve."},
                },
                "required": [],
            }
        )

    # Generic fallback
    return (
        f"Execute the '{tool_name}' action for the customer.",
        {
            "type": "object",
            "properties": {
                "customer_name":  {"type": "string", "description": "Customer name."},
                "customer_phone": {"type": "string", "description": "Customer phone number."},
                "notes":          {"type": "string", "description": "Additional details or context."},
            },
            "required": [],
        }
    )


async def create_tools_for_business_type(tools: list[str], backend_url: str) -> list[str]:
    """
    Create VAPI webhook tools for all tools the business needs.
    Returns list of tool IDs to attach to the assistant.
    """
    tool_ids = []
    for tool_name in tools:
        try:
            description, parameters = _tool_params(tool_name)
            tool_id = await create_webhook_tool(tool_name, description, parameters, backend_url)
            tool_ids.append(tool_id)
        except Exception as e:
            logger.error(f"[VAPI] Failed to create tool '{tool_name}': {e}")
    return tool_ids


async def attach_tool_to_assistant(assistant_id: str, tool_id: str, current_model: dict) -> None:
    """Attach a tool to an existing VAPI assistant by adding its ID to the model's toolIds."""
    existing_ids = current_model.get("toolIds") or []
    if tool_id in existing_ids:
        return  # already attached

    updated_ids = existing_ids + [tool_id]
    patch = {
        "model": {
            **current_model,
            "toolIds": updated_ids,
        }
    }

    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.patch(
            f"{VAPI_BASE}/assistant/{assistant_id}",
            json=patch,
            headers=vapi_headers()
        )

    if resp.status_code not in (200, 201, 204):
        raise RuntimeError(f"Failed to attach tool {tool_id} to assistant {assistant_id}: {resp.text}")

    logger.info(f"[VAPI] Attached tool {tool_id} to assistant {assistant_id}")


# Assistant Helpers

async def get_assistant_from_vapi(assistant_id: str) -> dict | None:
    """Fetch a single assistant from VAPI. Returns None if not found."""
    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.get(f"{VAPI_BASE}/assistant/{assistant_id}", headers=vapi_headers())

    if resp.status_code == 404:
        return None
    if resp.status_code != 200:
        raise RuntimeError(f"VAPI get assistant failed ({resp.status_code}): {resp.text}")

    return resp.json()


async def patch_assistant_prompt(assistant_id: str, new_prompt: str) -> dict:
    """
    Update only the system prompt of an existing VAPI assistant.
    Preserves all other model settings (provider, model, temperature, toolIds, etc.).
    Returns the updated assistant data.
    """
    # Fetch current assistant to preserve existing model config
    assistant = await get_assistant_from_vapi(assistant_id)
    if not assistant:
        raise RuntimeError(f"Assistant {assistant_id} not found in VAPI.")

    current_model = assistant.get("model", {})

    # Replace only the system message content
    messages = current_model.get("messages", [])
    updated_messages = []
    system_found = False
    for msg in messages:
        if msg.get("role") == "system" and not system_found:
            updated_messages.append({"role": "system", "content": new_prompt})
            system_found = True
        else:
            updated_messages.append(msg)

    if not system_found:
        updated_messages.insert(0, {"role": "system", "content": new_prompt})

    patch = {
        "model": {
            **current_model,
            "messages": updated_messages,
        }
    }

    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.patch(
            f"{VAPI_BASE}/assistant/{assistant_id}",
            json=patch,
            headers=vapi_headers()
        )

    if resp.status_code not in (200, 201, 204):
        raise RuntimeError(
            f"Failed to patch assistant {assistant_id} prompt ({resp.status_code}): {resp.text}"
        )

    logger.info(f"[VAPI] Patched system prompt for assistant {assistant_id}")
    return resp.json()


async def list_assistants_from_vapi() -> list[dict]:
    """List all assistants from VAPI."""
    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.get(f"{VAPI_BASE}/assistant", headers=vapi_headers())

    if resp.status_code != 200:
        raise RuntimeError(f"VAPI list assistants failed ({resp.status_code}): {resp.text}")

    return resp.json()

# Telephony & Transfer Helpers

async def import_twilio_number(
    twilio_sid: str,
    twilio_auth_token: str,
    twilio_number: str,
    assistant_id: str
) -> dict:
    """
    Imports a Twilio number into Vapi and binds it to an assistant.
    If it already exists, it finds it and patches it.
    """
    payload = {
        "provider": "twilio",
        "number": twilio_number,
        "twilioAccountSid": twilio_sid,
        "twilioAuthToken": twilio_auth_token,
        "assistantId": assistant_id
    }

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(f"{VAPI_BASE}/phone-number", json=payload, headers=vapi_headers())

        if resp.status_code == 400 and "Existing Phone Number" in resp.text:
            logger.info(f"[VAPI] Twilio number {twilio_number} already exists. Fetching to update...")
            get_resp = await client.get(f"{VAPI_BASE}/phone-number", headers=vapi_headers())
            if get_resp.status_code == 200:
                phone_numbers = get_resp.json()
                existing_id = None
                for phone in phone_numbers:
                    if phone.get("number") == twilio_number:
                        existing_id = phone.get("id")
                        break
                
                if existing_id:
                    logger.info(f"[VAPI] Found existing phone ID {existing_id}. Patching with new assistant...")
                    patch_payload = {"assistantId": assistant_id}
                    patch_resp = await client.patch(f"{VAPI_BASE}/phone-number/{existing_id}", json=patch_payload, headers=vapi_headers())
                    if patch_resp.status_code in (200, 201, 204):
                        return patch_resp.json()
                    else:
                        raise RuntimeError(f"Failed to patch existing Twilio number ({patch_resp.status_code}): {patch_resp.text}")
                else:
                    raise RuntimeError(f"Twilio number {twilio_number} reported existing but couldn't be found.")
            else:
                raise RuntimeError(f"Failed to fetch existing phone numbers ({get_resp.status_code}): {get_resp.text}")

        if resp.status_code not in (200, 201):
            raise RuntimeError(f"Failed to import Twilio number ({resp.status_code}): {resp.text}")

        result = resp.json()
        logger.info(f"[VAPI] Imported Twilio number {twilio_number} -> {result.get('id')} for assistant {assistant_id}")
        return result

#async def attach_transfer_tool(assistant_id: str, transfer_number: str) -> str:
async def attach_transfer_tool(assistant_id: str, transfer_number: str, twilio_number: str = None) -> str:
    """
    Creates a native Vapi transferCall tool pointing to the transfer_number
    and attaches it to the given assistant.
    """
    # 1. Create the transferCall tool
#    payload = {
#        "type": "transferCall",
#        "destinations": [
#            {
    destination_config = {
        "type": "number",
        "number": transfer_number,
        "message": "Transferring your call now. Please hold."
    }
    
    # By explicitly setting the callerId to the Twilio number, we prevent 
    # international telecom carriers from rejecting the call as 'Caller ID Spoofing'
    # when Vapi defaults to passing the customer's phone number as the From number.
    if twilio_number:
        destination_config["callerId"] = twilio_number

    payload = {
        "type": "transferCall",
        "destinations": [destination_config],
        "function": {
            "name": "escalate_to_human",
            "description": "Transfer the call to a human specialist, agent, manager, or supervisor.",
            "parameters": {
                "type": "object",
                "properties": {
                    "reason": {"type": "string", "description": "Reason for escalation."}
                },
                "required": ["reason"]
            }
        }
    }

    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.post(f"{VAPI_BASE}/tool", json=payload, headers=vapi_headers())

    if resp.status_code not in (200, 201):
        raise RuntimeError(f"Failed to create transfer tool ({resp.status_code}): {resp.text}")

    tool_id = resp.json().get("id")
    logger.info(f"[VAPI] Created transferCall tool -> {tool_id} targeting {transfer_number}")

    # 2. Fetch all tools to find old transfer tools
    async with httpx.AsyncClient(timeout=20) as client:
        tools_resp = await client.get(f"{VAPI_BASE}/tool", headers=vapi_headers())
        all_tools = tools_resp.json() if tools_resp.status_code == 200 else []
    
    # We want to remove any tools of type 'transferCall' or named 'escalate_to_human'
    tools_to_remove = set()
    for t in all_tools:
        if t.get("type") == "transferCall" or t.get("function", {}).get("name") == "escalate_to_human":
            tools_to_remove.add(t.get("id"))

    # 3. Attach the new tool to the assistant and remove old ones (prevent duplicates)
    assistant = await get_assistant_from_vapi(assistant_id)
    if not assistant:
        raise RuntimeError(f"Assistant {assistant_id} not found.")

    current_model = assistant.get("model", {})
    current_tool_ids = current_model.get("toolIds", [])
    
    # Remove old tools
    new_tool_ids = [tid for tid in current_tool_ids if tid not in tools_to_remove]
    
    # Add our newly created tool
    new_tool_ids.append(tool_id)
    current_model["toolIds"] = new_tool_ids
    
    # 4. Patch the assistant with the cleaned up list
    async with httpx.AsyncClient(timeout=15) as client:
        patch_resp = await client.patch(
            f"{VAPI_BASE}/assistant/{assistant_id}", 
            json={"model": current_model}, 
            headers=vapi_headers()
        )
        if patch_resp.status_code not in (200, 201):
            raise RuntimeError(f"Failed to update assistant tools ({patch_resp.status_code}): {patch_resp.text}")

    return tool_id
