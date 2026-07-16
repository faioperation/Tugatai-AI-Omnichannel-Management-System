import json
import logging
from fastapi import APIRouter, File, UploadFile, Form, HTTPException
import httpx

from app.config import VAPI_BASE, BACKEND_URL
from app.vapi_client import (
    upload_file_to_vapi, create_query_tool, attach_tool_to_assistant,
    vapi_headers, delete_file_from_vapi, create_tools_for_business_type,
    get_assistant_from_vapi, patch_assistant_prompt
)
from app.file_utils import (
    extract_text_from_bytes, extract_product_file_text,
    validate_product_file, ALLOWED_PRODUCT_EXTENSIONS
)
from app.services.business_config import (
    get_business_type, build_system_prompt as build_biz_prompt,
    analyze_business_pdf_with_openai, MASTER_PROMPT_TEMPLATE,
    inject_product_catalog_into_prompt
)

router = APIRouter()
logger = logging.getLogger(__name__)


def get_llm_provider(model: str) -> str:
    """Map model name to Vapi LLM provider string."""
    m = model.lower()
    if m.startswith("gpt"):
        return "openai"
    elif m.startswith("gemini"):
        return "google"
    elif m.startswith("llama") or m.startswith("mixtral"):
        return "groq"
    elif m.startswith("claude"):
        return "anthropic"
    return "openai"


def get_clean_backend_url() -> str:
    """Return cleaned backend URL or empty string."""
    if BACKEND_URL:
        return BACKEND_URL.rstrip('/')
    return ""


