from fastapi import HTTPException, status
from supabase import Client
from app.schemas.vendor_schema import VendorProfileCreate, VendorProfileUpdate
import uuid
from datetime import datetime, timezone
from typing import Optional

def require_vendor(user: dict):
    if user.get("role") != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendors can perform this action"
        )

def create_vendor_profile(profile: VendorProfileCreate, current_user: dict, supabase: Client):
    require_vendor(current_user)
    
    # Check if profile already exists for this user
    try:
        existing = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if existing.data and len(existing.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vendor profile already exists for this user"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check existing profile")

    vendor_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    vendor_data = profile.model_dump()
    vendor_data.update({
        "id": vendor_id,
        "user_id": current_user["id"],
        "rating": 0.0,
        "total_reviews": 0,
        "approved": False,
        "created_at": created_at
    })
    
    try:
        result = supabase.table("vendors").insert(vendor_data).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create vendor profile"
        )

def update_vendor_profile(profile_update: VendorProfileUpdate, current_user: dict, supabase: Client):
    require_vendor(current_user)
    
    # Check ownership implicitly by updating where user_id matches
    update_data = profile_update.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update"
        )
        
    try:
        # Fetch and verify existence
        existing = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor profile not found"
            )
        
        result = supabase.table("vendors").update(update_data).eq("user_id", current_user["id"]).execute()
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE UPDATE ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update vendor profile"
        )

def get_approved_vendors(
    supabase: Client,
    category_id: Optional[str] = None,
    location: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    search: Optional[str] = None
):
    try:
        query = supabase.table("vendors").select("*").eq("approved", True)
        
        if category_id:
            query = query.eq("category_id", category_id)
        if location:
            query = query.ilike("location", f"%{location}%")
        if min_price is not None:
            query = query.gte("base_price_min", min_price)
        if max_price is not None:
            query = query.lte("base_price_max", max_price)
        if search:
            query = query.or_(f"business_name.ilike.%{search}%,location.ilike.%{search}%")
            
        result = query.execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch vendors"
        )

def get_vendor_by_id(vendor_id: str, supabase: Client):
    try:
        result = supabase.table("vendors").select("*").eq("id", vendor_id).eq("approved", True).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor not found or not approved"
            )
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch vendor"
        )

def get_categories(supabase: Client):
    try:
        result = supabase.table("vendor_categories").select("*").execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch categories"
        )
