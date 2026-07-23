"""
Standalone image-pipeline test — isolates ONLY the image download + base64
+ vision-description step, without touching the live bot, memory, or
production logs.

WHY THIS EXISTS
----------------
Production logs are off, so we can't see [IMAGE ERROR] / [IMAGE] lines from
a real conversation. This script lets you run the exact same download +
base64 + vision logic locally, against a real image URL, and see every step
printed clearly — download status, byte size, guessed mime type, and finally
whether GPT-4o can actually describe what's in the image.

USAGE
-----
    python test_image_understanding.py "https://test8.fireai.agency/uploads/whatsapp/wa-....jpg"

If no URL is passed as an argument, edit TEST_IMAGE_URL below and just run:
    python test_image_understanding.py
"""

import asyncio
import sys

import httpx
from openai import AsyncOpenAI

from core.config import OPENAI_API_KEY, ROBERTO_API_TOKEN

# Edit this if you want to hardcode a URL instead of passing it as an argument
TEST_IMAGE_URL = "https://test8.fireai.agency/uploads/whatsapp/REPLACE-ME.jpg"

openai_client = AsyncOpenAI(api_key=OPENAI_API_KEY)


def _guess_image_mime(data: bytes) -> str:
    if data.startswith(b"\xff\xd8"):
        return "image/jpeg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if data.startswith(b"GIF87a") or data.startswith(b"GIF89a"):
        return "image/gif"
    if len(data) >= 12 and data[0:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return "image/jpeg"


async def test_download_with_token(url: str):
    print(f"\n--- Attempt 1: download WITH x-api-token header ---")
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                url,
                headers={"x-api-token": ROBERTO_API_TOKEN},
                timeout=30.0,
            )
            print(f"Status: {resp.status_code}")
            print(f"Content-Type header: {resp.headers.get('content-type')}")
            print(f"Bytes received: {len(resp.content)}")
            resp.raise_for_status()
            return resp.content
    except Exception as e:
        print(f"FAILED: {type(e).__name__}: {e}")
        return None


async def test_download_without_token(url: str):
    print(f"\n--- Attempt 2: download WITHOUT any auth header (public test) ---")
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(url, timeout=30.0)
            print(f"Status: {resp.status_code}")
            print(f"Content-Type header: {resp.headers.get('content-type')}")
            print(f"Bytes received: {len(resp.content)}")
            resp.raise_for_status()
            return resp.content
    except Exception as e:
        print(f"FAILED: {type(e).__name__}: {e}")
        return None


async def test_vision_description(image_bytes: bytes):
    import base64

    mime = _guess_image_mime(image_bytes)
    b64 = base64.b64encode(image_bytes).decode("utf-8")
    data_url = f"data:{mime};base64,{b64}"

    print(f"\n--- Attempt 3: asking GPT-4o to describe the downloaded image ---")
    print(f"Guessed mime type: {mime}")
    print(f"Base64 length: {len(b64)} chars")

    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "What do you see in this image? Describe it in detail."},
                        {"type": "image_url", "image_url": {"url": data_url}},
                    ],
                }
            ],
            max_tokens=300,
        )
        description = response.choices[0].message.content
        print(f"\nGPT-4o's description of the image:\n{description}")
        return description
    except Exception as e:
        print(f"FAILED: {type(e).__name__}: {e}")
        return None


async def main():
    url = sys.argv[1] if len(sys.argv) > 1 else TEST_IMAGE_URL

    if "REPLACE-ME" in url:
        print("Please pass a real image URL as an argument, e.g.:")
        print('  python test_image_understanding.py "https://test8.fireai.agency/uploads/whatsapp/wa-....jpg"')
        return

    print(f"Testing image URL: {url}")

    # Try both ways of downloading, so we know for sure whether the token
    # header matters at all for this route.
    image_bytes = await test_download_with_token(url)
    if image_bytes is None:
        image_bytes = await test_download_without_token(url)

    if image_bytes is None:
        print("\n>>> RESULT: Could not download the image AT ALL, with or "
              "without the token. This is a download/network/URL problem, "
              "not an AI/vision problem.")
        return

    if len(image_bytes) < 500:
        print(f"\n>>> WARNING: Only {len(image_bytes)} bytes downloaded — "
              f"this is suspiciously small for a real photo. It might be an "
              f"error page (HTML) rather than actual image data. First 200 "
              f"bytes:\n{image_bytes[:200]}")
        return

    description = await test_vision_description(image_bytes)

    if description:
        print("\n>>> RESULT: Download AND vision both worked. If the live "
              "bot still isn't describing images, the issue is likely in "
              "how agent_runner.py assembles the message content list, or "
              "in the system prompt / conversation flow — not in the image "
              "pipeline itself.")
    else:
        print("\n>>> RESULT: Image downloaded fine, but GPT-4o could not "
              "process it. Check the OpenAI error above.")


if __name__ == "__main__":
    asyncio.run(main())