@router.post("/api/agents/create")
async def create_agent(
    business_id: str = Form(...),
    rules_file: UploadFile = File(...),
    product_file: UploadFile = File(None)
):
    """
    Creates a Vapi assistant.
    Analyzes the uploaded business script (rules_file), generates prompt/persona/greeting,
    and automatically attaches tools according to business needs.

    Optionally accepts a product_file (XLSX/CSV/XLS) containing the business's
    product catalog or data sheet, which is injected into the agent's knowledge.
    """
    # ── Extract text from business script ────────────────────────────────────
    if not rules_file.filename:
        raise HTTPException(status_code=400, detail="rules_file is empty")

    content = await rules_file.read()
    extracted_text = extract_text_from_bytes(content, rules_file.filename)
    if not extracted_text:
        raise HTTPException(status_code=400, detail="Failed to extract text from rules_file")

    # Upload file to Vapi file store (needed for potential RAG search tool)
    vapi_file_id = None
    try:
        vapi_file_id = await upload_file_to_vapi(content, rules_file.filename)
    except Exception as exc:
        logger.error(f"Failed to upload business script to VAPI: {exc}")

    # ── Process product file (optional) ──────────────────────────────────────
    product_text = ""
    product_vapi_file_id = None

    if product_file and product_file.filename:
        product_content = await product_file.read()

        # Validate file type and size
        validation_error = validate_product_file(product_file.filename, len(product_content))
        if validation_error:
            raise HTTPException(status_code=400, detail=validation_error)

        # Extract structured text from the product file
        product_text = extract_product_file_text(product_content, product_file.filename)
        if not product_text:
            raise HTTPException(
                status_code=400,
                detail="Failed to extract data from product_file. Ensure it contains readable data."
            )

        # Upload product file to VAPI file store for RAG
        try:
            product_vapi_file_id = await upload_file_to_vapi(product_content, product_file.filename)
            logger.info(f"Uploaded product file '{product_file.filename}' to VAPI -> {product_vapi_file_id}")
        except Exception as exc:
            logger.error(f"Failed to upload product file to VAPI: {exc}")

    # ── Core Business Script Training Pipeline ────────────────────────────────
    # Call OpenAI to automatically analyze the business script and train the agent!
    try:
        analysis = await analyze_business_pdf_with_openai(extracted_text)
        logger.info(f"OpenAI script analysis result: {analysis}")
        
        # Use detected values
        detected_business_name = analysis.get("business_name") or business_id
        used_agent_name = analysis.get("agent_name") or "Assistant"
        used_business_type = analysis.get("business_type") or "generic"
        used_language = analysis.get("language") or "en"
        used_tools = analysis.get("tools") or ["collect_info", "escalate_to_human"]
        first_message = analysis.get("first_message") or f"Hello! Thank you for calling {detected_business_name}. How can I help you today?"
        dynamic_fields = analysis.get("extracted_data_fields") or {}
        
        # Construct a system prompt customized by AI using our MASTER_PROMPT_TEMPLATE
        custom_l2 = analysis.get("custom_layer2") or ""
        custom_l3 = analysis.get("custom_layer3") or ""
        
        prompt_content = MASTER_PROMPT_TEMPLATE.format(
            business_name=detected_business_name,
            business_type_label=get_business_type(used_business_type)["display_name"],
            layer2=custom_l2,
            layer3=custom_l3
        )
        
        # If the KB is small (< 10000 chars), inject it directly into the prompt.
        if len(extracted_text) <= 10000:
            placeholder = "[The business context and knowledge base content will be dynamically loaded and placed here. If this section is empty, rely on your knowledge base search tool.]"
            kb_section = f"# KNOWLEDGE BASE — {detected_business_name.upper()}\n\n{extracted_text}"
            used_prompt = prompt_content.replace(placeholder, kb_section)
        else:
            used_prompt = prompt_content

        # Inject product catalog into the prompt if provided
        if product_text:
            used_prompt = inject_product_catalog_into_prompt(used_prompt, product_text)

    except Exception as exc:
        logger.error(f"OpenAI script analysis failed: {exc}", exc_info=True)
        # Fallback to standard generic templates
        used_prompt = build_biz_prompt(
            business_type="generic",
            business_name=business_id,
            agent_name="Assistant",
            kb_text=extracted_text if len(extracted_text) <= 10000 else "",
            product_text=product_text
        )
        used_business_type = "generic"
        used_language = "en"
        used_tools = ["collect_info", "escalate_to_human"]
        first_message = f"Hello! Thank you for calling {business_id}. How can I help you today?"
        dynamic_fields = {}

    # ── Determine if query tool is needed ─────────────────────────────────────
    use_query_tool = bool(vapi_file_id and len(extracted_text) > 10000)
    use_product_query_tool = bool(product_vapi_file_id and product_text and len(product_text) > 10000)

    clean_backend_url = get_clean_backend_url()
    model = "gpt-4o"  # Default high-performance model
    llm_provider = get_llm_provider(model)

    transcriber_config = {
        "provider": "deepgram",
        "model": "nova-3",
        "language": used_language
    }

    voice_config = {
        "provider": "11labs",
        "model": "eleven_flash_v2",
        "voiceId": "21m00Tcm4TlvDq8ikWAM"  # Rachel (default voice)
    }

    # Build schema properties dynamically
    schema_properties = {
        "lead_status": {"type": "string", "description": "The status of the lead, e.g., scheduled, ordered, escalated, abandoned."},
        "call_summary": {"type": "string", "description": "A brief 1-2 sentence summary of what the customer wanted and the outcome."},
        "customer_name": {"type": "string", "description": "The full name of the customer."},
        "customer_phone": {"type": "string", "description": "The phone number of the customer."},
        "booking_confirmation": {"type": "boolean", "description": "True if a booking, order, or service was successfully confirmed during the call, otherwise False."}
    }
    
    # Conditionally add package details for cargo/delivery agents
    if used_business_type == "cargo":
        schema_properties["package_name"] = {"type": "string", "description": "The name or description of the package to be delivered."}
        schema_properties["package_type"] = {"type": "string", "description": "The type or category of the package."}
        schema_properties["weight_kg"] = {"type": "number", "description": "The estimated weight of the package in kilograms."}
        schema_properties["pickup_time"] = {"type": "string", "description": "The customer's requested pickup time for the parcel. It must be in a time format (e.g. HH:MM AM/PM like '02:30 PM' or '14:30')."}
    
    if isinstance(dynamic_fields, dict):
        for field_name, field_desc in dynamic_fields.items():
            if field_name not in schema_properties:
                schema_properties[field_name] = {"type": "string", "description": str(field_desc)}

    assistant_payload = {
        "name": business_id,
        "transcriber": transcriber_config,
        "model": {
            "provider": llm_provider,
            "model": model,
            "messages": [{"role": "system", "content": used_prompt}],
            "temperature": 0.4
        },
        "voice": voice_config,
        "recordingEnabled": True,
        "firstMessage": first_message,
        "endCallMessage": "Thank you for calling. Have a wonderful day!",
        "silenceTimeoutSeconds": 30,
        "maxDurationSeconds": 620,
        "backchannelingEnabled": False,
        "backgroundDenoisingEnabled": True,
        "startSpeakingPlan": {
            "waitSeconds": 0.1,
            "smartEndpointingEnabled": True,
            "smartEndpointingPlan": {"provider": "vapi"},
            "transcriptionEndpointingPlan": {
                "onNumberSeconds": 0.2,
                "onPunctuationSeconds": 0.1,
                "onNoPunctuationSeconds": 0.3
            }
        },
        "stopSpeakingPlan": {
            "numWords": 0,
            "voiceSeconds": 0.3,
            "backoffSeconds": 0.6
        },
        "analysisPlan": {
            "structuredDataPlan": {
                "schema": {
                    "type": "object",
                    "properties": schema_properties
                }
            }
        }
    }

    # If backend URL is set, direct VAPI events to our webhook/vapi handler.
    # We will compute the service URL from our server's config.
    from app.config import SERVICE_URL
    if SERVICE_URL:
        target_webhook = f"{SERVICE_URL.rstrip('/')}/api/webhook/vapi"
        assistant_payload["serverUrl"] = target_webhook
        assistant_payload["server"] = {
            "url": target_webhook,
            "timeoutSeconds": 20
        }

    # ── Create Assistant in VAPI ──────────────────────────────────────────────
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(f"{VAPI_BASE}/assistant", json=assistant_payload, headers=vapi_headers())

    if resp.status_code not in (200, 201):
        error_detail = resp.text
        logger.error(f"VAPI Assistant Creation Failed ({resp.status_code}): {error_detail}")
        raise HTTPException(resp.status_code, f"Vapi Error: {error_detail}")

    vapi_data = resp.json()
    assistant_id = vapi_data["id"]
    current_model = vapi_data.get("model", {})

    # ── Attach tools ──────────────────────────────────────────────────────────
    try:
        # Create and attach query tool if rules document is large
        if vapi_file_id and use_query_tool:
            biz_config = get_business_type(used_business_type)
            query_tool_id = await create_query_tool(
                file_ids=[vapi_file_id],
                kb_name=biz_config.get("kb_name", "business-kb"),
                kb_description=biz_config.get("kb_description", "Business knowledge base.")
            )
            await attach_tool_to_assistant(assistant_id, query_tool_id, current_model)
            # Re-fetch current model structure
            assistant_info = await get_assistant_from_vapi(assistant_id)
            if assistant_info:
                current_model = assistant_info.get("model", current_model)

        # Create and attach query tool if product catalog is large
        if product_vapi_file_id and use_product_query_tool:
            product_query_tool_id = await create_query_tool(
                file_ids=[product_vapi_file_id],
                kb_name="product-catalog-kb",
                kb_description="Product catalog, inventory, pricing, and item details."
            )
            await attach_tool_to_assistant(assistant_id, product_query_tool_id, current_model)
            assistant_info = await get_assistant_from_vapi(assistant_id)
            if assistant_info:
                current_model = assistant_info.get("model", current_model)

        # Create/attach business tools (booking, quote, human-escalation, etc.) targeting fallback webhook
        tool_ids = await create_tools_for_business_type(used_tools, SERVICE_URL or clean_backend_url)
        for t_id in tool_ids:
            try:
                await attach_tool_to_assistant(assistant_id, t_id, current_model)
                assistant_info = await get_assistant_from_vapi(assistant_id)
                if assistant_info:
                    current_model = assistant_info.get("model", current_model)
            except Exception as e:
                logger.warning(f"Failed to attach tool {t_id}: {e}")

    except Exception as exc:
        logger.warning(f"Error attaching tools (non-fatal): {exc}")

    return {
        "assistant_id": assistant_id,
        "business_id": business_id,
        "product_file_id": product_vapi_file_id
    }


