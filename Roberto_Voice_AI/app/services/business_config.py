"""
Business Type Configuration Registry
=====================================
Defines all supported business types for the Roberto AI Voice Agent platform.
Each business type specifies:
  - Display name & icon
  - Vapi tools to create and attach
  - System prompt template (Layer 2 & 3 of the master prompt)
  - Webhook action handlers
  - Labels used in the dashboard UI

To add a new business type:
  1. Add an entry to BUSINESS_TYPES below
  2. (Optionally) add a tool definition in vapi_client.py
  3. (Optionally) add a webhook handler in routes/calls.py
"""

from typing import Dict, Any

# Business Type Definitions

BUSINESS_TYPES: Dict[str, Dict[str, Any]] = {

    "cargo": {
        "display_name": "Cargo & Logistics",
        "icon": "🚢",
        "description": "Freight forwarding, shipping quotes, and booking confirmations.",
#        "tools": ["get_quote", "confirm_booking", "escalate_to_human"],
        "tools": ["confirm_booking", "escalate_to_human"],
        "kb_name": "cargo-kb",
        "kb_description": "Shipping routes, pricing rules, customs fees, and cargo handling guidelines.",
        "transaction_label": "Bookings",
        "lead_label": "Shipments",
        "prompt_layer2": """
- **Identity**: You are a professional cargo logistics agent representing {business_name}. Your name is {agent_name}.
- **Tone**: Warm, concise, WhatsApp-style replies. 1-2 sentences maximum.
- **Currency**: Always quote prices in QAR (Qatari Riyal) unless the client specifies otherwise.
""",
        "prompt_layer3": """
### 1. SHIPPING QUOTE:
- Collect: destination, item list, estimated weight (kg), package name, package type, and preferred mode (sea/air/DHL).
- Search your knowledge base or product catalog to calculate the exact pricing. Read back the exact result. Do not guess.

### 2. BOOKING CONFIRMATION:
- Once customer agrees to quote: collect name, phone, pickup location, and preferred pickup time. You MUST ask the customer for their preferred pickup time. It MUST be in a specific time-wise format (e.g. HH:MM AM/PM like '02:30 PM' or '14:30'). Collecting the pickup time in a time-wise format is mandatory.
- Trigger `confirm_booking` to finalize. Read back the booking reference clearly.

### 3. ESCALATION:
- If customer mentions restricted/hazardous items (lithium, explosives, radioactive), escalate immediately.
- If customer is angry or the request is too complex, trigger `escalate_to_human`.
""",
    },

    "restaurant": {
        "display_name": "Restaurant & Food",
        "icon": "🍽️",
        "description": "Table reservations, menu queries, and order placement.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "restaurant-kb",
        "kb_description": "Menu items, prices, allergens, opening hours, and reservation policies.",
        "transaction_label": "Orders",
        "lead_label": "Reservations",
        "prompt_layer2": """
- **Identity**: You are a friendly front-desk assistant for {business_name}. Your name is {agent_name}.
- **Tone**: Warm, welcoming, and efficient. Keep replies brief and conversational.
""",
        "prompt_layer3": """
### 1. MENU QUERIES:
- Always search the knowledge base before quoting any menu item or price.
- Clearly state item names, sizes, and prices from the KB only.

### 2. RESERVATIONS:
- Collect: party size, preferred date and time, customer name, and phone number.
- Confirm availability based on your KB and use `collect_info` to save the reservation.

### 3. ESCALATION:
- If customer has complex dietary needs, complaints, or requests you cannot fulfill, trigger `escalate_to_human`.
""",
    },

    "legal": {
        "display_name": "Law & Legal Services",
        "icon": "⚖️",
        "description": "Legal consultation scheduling, case intake, and information requests.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "legal-kb",
        "kb_description": "Practice areas, fee schedules, consultation availability, and firm policies.",
        "transaction_label": "Consultations",
        "lead_label": "Case Inquiries",
        "prompt_layer2": """
- **Identity**: You are a professional legal receptionist for {business_name}. Your name is {agent_name}.
- **Tone**: Professional, empathetic, and precise. Never give legal advice — only schedule and gather intake information.
""",
        "prompt_layer3": """
### 1. CONSULTATION BOOKING:
- Collect: caller's name, contact number, brief description of legal matter, and preferred consultation time.
- Use `collect_info` to save the intake details for the attorney's review.

### 2. INFORMATION REQUESTS:
- Only reference information available in your knowledge base (practice areas, fees, office hours).
- NEVER provide legal advice, interpretations, or case outcomes.

### 3. ESCALATION:
- If the caller has an urgent legal emergency, is in distress, or requests to speak directly with an attorney, trigger `escalate_to_human` immediately.
""",
    },

    "education": {
        "display_name": "Education & Training",
        "icon": "🎓",
        "description": "Course enrollment, schedule queries, and student support.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "education-kb",
        "kb_description": "Courses, schedules, fees, enrollment procedures, and instructor information.",
        "transaction_label": "Enrollments",
        "lead_label": "Student Leads",
        "prompt_layer2": """
- **Identity**: You are a helpful enrollment advisor for {business_name}. Your name is {agent_name}.
- **Tone**: Encouraging, clear, and student-focused. Be patient and thorough.
""",
        "prompt_layer3": """
### 1. COURSE INFORMATION:
- Always reference your knowledge base for course names, schedules, fees, and prerequisites.
- Guide the caller through available programs based on their stated goals.

### 2. ENROLLMENT:
- Collect: student name, contact info, course of interest, and preferred start date.
- Use `collect_info` to save enrollment interest for the admissions team.

### 3. ESCALATION:
- If the caller has complex academic history questions, financial aid queries, or requests a human advisor, trigger `escalate_to_human`.
""",
    },

    "real_estate": {
        "display_name": "Real Estate",
        "icon": "🏠",
        "description": "Property listings, viewing appointments, and buyer/seller inquiries.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "realestate-kb",
        "kb_description": "Property listings, pricing, neighborhood info, agent availability, and viewing schedules.",
        "transaction_label": "Viewings",
        "lead_label": "Property Leads",
        "prompt_layer2": """
- **Identity**: You are a professional property consultant for {business_name}. Your name is {agent_name}.
- **Tone**: Confident, helpful, and informative. Paint a picture but always stay factual.
""",
        "prompt_layer3": """
### 1. PROPERTY QUERIES:
- Reference your knowledge base for available listings, prices, and amenities.
- Never speculate on future prices or investment returns.

### 2. VIEWING APPOINTMENTS:
- Collect: buyer/renter name, contact number, property of interest, and preferred viewing time.
- Use `collect_info` to log the appointment request for an agent to confirm.

### 3. ESCALATION:
- If the caller wants to make an offer, discuss contracts, or negotiate, transfer to a licensed agent via `escalate_to_human`.
""",
    },

    "healthcare": {
        "display_name": "Healthcare & Clinic",
        "icon": "🏥",
        "description": "Appointment booking, service information, and patient support.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "healthcare-kb",
        "kb_description": "Services offered, doctor availability, appointment procedures, insurance, and clinic hours.",
        "transaction_label": "Appointments",
        "lead_label": "Patient Inquiries",
        "prompt_layer2": """
- **Identity**: You are a compassionate patient coordinator for {business_name}. Your name is {agent_name}.
- **Tone**: Empathetic, calm, and professional. Patient care is always the priority.
""",
        "prompt_layer3": """
### 1. APPOINTMENT BOOKING:
- Collect: patient name, date of birth, contact number, reason for visit, and preferred date/time.
- Use `collect_info` to save appointment requests.

### 2. SERVICE QUERIES:
- Only reference services, doctors, and procedures listed in your knowledge base.
- NEVER provide medical diagnoses, advice, or medication recommendations.

### 3. ESCALATION:
- If caller describes a medical emergency, trigger `escalate_to_human` immediately.
- For urgent care requests or complex insurance questions, transfer to staff.
""",
    },

    "generic": {
        "display_name": "General Business",
        "icon": "🏢",
        "description": "Universal template suitable for any business type.",
        "tools": ["collect_info", "escalate_to_human"],
        "kb_name": "business-kb",
        "kb_description": "Business information, services, pricing, and frequently asked questions.",
        "transaction_label": "Leads",
        "lead_label": "Inquiries",
        "prompt_layer2": """
- **Identity**: You are a professional front-desk assistant for {business_name}. Your name is {agent_name}.
- **Tone**: Friendly, professional, and efficient. Adapt to the caller's needs.
""",
        "prompt_layer3": """
### 1. INFORMATION REQUESTS:
- Answer questions based strictly on your knowledge base content.
- If you don't have the answer, say so honestly and offer to have someone follow up.

### 2. LEAD CAPTURE:
- Collect caller name, contact number, and the nature of their inquiry.
- Use `collect_info` to save the lead for follow-up.

### 3. ESCALATION:
- For urgent requests, complaints, or questions beyond your knowledge base, trigger `escalate_to_human`.
""",
    },
}


