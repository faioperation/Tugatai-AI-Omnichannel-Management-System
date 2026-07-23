from langchain_core.tools import tool


def make_handoff_human(handoff_state: dict):
    """
    handoff_state is a plain dict (e.g. {"triggered": False, "reason": None})
    created fresh per-request in agent_runner.py. When this tool is called,
    it flips handoff_state["triggered"] to True so agent_runner.py can tell
    (after the agent finishes) that a human handoff happened this turn, and
    include "continueAi": false in the response sent back to the backend.
    """

    @tool
    def handoff_human(reason: str) -> str:
        """
        Escalate this conversation to a human agent.
        Use this when:
        - Customer is upset or angry
        - Customer disputes a price
        - Customer needs actual legal advice
        - The request needs a decision outside your authority (e.g. custom
          pricing/discounts, confirming a specific meeting time the business
          owner's actual availability, or anything else only the business
          owner/team can decide)
        - Issue is too complex for AI to handle
        - Customer requests to speak with a human
        """
        handoff_state["triggered"] = True
        handoff_state["reason"] = reason

        return (
            f"I'm connecting you with a human agent now. "
            f"Please wait a moment. "
            f"Someone from our team will assist you shortly."
        )

    return handoff_human