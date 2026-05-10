from fastapi import APIRouter, Depends
from typing import List
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.availability_schema import BlockDateCreate, AvailabilityResponse
from app.services.availability_service import block_date, remove_blocked_date, get_my_availability, get_vendor_availability
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/availability", tags=["Availability"])

@router.post("/block", response_model=AvailabilityResponse, status_code=201)
def api_block_date(block_data: BlockDateCreate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Block a date for the vendor. Only allowed for vendors with a profile."""
    return block_date(block_data, current_user, supabase)

@router.delete("/{availability_id}", status_code=200)
def api_remove_blocked_date(availability_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Remove a blocked date. Only allowed for the vendor who owns it."""
    return remove_blocked_date(availability_id, current_user, supabase)

@router.get("/me", response_model=List[AvailabilityResponse])
def api_get_my_availability(current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all blocked dates for the current vendor."""
    return get_my_availability(current_user, supabase)

@router.get("/{vendor_id}", response_model=List[AvailabilityResponse])
def api_get_vendor_availability(vendor_id: str, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get blocked dates for a specific vendor. Any authenticated user can view this."""
    return get_vendor_availability(vendor_id, supabase)