# Product Catalog Prompt Constants

PRODUCT_CATALOG_START_MARKER = (
    "# ============================================================\n"
    "# PRODUCT CATALOG / DATA SHEET\n"
    "# ============================================================"
)
PRODUCT_CATALOG_END_MARKER = "# ============ END PRODUCT CATALOG ============"

PRODUCT_CATALOG_SECTION_TEMPLATE = """{start_marker}
Use the following product/data catalog when customers ask about products, prices, availability, items, or any specifics.
Always reference this data accurately. Never invent products or prices not listed here.

{product_data}

{end_marker}"""


def build_product_catalog_section(product_text: str) -> str:
    """Build the product catalog section string for prompt injection."""
    return PRODUCT_CATALOG_SECTION_TEMPLATE.format(
        start_marker=PRODUCT_CATALOG_START_MARKER,
        product_data=product_text,
        end_marker=PRODUCT_CATALOG_END_MARKER,
    )


def inject_product_catalog_into_prompt(prompt: str, product_text: str) -> str:
    """
    Inject or replace the product catalog section in an existing prompt.
    If a product catalog section already exists, it is replaced.
    Otherwise, the section is appended at the end of the prompt.
    """
    catalog_section = build_product_catalog_section(product_text)

    # Check if there's an existing product catalog section to replace
    if PRODUCT_CATALOG_START_MARKER in prompt:
        start_idx = prompt.index(PRODUCT_CATALOG_START_MARKER)
        if PRODUCT_CATALOG_END_MARKER in prompt:
            end_idx = prompt.index(PRODUCT_CATALOG_END_MARKER) + len(PRODUCT_CATALOG_END_MARKER)
            return prompt[:start_idx] + catalog_section + prompt[end_idx:]
        else:
            # Start marker exists but no end — replace from start marker to end
            return prompt[:start_idx] + catalog_section

    # No existing section — append after the prompt
    return prompt.rstrip() + "\n\n" + catalog_section


