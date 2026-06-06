import os
from dotenv import load_dotenv

load_dotenv()

# ── VAPI ─────────────────────────────────────────────────────────────────────
VAPI_API_KEY = os.getenv("VAPI_API_KEY", "")
VAPI_BASE    = "https://api.vapi.ai"

# ── OpenAI (for PDF business analysis) ───────────────────────────────────────
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

# ── Backend ───────────────────────────────────────────────────────────────────
# Your backend URL — receives full call summaries at end-of-call
BACKEND_URL = os.getenv("BACKEND_URL") or os.getenv("WEBHOOK_URL") or ""

# This service's own public URL — used as VAPI webhook target
# Set this to your ngrok / production URL so VAPI can reach your /api/webhook/calls
SERVICE_URL = os.getenv("SERVICE_URL", "http://localhost:8001")