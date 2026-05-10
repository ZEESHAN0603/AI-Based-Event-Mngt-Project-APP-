from fastapi import HTTPException, status
from supabase import Client
from app.schemas.shortlist_schema import ShortlistCreate
import uuid
from datetime import datetime, timezone

def require_organizer(user: dict):
    if user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can perform this action"
        )

def verify_event_ownership(event_id: str, current_user: dict, supabase: Client):
    """Verify that the event exists and belongs to the current user."""
    try:
        result = supabase.table("events").select("id").eq("id", event_id).eq("organizer_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found or you don't have access"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify event ownership")

def verify_vendor_exists(vendor_id: str, supabase: Client):
    """Verify that the vendor exists."""
    try:
        result = supabase.table("vendors").select("id").eq("id", vendor_id).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor not found"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify vendor")

def add_to_shortlist(shortlist_data: ShortlistCreate, current_user: dict, supabase: Client):
    require_organizer(current_user)
    verify_event_ownership(shortlist_data.event_id, current_user, supabase)
    verify_vendor_exists(shortlist_data.vendor_id, supabase)
    
    # Check for duplicate shortlist entry
    try:
        existing = supabase.table("event_shortlists").select("id").eq("event_id", shortlist_data.event_id).eq("vendor_id", shortlist_data.vendor_id).execute()
        if existing.data and len(existing.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vendor is already shortlisted for this event"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check existing shortlist")

    shortlist_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    row = {
        "id": shortlist_id,
        "event_id": shortlist_data.event_id,
        "vendor_id": shortlist_data.vendor_id,
        "created_at": created_at
    }
    
    try:
        result = supabase.table("event_shortlists").insert(row).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to add vendor to shortlist")

def get_event_shortlists(event_id: str, current_user: dict, supabase: Client):
    require_organizer(current_user)
    verify_event_ownership(event_id, current_user, supabase)
    
    try:
        result = supabase.table("event_shortlists").select("*").eq("event_id", event_id).execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch shortlists")

def remove_from_shortlist(shortlist_id: str, current_user: dict, supabase: Client):
    require_organizer(current_user)
    
    # Fetch the shortlist entry
    try:
        result = supabase.table("event_shortlists").select("*").eq("id", shortlist_id).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Shortlist entry not found"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch shortlist entry")

    # Verify the organizer owns the event linked to this shortlist
    shortlist_entry = result.data[0]
    verify_event_ownership(shortlist_entry["event_id"], current_user, supabase)
    
    try:
        supabase.table("event_shortlists").delete().eq("id", shortlist_id).execute()
        return {"message": "Vendor removed from shortlist successfully"}
    except Exception as e:
        print(f"SUPABASE DELETE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to remove from shortlist")
