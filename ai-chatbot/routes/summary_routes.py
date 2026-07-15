from fastapi import APIRouter, Depends
from core.security import verify_token
from summary_agent.summary_runner import run_summary_for_all_conversations

router = APIRouter()

@router.post("/summary/run")
async def trigger_summary(_=Depends(verify_token)):
    await run_summary_for_all_conversations()
    return {"status": "ok", "message": "Summary job completed"}

@router.get("/summary/status")
async def summary_status(_=Depends(verify_token)):
    from agent.memory import _memory
    return {
        "status": "ok",
        "total_conversations": len(_memory),
        "conversation_keys": list(_memory.keys())
    }