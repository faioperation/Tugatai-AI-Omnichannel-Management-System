"""
Roberto Voice Agent - 4-Business Test Runner
=============================================
Creates 4 AI voice agents for 4 different business types, then
runs chat simulations against each one and prints the results.

Business Types Tested:
  1. 🍽️  Restaurant     — Golden Fork Restaurant
  2. 🚢  Cargo          — Swift Cargo International
  3. ⚖️  Legal          — Meridian Law Firm
  4. 🏥  Healthcare     — Summit Health Clinic

Usage:
  python test_4_agents.py

Requirements:
  - Server running at http://localhost:8001
  - VAPI_API_KEY and OPENAI_API_KEY set in .env
"""

import asyncio
import httpx
import json
import os
import sys

# Force UTF-8 output on Windows
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")  # type: ignore
from pathlib import Path
from datetime import datetime

BASE_URL = "http://localhost:8001"

# ── Business Definitions ──────────────────────────────────────────────────────

BUSINESSES = [
    {
        "id": "golden-fork-restaurant",
        "label": "[RESTAURANT] Golden Fork Restaurant",
        "type": "restaurant",
        "script_path": "test_businesses/restaurant_scripts/golden_fork_restaurant.txt",
        "test_conversations": [
            "Hi, I'd like to make a reservation for 4 people this Saturday at 7pm.",
            "What's on your menu for mains? Any lamb dishes?",
            "Do you have vegetarian options? What's the price range?",
        ]
    },
    {
        "id": "swift-cargo-international",
        "label": "[CARGO] Swift Cargo International",
        "type": "cargo",
        "script_path": "test_businesses/cargo_scripts/swift_cargo.txt",
        "test_conversations": [
            "Hi, I need to ship 200kg of electronics from Dubai to London. What are my options?",
            "How long does sea freight to China take and what's the cost per CBM?",
            "I want to ship some lithium batteries, is that possible?",
        ]
    },
    {
        "id": "meridian-law-firm",
        "label": "[LEGAL] Meridian Law Firm",
        "type": "legal",
        "script_path": "test_businesses/legal_scripts/meridian_law_firm.txt",
        "test_conversations": [
            "Hello, I need to consult a lawyer about a divorce case. What are my options?",
            "What are your consultation fees? Is the first one free?",
            "I was just arrested, I need help right now!",
        ]
    },
    {
        "id": "summit-health-clinic",
        "label": "[HEALTHCARE] Summit Health Clinic",
        "type": "healthcare",
        "script_path": "test_businesses/healthcare_scripts/summit_health_clinic.txt",
        "test_conversations": [
            "Hi, I'd like to book an appointment with Dr. Reyes for next Tuesday.",
            "Do you accept Blue Cross Blue Shield insurance?",
            "I'm having severe chest pain and can't breathe properly!",
        ]
    }
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def print_header(text: str, char: str = "="):
    line = char * 60
    print(f"\n{line}")
    print(f"  {text}")
    print(f"{line}")


def print_result(label: str, value: str, success: bool = True):
    icon = "[OK]" if success else "[FAIL]"
    print(f"  {icon}  {label}: {value}")


# ── Step 1: Create Agents ─────────────────────────────────────────────────────

async def create_agent(client: httpx.AsyncClient, business: dict) -> str | None:
    """POST /api/agents/create with the business script file."""
    script_path = Path(business["script_path"])

    if not script_path.exists():
        print_result(f"Script not found", str(script_path), success=False)
        return None

    print(f"  >> Uploading script: {script_path.name}")

    with open(script_path, "rb") as f:
        files = {"rules_file": (script_path.name, f, "text/plain")}
        data  = {"business_id": business["id"]}

        try:
            resp = await client.post(
                f"{BASE_URL}/api/agents/create",
                files=files,
                data=data,
                timeout=120  # OpenAI analysis can take a moment
            )
        except httpx.ConnectError:
            print_result("Connection failed", f"Is the server running at {BASE_URL}?", success=False)
            return None

    if resp.status_code in (200, 201):
        data_out = resp.json()
        assistant_id = data_out.get("assistant_id", "N/A")
        print_result("Agent created", assistant_id)
        return assistant_id
    else:
        print_result(f"Create failed ({resp.status_code})", resp.text[:200], success=False)
        return None


# ── Step 2: Chat with Agents ──────────────────────────────────────────────────

async def chat_with_agent(client: httpx.AsyncClient, assistant_id: str, message: str) -> str:
    """POST /api/chat-with-agent to get a text response from the AI."""
    payload = {
        "assistant_id": assistant_id,
        "message": message
    }
    try:
        resp = await client.post(
            f"{BASE_URL}/api/chat-with-agent",
            json=payload,
            timeout=60
        )
        if resp.status_code == 200:
            result = resp.json()
            # Handle different response shapes
            if isinstance(result, dict):
                return (
                    result.get("response") or
                    result.get("message") or
                    result.get("content") or
                    result.get("reply") or
                    json.dumps(result)
                )
            return str(result)
        else:
            return f"[ERROR {resp.status_code}] {resp.text[:150]}"
    except Exception as e:
        return f"[EXCEPTION] {type(e).__name__}: {e}"


# ── Step 3: Full Test Run ─────────────────────────────────────────────────────

async def run_tests():
    print_header("ROBERTO VOICE AGENT — 4-BUSINESS TEST RUN")
    print(f"  Server: {BASE_URL}")
    print(f"  Time:   {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    results = []

    async with httpx.AsyncClient() as client:

        # ── Quick health check ────────────────────────────────────────────────
        print_header("STEP 0: Health Check", "-")
        try:
            hc = await client.get(f"{BASE_URL}/", timeout=10)
            if hc.status_code == 200:
                print_result("Server status", "ONLINE ✔")
            else:
                print_result("Server returned unexpected status", str(hc.status_code), success=False)
                print("  ⚠️  Fix server first. Aborting.")
                return
        except httpx.ConnectError:
            print_result("Cannot reach server", f"{BASE_URL} — run: uvicorn main:app --reload --port 8001", success=False)
            print("\n  ⛔ Start the server first, then re-run this script.")
            return

        # ── Process each business ─────────────────────────────────────────────
        for biz in BUSINESSES:
            print_header(f"BUSINESS: {biz['label']}")

            # 1. Create agent
            print(f"\n  [1/2] Creating agent from script...")
            assistant_id = await create_agent(client, biz)

            if not assistant_id:
                results.append({
                    "business": biz["label"],
                    "status": "FAILED — agent not created",
                    "conversations": []
                })
                continue

            # 2. Run test conversations
            print(f"\n  [2/2] Testing {len(biz['test_conversations'])} conversations...\n")
            conversations = []

            for i, user_msg in enumerate(biz["test_conversations"], 1):
                print(f"  ─── Message {i} ───────────────────────────────────────")
                print(f"  USER:  {user_msg}")
                agent_reply = await chat_with_agent(client, assistant_id, user_msg)
                print(f"  AGENT: {agent_reply}")
                print()

                conversations.append({
                    "user": user_msg,
                    "agent": agent_reply
                })

                await asyncio.sleep(1)  # gentle pacing

            results.append({
                "business": biz["label"],
                "business_type": biz["type"],
                "assistant_id": assistant_id,
                "status": "SUCCESS",
                "conversations": conversations
            })

    # ── Final Summary ─────────────────────────────────────────────────────────
    print_header("FINAL SUMMARY")
    for r in results:
        status_icon = "[OK]" if r["status"] == "SUCCESS" else "[FAIL]"
        conv_count  = len(r.get("conversations", []))
        print(f"  {status_icon}  {r['business']}")
        if r["status"] == "SUCCESS":
            print(f"       Assistant ID : {r.get('assistant_id', 'N/A')}")
            print(f"       Conversations: {conv_count} tested")
        else:
            print(f"       Status       : {r['status']}")
        print()

    # ── Save JSON output ──────────────────────────────────────────────────────
    output_file = f"test_output_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"  >> Full output saved to: {output_file}")
    print_header("TEST COMPLETE", "=")


if __name__ == "__main__":
    asyncio.run(run_tests())
