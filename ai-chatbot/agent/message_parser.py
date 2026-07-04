"""
Parses the incoming `message` field, which is now a LIST of typed blocks
instead of a plain string, e.g.:

    [{"type": "text", "content": "এই জামাটার দাম কত?"}]
    [{"type": "image", "url": "https://graph.facebook.com/.../media"}]
    [{"type": "document", "content": {"text": "John Doe\\nSoftware Engineer..."}}]

A single message can contain one or more blocks of any type, in any
combination. This module is defensive: it never assumes a block is present,
and unknown block types are safely ignored (logged, not crashed on).

Output: a LangChain-compatible multimodal `content` list, ready to drop into
a HumanMessage, e.g.:

    [
        {"type": "text", "text": "এই জামাটার দাম কত?"},
        {"type": "image_url", "image_url": {"url": "https://..."}}
    ]

If the whole message is just text blocks, we collapse it down to a plain
string instead of a list — this keeps memory/history storage simple and
avoids storing image URLs (which can expire) in long-term conversation
history.
"""

from typing import Any, Union


def parse_incoming_message(raw_message: Any) -> Union[str, list]:
    """
    Normalizes `raw_message` (new list-of-blocks format, or legacy plain
    string) into either:
      - a plain string (when there's no image), or
      - a LangChain multimodal content list (when an image is present)

    Legacy support: if raw_message is already a plain string (old webhook
    shape), it's returned as-is.
    """
    # Legacy / already-plain-text payloads
    if isinstance(raw_message, str):
        return raw_message

    if not isinstance(raw_message, list):
        # Unexpected shape — fail safe rather than crashing the whole request
        print(f"[MESSAGE PARSE WARNING] Unexpected message type: {type(raw_message)}")
        return ""

    text_parts = []
    image_urls = []

    for block in raw_message:
        if not isinstance(block, dict):
            continue

        block_type = block.get("type")

        if block_type == "text":
            content = block.get("content", "")
            if content:
                text_parts.append(str(content))

        elif block_type == "image":
            url = block.get("url")
            if url:
                image_urls.append(url)

        elif block_type == "document":
            # Backend already extracts document text for us — no PDF/DOCX
            # parsing needed on our side. Just fold it into the text with a
            # clear marker so the LLM knows it's document content.
            doc_content = block.get("content", {})
            doc_text = doc_content.get("text", "") if isinstance(doc_content, dict) else ""
            if doc_text:
                text_parts.append(f"[Customer shared a document with this content:]\n{doc_text}")

        else:
            print(f"[MESSAGE PARSE WARNING] Unknown block type: {block_type}")

    combined_text = "\n".join(text_parts).strip()

    # No image → keep it simple, return plain string (works with existing
    # history storage and every code path that expects `message: str`)
    if not image_urls:
        return combined_text or "[Empty message]"

    # Image present → build multimodal content list for the LLM
    content_list = []
    if combined_text:
        content_list.append({"type": "text", "text": combined_text})
    else:
        # Vision models generally expect at least some text alongside the
        # image; give a minimal instruction so the model knows to look at it.
        content_list.append({"type": "text", "text": "Customer shared an image."})

    for url in image_urls:
        content_list.append({"type": "image_url", "image_url": {"url": url}})

    return content_list


def message_to_history_text(raw_message: Any) -> str:
    """
    Produces a plain-text representation of the message, suitable for
    storing in long-term conversation history (memory.py) and for the
    summary job (summary_prompt.py).

    We deliberately do NOT store raw image URLs in history — Meta media
    URLs expire, and keeping them around is not useful for future context.
    Instead we store a short placeholder so the summary/history still makes
    sense to a human or the LLM reading it later.
    """
    parsed = parse_incoming_message(raw_message)

    if isinstance(parsed, str):
        return parsed

    # It's a multimodal list — extract text parts, note the image separately
    text_bits = []
    has_image = False
    for item in parsed:
        if item.get("type") == "text":
            text_bits.append(item["text"])
        elif item.get("type") == "image_url":
            has_image = True

    text = "\n".join(text_bits).strip()
    if has_image:
        text = (text + "\n[Customer shared an image]").strip()

    return text or "[Customer shared an image]"