# Master System Prompt Template
# Layers 1 and 4 are fixed; Layers 2 & 3 are injected per business type.

MASTER_PROMPT_TEMPLATE = """# ============================================================
# ROBERTO AI — UNIVERSAL VOICE AGENT SYSTEM PROMPT
# Business: {business_name} | Type: {business_type_label}
# ============================================================

# ============================================================
# LAYER 1: ABSOLUTE PROHIBITIONS — HIGHEST PRIORITY (NEVER BREAK)
# ============================================================

## HARD STOP RULES:
RULE 1 — ACCURACY:
Never guess prices, rates, dates, availability, or facts. If the answer is not in your knowledge base, say you don't have that information and offer to escalate.

RULE 2 — CONCISENESS & RICHNESS:
Keep replies natural and conversational (2 to 3 sentences maximum). Provide rich, descriptive details when explaining products or answering questions, but avoid long robotic monologues. The customer is listening to you in real-time. No bullet points, no markdown symbols, no lists.

RULE 3 — NO TECHNICAL TALK:
Never mention that you are an AI, a language model, or that you are using tools or functions. Act as a natural human business representative at all times.

# ============================================================
# LAYER 2: CONVERSATIONAL IDENTITY & STATE
# ============================================================
{layer2}

# ============================================================
# LAYER 3: TRANSACTION FLOW & ACTIONS
# ============================================================
{layer3}

# ============================================================
# LAYER 4: BUSINESS KNOWLEDGE BASE (DYNAMICALLY INJECTED)
# ============================================================
[The business context and knowledge base content will be dynamically loaded and placed here. If this section is empty, rely on your knowledge base search tool.]
"""


def get_business_type(business_type: str) -> Dict[str, Any]:
    """Return config for a given business type, defaulting to 'generic'."""
    return BUSINESS_TYPES.get(business_type, BUSINESS_TYPES["generic"])


def build_system_prompt(
    business_type: str,
    business_name: str,
    agent_name: str = "Assistant",
    kb_text: str = "",
    product_text: str = ""
) -> str:
    """
    Build a complete system prompt for an assistant.

    Args:
        business_type: One of the keys in BUSINESS_TYPES
        business_name: The name of the business (e.g., "Tugatai Cargo")
        agent_name: The AI agent's persona name (e.g., "Lena")
        kb_text: Extracted knowledge base text to inject into Layer 4
        product_text: Extracted product catalog text to inject as product section

    Returns:
        Complete system prompt string ready for Vapi
    """
    config = get_business_type(business_type)

    layer2 = config["prompt_layer2"].format(
        business_name=business_name,
        agent_name=agent_name
    )
    layer3 = config["prompt_layer3"]

    prompt = MASTER_PROMPT_TEMPLATE.format(
        business_name=business_name,
        business_type_label=config["display_name"],
        layer2=layer2,
        layer3=layer3,
    )

    # Inject KB text into Layer 4 if provided
    if kb_text:
        placeholder = "[The business context and knowledge base content will be dynamically loaded and placed here. If this section is empty, rely on your knowledge base search tool.]"
        kb_section = f"# KNOWLEDGE BASE — {business_name.upper()}\n\n{kb_text}"
        prompt = prompt.replace(placeholder, kb_section)

    # Inject product catalog if provided
    if product_text:
        prompt = inject_product_catalog_into_prompt(prompt, product_text)

    return prompt


