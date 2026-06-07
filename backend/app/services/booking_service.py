from fastapi import HTTPException, status
from supabase import Client
from app.schemas.booking_schema import BookingCreate, BookingStatusUpdate, BookingRejectRequest
import uuid
from datetime import datetime, timezone

# ----- Role helpers -----
def require_organizer(user: dict):
    if user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can perform this action",
        )

def require_vendor(user: dict):
    if user.get("role") != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendors can perform this action",
        )

# ----- Vendor profile helper -----
def get_vendor_profile_id(current_user: dict, supabase: Client) -> str:
    """Get the vendor profile ID linked to the current user."""
    try:
        result = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor profile not found",
            )
        return result.data[0]["id"]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendor profile")

# ----- Core booking creation -----
def create_booking(booking_data: BookingCreate, current_user: dict, supabase: Client):
    require_organizer(current_user)
    # Verify organizer owns the event
    try:
        event_result = (
            supabase.table("events")
            .select("id, event_date")
            .eq("id", booking_data.event_id)
            .eq("organizer_id", current_user["id"]).execute()
        )
        if not event_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found or you don't have access",
            )
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify event")
    event = event_result.data[0]
    # Verify vendor exists and is approved
    try:
        vendor_result = (
            supabase.table("vendors")
            .select("id, approved")
            .eq("id", booking_data.vendor_id)
            .execute()
        )
        if not vendor_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor not found",
            )
        if not vendor_result.data[0].get("approved"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vendor is not approved yet",
            )
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify vendor")
    # Check vendor availability on event date
    event_date_str = event["event_date"]
    event_date = event_date_str[:10] if isinstance(event_date_str, str) else str(event_date_str)[:10]
    try:
        avail_result = (
            supabase.table("vendor_availability")
            .select("id")
            .eq("vendor_id", booking_data.vendor_id)
            .eq("blocked_date", event_date)
            .execute()
        )
        if avail_result.data:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Vendor is unavailable on the event date",
            )
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check vendor availability")
    # Prevent duplicate pending bookings
    try:
        dup_result = (
            supabase.table("bookings")
            .select("id")
            .eq("event_id", booking_data.event_id)
            .eq("vendor_id", booking_data.vendor_id)
            .eq("booking_status", "pending")
            .execute()
        )
        if dup_result.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A pending booking already exists for this vendor and event",
            )
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check duplicate bookings")
    # Insert booking
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
        "created_at": created_at,
    }
    try:
        result = supabase.table("bookings").insert(row).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to create booking")

# ----- Retrieval -----
def get_organizer_bookings(current_user: dict, supabase: Client):
    require_organizer(current_user)
    try:
        result = (
            supabase.table("bookings")
            .select("*")
            .eq("organizer_id", current_user["id"])
            .order("created_at", desc=True)
            .execute()
        )
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch bookings")

def get_vendor_bookings(current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    try:
        result = (
            supabase.table("bookings")
            .select("*")
            .eq("vendor_id", vendor_id)
            .order("created_at", desc=True)
            .execute()
        )
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch bookings")

# ----- Generic status update (kept for backward compatibility) -----
def update_booking_status(booking_id: str, status_update: BookingStatusUpdate, current_user: dict, supabase: Client):
    """Vendor updates a booking status with proper ownership validation and transition checks."""
    require_vendor(current_user)
    vendor_profile_id = get_vendor_profile_id(current_user, supabase)
    # Verify ownership and fetch booking
    try:
        result = supabase.table("bookings").select("*", "booking_status").eq("id", booking_id).execute()
        if not result.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        booking = result.data[0]
        if booking["vendor_id"] != vendor_profile_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only manage bookings assigned to you")
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")
    # Validate allowed transitions for vendor
    current_status = booking["booking_status"].lower()
    new_status = status_update.booking_status.lower()
    allowed = {
        "pending": ["accepted", "rejected", "cancelled"],
        "accepted": ["completed", "cancelled"],
        "rejected": [],
        "cancelled": [],
        "completed": [],
    }
    if new_status not in allowed.get(current_status, []):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid transition from {current_status} to {new_status}",
        )
    # Apply status update
    try:
        result = (
            supabase.table("bookings")
            .update({"booking_status": new_status})
            .eq("id", booking_id)
            .execute()
        )
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to update booking status")

# ----- Workflow specific functions -----
def accept_booking(booking_id: str, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    # Validate booking
    try:
        result = (
            supabase.table("bookings")
            .select("booking_status", "vendor_id")
            .eq("id", booking_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        booking = result.data[0]
        if booking["vendor_id"] != vendor_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your booking")
        if booking["booking_status"] != "pending":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only pending bookings can be accepted")
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")
    try:
        supabase.table("bookings").update({"booking_status": "accepted"}).eq("id", booking_id).execute()
        return {"message": "Booking accepted"}
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to accept booking")

def reject_booking(booking_id: str, reason: str | None, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    try:
        result = (
            supabase.table("bookings")
            .select("booking_status", "vendor_id")
            .eq("id", booking_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        booking = result.data[0]
        if booking["vendor_id"] != vendor_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your booking")
        if booking["booking_status"] != "pending":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only pending bookings can be rejected")
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")
    updates = {"booking_status": "rejected", "rejection_reason": reason}
    try:
        supabase.table("bookings").update(updates).eq("id", booking_id).execute()
        return {"message": "Booking rejected"}
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to reject booking")

def cancel_booking(booking_id: str, current_user: dict, supabase: Client):
    require_organizer(current_user)
    try:
        result = (
            supabase.table("bookings")
            .select("booking_status", "organizer_id")
            .eq("id", booking_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        booking = result.data[0]
        if booking["organizer_id"] != current_user["id"]:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your booking")
        if booking["booking_status"] not in ["pending", "accepted"]:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only pending or accepted bookings can be cancelled")
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")
    try:
        supabase.table("bookings").update({"booking_status": "cancelled"}).eq("id", booking_id).execute()
        return {"message": "Booking cancelled"}
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to cancel booking")

def complete_booking(booking_id: str, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor_id = get_vendor_profile_id(current_user, supabase)
    try:
        result = (
            supabase.table("bookings")
            .select("booking_status", "vendor_id")
            .eq("id", booking_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        booking = result.data[0]
        if booking["vendor_id"] != vendor_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your booking")
        if booking["booking_status"] != "accepted":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only accepted bookings can be completed")
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch booking")
    try:
        supabase.table("bookings").update({"booking_status": "completed"}).eq("id", booking_id).execute()
        return {"message": "Booking completed"}
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to complete booking")
