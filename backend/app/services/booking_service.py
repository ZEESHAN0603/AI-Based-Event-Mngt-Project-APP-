from fastapi import HTTPException, status
from supabase import Client
from app.schemas.booking_schema import BookingCreate, BookingStatusUpdate
import uuid
from datetime import datetime, timezone

def require_organizer(user: dict):
    if user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can perform this action"
        )

def require_vendor(user: dict):
    if user.get("role") != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendors can perform this action"
        )

def get_vendor_profile_id(current_user: dict, supabase: Client) -> str:
    """Get the vendor profile ID linked to the current user."""
    try:
        result = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor profile not found"
            )
        return result.data[0]["id"]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendor profile")

def create_booking(booking_data: BookingCreate, current_user: dict, supabase: Client):
    require_organizer(current_user)
    
    # 1. Verify organizer owns the event
    try:
        event_result = supabase.table("events").select("id, event_date").eq("id", booking_data.event_id).eq("organizer_id", current_user["id"]).execute()
        if not event_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found or you don't have access"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify event")

    event = event_result.data[0]
    
    # 2. Verify vendor exists and is approved
    try:
        vendor_result = supabase.table("vendors").select("id, approved").eq("id", booking_data.vendor_id).execute()
        if not vendor_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor not found"
            )
        if not vendor_result.data[0].get("approved"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vendor is not approved yet"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify vendor")

    # 3. Check vendor availability against event date
    event_date_str = event["event_date"]
    # Extract just the date portion (YYYY-MM-DD) for comparison
    if isinstance(event_date_str, str):
        event_date_only = event_date_str[:10]
    else:
        event_date_only = str(event_date_str)[:10]

    try:
        avail_result = supabase.table("vendor_availability").select("id").eq("vendor_id", booking_data.vendor_id).eq("blocked_date", event_date_only).execute()
        if avail_result.data and len(avail_result.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Vendor is unavailable on the event date"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check vendor availability")

    # 4. Prevent duplicate pending bookings for the same event+vendor
    try:
        dup_result = supabase.table("bookings").select("id").eq("event_id", booking_data.event_id).eq("vendor_id", booking_data.vendor_id).eq("booking_status", "pending").execute()
        if dup_result.data and len(dup_result.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A pending booking already exists for this vendor and event"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check duplicate bookings")

    # 5. Insert booking
    booking_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    row = {
        "id": booking_id,
        "event_id": booking_data.event_id,
        "vendor_id": booking_data.vendor_id,
        "organizer_id": current_user["id"],
        "booking_status": "pending",
        "total_amount": booking_data.total_amount,
        "notes": booking_data.notes,
        "created_at": created_at
    }
    
    try:
        result = supabase.table("bookings").insert(row).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to create booking")

def get_organizer_bookings(current_user: dict, supabase: Client):
    require_organizer(current_user)
    try:
        result = supabase.table("bookings").select("*").eq("organizer_id", current_user["id"]).order("created_at", desc=True).execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch bookings")

def get_vendor_bookings(current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    try:
        result = supabase.table("bookings").select("*").eq("vendor_id", vendor_id).order("created_at", desc=True).execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch bookings")

def update_booking_status(booking_id: str, status_update: BookingStatusUpdate, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    
    # Fetch booking and verify vendor ownership
    try:
        result = supabase.table("bookings").select("*").eq("id", booking_id).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found"
            )
        booking = result.data[0]
        if booking["vendor_id"] != vendor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only manage bookings assigned to you"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")

    try:
        result = supabase.table("bookings").update({"booking_status": status_update.booking_status}).eq("id", booking_id).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to update booking status")
