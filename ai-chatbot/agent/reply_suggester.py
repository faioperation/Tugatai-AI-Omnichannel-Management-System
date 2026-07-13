import re

from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent

from agent.memory import fetch_conversation_history, get_history
from agent.prompt_builder import build_prompt
from agent.tools.search_knowledge import search_knowledge
from agent.tools.get_pricing import make_get_pricing
from agent.agent_runner import fetch_business, fetch_training_data, fetch_campaigns
from core.config import OPENAI_API_KEY

# Same model as the main agent, but a bit more conservative temperature since
# this text may go out verbatim if the human doesn't edit it much.
llm = ChatOpenAI(
    model="gpt-4o",
    api_key=OPENAI_API_KEY,
    temperature=0.5
)


def _strip_markdown(text: str) -> str:
    """Same stripping as agent_runner.py — WhatsApp/Messenger/Instagram don't
    render markdown consistently, and a human agent shouldn't have to clean
    up stray asterisks before sending."""
    if not text:
        return text
    text = re.sub(r"\*\*([^\n*]+?)\*\*", r"\1", text)
    text = re.sub(r"(?<!\*)\*([^\n*]+?)\*(?!\*)", r"\1", text)
    text = re.sub(r"(?m)^#{1,6}\s+", "", text)
    text = re.sub(r"`([^`]+)`", r"\1", text)
    return text


def _last_customer_message(history: list) -> str:
    """Finds the most recent message that came FROM the customer (role
    'user'), scanning backwards. Returns '' if none found."""
    for msg in reversed(history):
        if msg.get("role") == "user" and msg.get("content"):
            return msg["content"]
    return ""


DRAFT_MODE_INSTRUCTIONS = """

HUMAN AGENT REPLY-ASSIST MODE — VERY IMPORTANT, THIS OVERRIDES YOUR NORMAL WORKFLOW:
A human agent from the business wants AI help writing their NEXT reply to
the customer. This is a completely different job from your normal
autonomous conversation-running role. Read this carefully:

- You will be told, explicitly, what the customer's most recent message
  was. Your ONLY job is to write ONE natural, humanized reply that directly
  answers or engages with THAT specific message — as if a knowledgeable,
  friendly staff member is personally typing back to them right now.
- DO NOT write a generic filler line like "I've connected you with a human
  agent, please hold on" / "someone will assist you shortly" / "thank you
  for your patience" as your whole reply. That is NOT a reply — it's an
  empty placeholder, and the human agent asking for your help already knows
  they need to say something real. Actually engage with the topic:
    * Asking about an offer, discount, or campaign? Check the active
      campaigns / business knowledge given to you and tell them specifically
      what's available (or, if genuinely nothing applies, say that plainly
      and offer the closest real alternative — a standard rate, a related
      service, etc.).
    * Asking about price/cost? Use get_pricing_rule or search_knowledge and
      give them real numbers if you can calculate them from what's known;
      otherwise ask for exactly the missing detail needed to quote it.
    * Asking about their shipment/parcel/booking status or details? Refer to
      the specific details already given earlier in the conversation
      (product, addresses, dates) and respond to their specific question
      about it.
    * Making a request only a human can decide (e.g. approving a custom
      discount)? Don't dodge it with filler — write what a real staff
      member would actually say: acknowledge the specific ask, say
      honestly what you (as the business) can offer or that you'll confirm
      with the team, and give a concrete next step or timeframe if possible.
- Sound like a person, not a script: warm, specific, conversational — refer
  to the actual details of what they asked rather than a template phrase.
- Use the full conversation history only as background/context (product,
  addresses, previous answers already given) — but the reply itself must be
  aimed squarely at their LAST message, not a generic conversation summary.
- You MAY use search_knowledge or get_pricing_rule to make sure the reply is
  factually accurate.
- Do NOT call collect_lead, create_booking, or handoff_human — a human is
  already handling this conversation; you are only drafting text for them.
- Reply in the SAME language and script the customer's last message used.
- Do not use markdown formatting symbols, per the formatting rule above.
- Output ONLY the drafted reply text itself — no preamble, no explanation,
  no quotation marks around it. Just the message as it should be sent.
"""


async def generate_reply_suggestion(
    business_id: str,
    subject: str,
    conversation_id: str,
    recipient_id: str,
    branch_id: str = None,
) -> str:
    """
    Generates a DRAFT reply for a human agent to review/edit before sending —
    a humanized, specific answer to the customer's LAST message, not a
    generic conversation-continuation or acknowledgment.

    Unlike run_agent():
    - No tools that take real action (collect_lead, create_booking,
      handoff_human) are given to the model — only read-only knowledge tools.
    - Nothing is saved to conversation memory here — the draft may be edited
      or discarded, and only becomes part of the real conversation once the
      human actually sends something through the normal send flow.
    - Nothing is sent to WhatsApp/Facebook/Instagram — this only returns
      text for the frontend to place in the reply box.

    Returns the drafted reply text (markdown-stripped), or a safe fallback
    string if something goes wrong.
    """
    try:
        business_data = await fetch_business(business_id)
        business_profile = business_data.get("profile", None)

        training_config = await fetch_training_data(business_id)
        active_campaigns = await fetch_campaigns(branch_id)

        # Load real conversation history the same way the main agent does
        history = await fetch_conversation_history(conversation_id)
        if not history:
            history = get_history(business_id, recipient_id)

        if not history:
            return (
                "There's no conversation history yet to base a suggested "
                "reply on."
            )

        last_message = _last_customer_message(history)
        if not last_message:
            return (
                "I couldn't find a message from the customer to reply to "
                "yet."
            )

        # Use the customer's actual last message (not a generic subject
        # string) as the RAG query, so retrieved knowledge is relevant to
        # what they're specifically asking about right now.
        context = None
        if not training_config:
            from rag.retriever import retrieve
            context = await retrieve(last_message, subject)

        system_prompt = build_prompt(
            subject=subject,
            business_profile=business_profile,
            training_config=training_config if training_config else None,
            context=context,
            active_campaigns=active_campaigns,
        )
        system_prompt += f"\n\nCRITICAL: The business_id for this conversation is: {business_id}"
        if branch_id:
            system_prompt += f"\nThe branch_id for this conversation is: {branch_id}"
        system_prompt += DRAFT_MODE_INSTRUCTIONS

        # Explicit final turn: hand the model the customer's actual last
        # message directly, plus the full history as context. This is what
        # keeps the draft targeted and specific instead of a vague
        # conversation-continuation or repeated acknowledgment.
        messages_for_model = history + [{
            "role": "user",
            "content": (
                "[Internal request from the business — not from the "
                "customer] The customer's most recent message, which you "
                "must write a direct, humanized, specific reply to, was:\n\n"
                f"\"{last_message}\"\n\n"
                "Use the conversation above only as background context. "
                "Draft ONE reply that a human agent could send right now — "
                "specific to that message, not a generic acknowledgment."
            ),
        }]

        # Read-only tools ONLY — no collect_lead / create_booking / handoff_human
        tools = [search_knowledge, make_get_pricing(business_id, branch_id)]

        agent = create_react_agent(llm, tools, prompt=system_prompt)
        result = await agent.ainvoke({"messages": messages_for_model})

        draft = result["messages"][-1].content
        draft = _strip_markdown(draft)
        return draft

    except Exception as e:
        print(f"[REPLY SUGGESTION ERROR] {e}")
        return (
            "Sorry, I couldn't generate a suggested reply right now due to "
            "a system issue. Please write your reply manually."
        )