@router.put("/api/agents/{assistant_id}/product-file")
async def update_product_file(
    assistant_id: str,
    product_file: UploadFile = File(...)
):
    """
    Update or replace the product file for an existing VAPI assistant.

    This endpoint:
    1. Validates the uploaded file (XLSX/CSV/XLS, max 10MB)
    2. Extracts structured text from the product file
    3. Fetches the existing assistant's system prompt from VAPI
    4. Injects/replaces the product catalog section in the prompt
    5. Uploads the new file to VAPI's file store for RAG
    6. Patches the assistant with the updated prompt
    7. If the product data is large (>10k chars), creates a RAG query tool

    Returns the updated assistant info and new product file ID.
    """
    if not product_file.filename:
        raise HTTPException(status_code=400, detail="product_file is empty")

    product_content = await product_file.read()

    # Validate file type and size
    validation_error = validate_product_file(product_file.filename, len(product_content))
    if validation_error:
        raise HTTPException(status_code=400, detail=validation_error)

    # Extract structured text
    product_text = extract_product_file_text(product_content, product_file.filename)
    if not product_text:
        raise HTTPException(
            status_code=400,
            detail="Failed to extract data from product_file. Ensure it contains readable data."
        )

    # ── Fetch existing assistant ─────────────────────────────────────────────
    assistant = await get_assistant_from_vapi(assistant_id)
    if not assistant:
        raise HTTPException(status_code=404, detail=f"Assistant {assistant_id} not found in VAPI")

    # ── Extract current system prompt ────────────────────────────────────────
    current_model = assistant.get("model", {})
    messages = current_model.get("messages", [])
    current_prompt = ""
    for msg in messages:
        if msg.get("role") == "system":
            current_prompt = msg.get("content", "")
            break

    if not current_prompt:
        raise HTTPException(
            status_code=400,
            detail="Assistant has no system prompt. Cannot inject product data."
        )

    # ── Inject/replace product catalog in prompt ─────────────────────────────
    updated_prompt = inject_product_catalog_into_prompt(current_prompt, product_text)

    # ── Upload new product file to VAPI ──────────────────────────────────────
    product_vapi_file_id = None
    try:
        product_vapi_file_id = await upload_file_to_vapi(product_content, product_file.filename)
        logger.info(f"Uploaded new product file '{product_file.filename}' to VAPI -> {product_vapi_file_id}")
    except Exception as exc:
        logger.error(f"Failed to upload product file to VAPI: {exc}")

    # ── Patch the assistant's system prompt ───────────────────────────────────
    try:
        await patch_assistant_prompt(assistant_id, updated_prompt)
    except Exception as exc:
        logger.error(f"Failed to patch assistant prompt: {exc}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update assistant prompt: {exc}"
        )

    # ── If product data is large, create/attach a RAG query tool ─────────────
    if product_vapi_file_id and len(product_text) > 10000:
        try:
            product_query_tool_id = await create_query_tool(
                file_ids=[product_vapi_file_id],
                kb_name="product-catalog-kb",
                kb_description="Product catalog, inventory, pricing, and item details."
            )
            # Re-fetch assistant to get latest model state
            refreshed = await get_assistant_from_vapi(assistant_id)
            if refreshed:
                await attach_tool_to_assistant(
                    assistant_id, product_query_tool_id,
                    refreshed.get("model", {})
                )
                logger.info(f"Attached product RAG query tool {product_query_tool_id} to assistant {assistant_id}")
        except Exception as exc:
            logger.warning(f"Failed to create/attach product RAG tool (non-fatal): {exc}")

    return {
        "status": "success",
        "assistant_id": assistant_id,
        "product_file_id": product_vapi_file_id,
        "message": "Product file updated successfully."
    }
