from agent.agent_runner import run_agent

paused_conversations = set()

async def handle_incoming(payload: dict):
    print(f"[INCOMING] Raw payload: {payload}")

    business_id = payload.get("business_id") or payload.get("businessId")
    training_data_id = payload.get("training_data_id") or payload.get("trainingDataId")
    subject = payload.get("subject")
    recipient_id = payload.get("recipient_id") or payload.get("recipientId")
    conversation_id = payload.get("conversation_id") or payload.get("conversationId")
    channel = payload.get("channel")
    message = payload.get("message")
    branch_id = payload.get("branch_id") or payload.get("branchId")

    key = f"{business_id}:{recipient_id}"
    if key in paused_conversations:
        print(f"[HANDOFF] AI paused for {key} — human agent handling")
        return {"response": None, "continue_ai": False}

    response = await run_agent(
        business_id=business_id,
        training_data_id=training_data_id,
        subject=subject,
        recipient_id=recipient_id,
        conversation_id=conversation_id,
        channel=channel,
        message=message,
        branch_id=branch_id
    )
    return response