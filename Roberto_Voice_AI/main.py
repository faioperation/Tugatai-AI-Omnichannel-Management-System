"""
Roberto Voice Agent Service - Stateless API
Creates voice agents based on business scripts, handles VAPI call webhooks,
and forwards summary reports to the backend service.
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
# import logging

# logging.basicConfig(level=logging.INFO, format="%(levelname)s:\t  %(message)s")

from app.routes import (
    calls_router,
    assistants_router,
    chat_router,
    telephony_router
)
from app import http_client


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ──────────────────────────────────────────────────────
    await http_client.startup()
    print("[SERVER] HTTP client initialized")
    print("[SERVER] Stateless service started. Webhooks ready on /api/webhook/calls")
    yield
    # ── Shutdown ─────────────────────────────────────────────────────
    await http_client.shutdown()
    print("[SERVER] HTTP client shut down")


app = FastAPI(
    title="Roberto Voice Agent API",
    description="Stateless service for creating and managing AI Voice receptionists",
    version="3.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all stateless routers
app.include_router(assistants_router)
app.include_router(calls_router)
app.include_router(chat_router)
app.include_router(telephony_router)


@app.get("/")
def health_check():
    """Health check endpoint."""
    return {
        "status": "ok",
        "service": "Roberto Voice Agent API",
        "version": "3.0",
        "endpoints": {
            "create_assistant": "POST /api/create-assistant",
            "list_assistants": "GET /api/assistants",
            "get_assistant": "GET /api/assistant/{id}",
            "patch_assistant": "PATCH /api/assistant/{id}",
            "delete_assistant": "DELETE /api/assistant/{id}",
            "webhook": "POST /api/webhook/calls",
            "chat": "POST /api/chat-with-agent",
            "telephony": "GET/POST/DELETE /api/telephony/numbers"
        }
    }


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8002, reload=True)