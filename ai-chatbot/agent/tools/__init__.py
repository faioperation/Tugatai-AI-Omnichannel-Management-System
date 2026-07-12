from agent.tools.search_knowledge import search_knowledge
from agent.tools.handoff_human import make_handoff_human
from agent.tools.collect_lead import make_collect_lead
from agent.tools.create_booking import make_create_booking
from agent.tools.get_pricing import make_get_pricing


def get_all_tools(
    business_id: str = None,
    branch_id: str = None,
    channel: str = None,
    conversation_id: str = None,
    handoff_state: dict = None,
):
    if handoff_state is None:
        handoff_state = {"triggered": False, "reason": None}

    return [
        search_knowledge,
        make_handoff_human(handoff_state),
        make_collect_lead(branch_id, channel, conversation_id),
        make_create_booking(branch_id, conversation_id),
        make_get_pricing(business_id, branch_id),
    ]