from fastapi import HTTPException, status
from supabase import Client
from app.schemas.event_schema import EventCreate, EventUpdate
import uuid
from datetime import datetime, timezone

def require_organizer(user: dict):
    if user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can perform this action"
        )

def create_event(event: EventCreate, current_user: dict, supabase: Client):
    require_organizer(current_user)
    
    event_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    event_data = event.model_dump()
    if event_data.get("event_date"):
        event_data["event_date"] = event_data["event_date"].isoformat()
        
    event_data.update({
        "id": event_id,
        "organizer_id": current_user["id"],
        "created_at": created_at
    })
    
    try:
        result = supabase.table("events").insert(event_data).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create event"
        )

def get_events(current_user: dict, supabase: Client):
    try:
        result = supabase.table("events").select("*").eq("organizer_id", current_user["id"]).execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch events"
        )

def get_event_by_id(event_id: str, current_user: dict, supabase: Client):
    try:
        result = supabase.table("events").select("*").eq("id", event_id).eq("organizer_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found or you don't have access"
            )
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch event"
        )

def update_event(event_id: str, event_update: EventUpdate, current_user: dict, supabase: Client):
    require_organizer(current_user)
    
    # Verify ownership
    get_event_by_id(event_id, current_user, supabase)
    
    update_data = event_update.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update"
        )
        
    if update_data.get("event_date"):
        update_data["event_date"] = update_data["event_date"].isoformat()
        
    try:
        result = supabase.table("events").update(update_data).eq("id", event_id).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update event"
        )

def delete_event(event_id: str, current_user: dict, supabase: Client):
    require_organizer(current_user)
    
    # Verify ownership
    get_event_by_id(event_id, current_user, supabase)
    
    try:
        supabase.table("events").delete().eq("id", event_id).execute()
        return {"message": "Event deleted successfully"}
    except Exception as e:
        print(f"SUPABASE DELETE ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete event"
        )
