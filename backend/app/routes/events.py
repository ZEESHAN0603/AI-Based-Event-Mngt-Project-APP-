from fastapi import APIRouter, Depends
from typing import List
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.event_schema import EventCreate, EventUpdate, EventResponse
from app.services.event_service import create_event, get_events, get_event_by_id, update_event, delete_event
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/events", tags=["Events"])

@router.post("", response_model=EventResponse, status_code=201)
def api_create_event(event: EventCreate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Create a new event. Only allowed for organizers."""
    return create_event(event, current_user, supabase)

@router.get("", response_model=List[EventResponse])
def api_get_events(current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all events belonging to the current user."""
    return get_events(current_user, supabase)

@router.get("/{event_id}", response_model=EventResponse)
def api_get_event(event_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get a specific event belonging to the current user."""
    return get_event_by_id(event_id, current_user, supabase)

@router.put("/{event_id}", response_model=EventResponse)
def api_update_event(event_id: str, event_update: EventUpdate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Update a specific event. Only allowed for organizers who own the event."""
    return update_event(event_id, event_update, current_user, supabase)

@router.delete("/{event_id}", status_code=200)
def api_delete_event(event_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Delete a specific event. Only allowed for organizers who own the event."""
    return delete_event(event_id, current_user, supabase)