def list_business_types() -> list:
    """Return list of business types for API/frontend use."""
    return [
        {
            "value": key,
            "label": cfg["display_name"],
            "icon": cfg["icon"],
            "description": cfg["description"],
            "tools": cfg["tools"],
        }
        for key, cfg in BUSINESS_TYPES.items()
    ]


async def analyze_business_pdf_with_openai(doc_text: str) -> dict:
    """
    Call OpenAI to analyze a business script/document and extract structural details:
    business type, business name, agent name, language, specific flow instructions (layer 2/3),
    and what tools are needed.
    """
    import json
    import httpx
    from app.config import OPENAI_API_KEY

    if not OPENAI_API_KEY:
        # Fallback if no API key is set
        return {
            "business_name": "Valued Business",
            "agent_name": "Sarah",
            "business_type": "generic",
            "language": "en",
            "custom_layer2": "- **Identity**: You are a professional front-desk assistant.\n- **Tone**: Warm, helpful, and concise.",
            "custom_layer3": "### 1. INFORMATION REQUESTS:\n- Answer questions based on the knowledge base.\n\n### 2. ESCALATION:\n- Transfer calls using the escalate_to_human tool if the query is too complex or urgent.",
            "tools": ["collect_info", "escalate_to_human"],
            "first_message": "Hello! How can I help you today?"
        }

    prompt = f"""
You are an expert voice AI designer. Analyze the following business script/document and design a voice agent tailored to this business.

Business Document:
\"\"\"
{doc_text}
\"\"\"

Provide your response in JSON format matching the following keys:
1. "business_name": The name of the business (e.g., "Doha VIP Wheels").
2. "agent_name": A friendly, professional name for the AI agent (e.g., "Sarah", "Alex").
3. "business_type": The closest matching business type from: "cargo", "restaurant", "legal", "education", "real_estate", "healthcare", "generic".
4. "language": Two-letter language code (e.g., "en", "es", "ar").
5. "custom_layer2": A bulleted list defining the agent's identity, persona, and specific vocal tone/rules. Explicitly include dynamic vocal delivery instructions based on the script (e.g. "Use rich, appetizing descriptive language when discussing menu items", or "Speak with empathetic, clear pacing for medical queries").
6. "custom_layer3": A structured guide for the agent's main flows and scenarios (e.g. booking appointment, taking order, providing quote, escalating call). Be detailed and specific to this business's script, specifying exactly what fields/data the agent needs to collect. If the business is cargo (parcel delivery), you MUST specify in 'custom_layer3' that the agent must ask the customer for their preferred pickup time in a specific time-wise format (e.g. '02:30 PM' or '14:30'), and that collecting this information is mandatory.
7. "tools": A list of tool names the agent will need. Choose from: "confirm_booking", "collect_info", "escalate_to_human". Choose "confirm_booking" if booking is needed; "escalate_to_human" if human handoff is needed; "collect_info" for other general form submissions. Do not use get_quote, the agent should quote based on its knowledge base.
8. "first_message": A warm, business-specific first greeting that the agent will speak when the call starts.
9. "extracted_data_fields": A JSON object defining specific data fields the agent must extract at the end of the call, based on this business's needs (e.g. for a restaurant: party_size, booking_time; for cargo: weight_kg, destination, pickup_time). If the business is cargo (parcel delivery), you MUST include 'pickup_time' as a required field with a description stating it must be a time-wise value (e.g., '02:30 PM' or '14:30'). Each key should be the field name, and the value should be a brief string description of what the field is. DO NOT include generic fields like lead_status, call_summary, customer_name, customer_phone, as they are already included by default.

Make sure the JSON is valid and only return the JSON block.
"""

    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": "You are a professional voice agent generator. Return only JSON."},
            {"role": "user", "content": prompt}
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.2
    }

    async with httpx.AsyncClient(timeout=40) as client:
        resp = await client.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
        if resp.status_code != 200:
            raise RuntimeError(f"OpenAI analysis failed: {resp.text}")
        
        result = resp.json()
        content = result["choices"][0]["message"]["content"]
        return json.loads(content)
