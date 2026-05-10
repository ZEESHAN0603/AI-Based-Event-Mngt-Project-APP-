from fastapi import APIRouter, Depends
from typing import List
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.shortlist_schema import ShortlistCreate, ShortlistResponse
from app.services.shortlist_service import add_to_shortlist, get_event_shortlists, remove_from_shortlist
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/shortlists", tags=["Shortlists"])

@router.post("", response_model=ShortlistResponse, status_code=201)
def api_add_to_shortlist(shortlist_data: ShortlistCreate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Shortlist a vendor for an event. Only allowed for organizers who own the event."""
    return add_to_shortlist(shortlist_data, current_user, supabase)

@router.get("/{event_id}", response_model=List[ShortlistResponse])
def api_get_event_shortlists(event_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all shortlisted vendors for a specific event. Only for event owner."""
    return get_event_shortlists(event_id, current_user, supabase)

@router.delete("/{shortlist_id}", status_code=200)
def api_remove_from_shortlist(shortlist_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Remove a vendor from the shortlist. Only for event owner."""
    return remove_from_shortlist(shortlist_id, current_user, supabase)
