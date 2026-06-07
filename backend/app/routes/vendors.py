from fastapi import APIRouter, Depends, Query
from typing import List, Optional
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.vendor_schema import VendorProfileCreate, VendorProfileUpdate, VendorResponse
from app.services.vendor_service import create_vendor_profile, update_vendor_profile, get_approved_vendors, get_vendor_by_id
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/vendors", tags=["Vendors"])

@router.post("/profile", response_model=VendorResponse, status_code=201)
def api_create_vendor_profile(profile: VendorProfileCreate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Create a new vendor profile. Only allowed for vendors."""
    return create_vendor_profile(profile, current_user, supabase)

@router.put("/profile", response_model=VendorResponse)
def api_update_vendor_profile(profile_update: VendorProfileUpdate, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Update own vendor profile. Only allowed for vendors."""
    return update_vendor_profile(profile_update, current_user, supabase)

@router.get("/", response_model=List[VendorResponse])
def api_get_vendors(
    category_id: Optional[str] = None,
    location: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    q: Optional[str] = Query(None, alias="q"),
    available_date: Optional[str] = Query(None),
    sort_by: Optional[str] = Query(
    None,
    pattern="^(name|price_low_high|price_high_low|newest)$"
),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_supabase)
):
    """Get all approved vendors. Supports filtering, search, availability and sorting."""
    return get_approved_vendors(
        supabase,
        category_id=category_id,
        location=location,
        min_price=min_price,
        max_price=max_price,
        search=q,
        available_date=available_date,
        sort_by=sort_by,
    )

@router.get("/{vendor_id}", response_model=VendorResponse)
def api_get_vendor(vendor_id: str, supabase: Client = Depends(get_supabase)):
    """Get specific approved vendor details."""
    return get_vendor_by_id(vendor_id, supabase)
