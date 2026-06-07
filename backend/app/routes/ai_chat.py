from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Optional
import requests

from app.auth.jwt_handler import get_current_user
from app.config.supabase import get_supabase
from app.schemas.chat_schema import ChatRequest, ChatResponse
from supabase import Client

router = APIRouter(
    prefix="/ai",
    tags=["AI Chatbot"]
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _fetch_vendor_context(supabase: Client) -> str:
    """Build a compact vendor context block for the Gemma prompt."""
    try:
        vendors_res = supabase.table("vendors").select("*").eq("approved", True).execute()
        vendors = vendors_res.data or []

        # Fetch category names once
        cats_res = supabase.table("vendor_categories").select("id,name").execute()
        cat_map: Dict[str, str] = {c["id"]: c["name"] for c in (cats_res.data or [])}
    except Exception:
        return ""

    lines: List[str] = ["=== APPROVED VENDORS ==="]
    for v in vendors:
        cat_name = cat_map.get(v.get("category_id", ""), "General")
        lines.append(
            f"- {v.get('business_name', 'N/A')} | Category: {cat_name} | "
            f"Location: {v.get('location', 'N/A')} | "
            f"Rating: {v.get('rating', 0.0):.1f}/5 | "
            f"Price: ₹{int(v.get('base_price_min', 0))}–₹{int(v.get('base_price_max', 0))} | "
            f"Description: {(v.get('description') or 'N/A')[:120]}"
        )
    return "\n".join(lines)


def _fetch_event_context(supabase: Client, user_id: str) -> str:
    """Fetch the user's upcoming events for context."""
    try:
        res = supabase.table("events").select(
            "name,event_date,location,budget,event_type"
        ).eq("user_id", user_id).order("event_date", desc=False).limit(5).execute()
        events = res.data or []
    except Exception:
        return ""

    if not events:
        return ""
    lines = ["=== USER EVENTS ==="]
    for e in events:
        lines.append(
            f"- {e.get('name', 'N/A')} | Date: {e.get('event_date', 'N/A')} | "
            f"Location: {e.get('location', 'N/A')} | "
            f"Budget: ₹{int(e.get('budget', 0))} | "
            f"Type: {e.get('event_type', 'N/A')}"
        )
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# System Prompt
# ---------------------------------------------------------------------------

SYSTEM_PROMPT = """You are Event Nanban, an intelligent and friendly AI event planning assistant for the EventLink platform.

Your core responsibilities:
1. Recommend ONLY approved vendors from the database provided below.
2. Respect the user's stated budget — never suggest vendors that exceed it significantly.
3. Prefer vendors with higher ratings when multiple options exist.
4. Suggest complete, practical event plans when asked.
5. Allocate budget intelligently across vendor categories for any given event type.
6. Answer FAQ about event planning (timelines, decorations, catering ratios, etc.).
7. Be conversational, warm, and concise. Use ₹ for Indian Rupee amounts.
8. If you cannot find a suitable vendor in the database, say so honestly — never invent vendors.
9. When comparing vendors, list them in a clear table-like format.
10. Always reference vendor names, ratings, and price ranges from the data provided.

IMPORTANT: Use ONLY the vendor data given to you. Do not invent vendors, prices, or ratings."""


def _build_prompt(request: ChatRequest, vendor_ctx: str, event_ctx: str) -> str:
    """Assemble the full prompt with system instructions, context, history, and user message."""
    sections = [SYSTEM_PROMPT, ""]

    if vendor_ctx:
        sections.append(vendor_ctx)
        sections.append("")

    if event_ctx:
        sections.append(event_ctx)
        sections.append("")

    # Conversation history
    if request.history:
        sections.append("=== CONVERSATION HISTORY ===")
        for turn in request.history:
            role_label = "User" if turn.role == "user" else "Event Nanban"
            sections.append(f"{role_label}: {turn.content}")
        sections.append("")

    sections.append("=== CURRENT USER MESSAGE ===")
    sections.append(f"User: {request.message}")
    sections.append("")
    sections.append("Event Nanban:")  # Prompt the model to continue from here

    return "\n".join(sections)


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(
    request: ChatRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_supabase)
):
    """
    Event Nanban AI chat endpoint powered by Gemma via Ollama.

    - Injects live vendor data (name, category, location, rating, price range)
    - Injects the user's own events for context
    - Supports multi-turn conversation history
    - Uses a detailed Event Nanban system prompt
    """
    # 1. Gather real database context
    vendor_ctx = _fetch_vendor_context(supabase)
    event_ctx = _fetch_event_context(supabase, current_user.get("id", ""))

    # 2. Build the full prompt
    prompt = _build_prompt(request, vendor_ctx, event_ctx)

    # 3. Call Ollama (gemma4:31b-cloud)
    ollama_url = "http://localhost:11434/api/generate"
    payload = {
        "model": "gemma4:31b-cloud",
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0.7,
            "top_p": 0.9,
            "num_predict": 1024,
        }
    }

    try:
        resp = requests.post(ollama_url, json=payload, timeout=120)
        resp.raise_for_status()
    except requests.Timeout:
        raise HTTPException(
            status_code=503,
            detail="The AI model took too long to respond. Please try again."
        )
    except requests.RequestException as e:
        raise HTTPException(
            status_code=503,
            detail="AI service is currently unavailable. Please ensure Ollama is running."
        )

    data = resp.json()
    reply_text: Optional[str] = (
        data.get("response")
        or data.get("output")
        or (data.get("message") or {}).get("content")
    )
    if not reply_text:
        raise HTTPException(
            status_code=500,
            detail="Received an empty response from the AI model."
        )

    return ChatResponse(reply=reply_text.strip())
