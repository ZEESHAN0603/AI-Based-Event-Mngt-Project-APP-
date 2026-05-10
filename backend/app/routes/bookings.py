from fastapi import APIRouter, Depends
from typing import List
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.booking_schema import BookingCreate, BookingStatusUpdate, BookingResponse
from app.services.booking_service import create_booking, get_organizer_bookings, get_vendor_bookings, update_booking_status
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/bookings", tags=["Bookings"])

@router.post("", response_model=BookingResponse, status_code=201)
def api_create_booking(booking_data: BookingCreate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Create a booking request. Only allowed for organizers who own the event."""
    return create_booking(booking_data, current_user, supabase)

@router.get("/me", response_model=List[BookingResponse])
def api_get_organizer_bookings(current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all bookings created by the current organizer."""
    return get_organizer_bookings(current_user, supabase)

@router.get("/vendor", response_model=List[BookingResponse])
def api_get_vendor_bookings(current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all bookings assigned to the current vendor."""
    return get_vendor_bookings(current_user, supabase)

@router.put("/{booking_id}/status", response_model=BookingResponse)
def api_update_booking_status(booking_id: str, status_update: BookingStatusUpdate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Update booking status. Only allowed for the assigned vendor."""
    return update_booking_status(booking_id, status_update, current_user, supabase)
