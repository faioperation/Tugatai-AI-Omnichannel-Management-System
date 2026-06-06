"""
Assistants route — VAPI assistant CRUD endpoints.
Wraps agents.py under the /api/assistants prefix for cleaner RESTful naming.
"""
from .agents import router as router  # re-export the same router
