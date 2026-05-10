from fastapi import HTTPException, status
from supabase import Client
from app.schemas.availability_schema import BlockDateCreate
import uuid
from datetime import datetime, timezone

def require_vendor(user: dict):
    if user.get("role") != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendors can perform this action"
        )

def get_vendor_profile(current_user: dict, supabase: Client) -> dict:
    """Fetch the vendor profile for the current user. Raises 404 if not found."""
    try:
        result = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor profile not found. Create a vendor profile first."
            )
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendor profile")

def block_date(block_data: BlockDateCreate, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor = get_vendor_profile(current_user, supabase)
    vendor_id = vendor["id"]
    
    blocked_date_str = block_data.blocked_date.isoformat()
    
    # Check for duplicate blocked date
    try:
        existing = supabase.table("vendor_availability").select("id").eq("vendor_id", vendor_id).eq("blocked_date", blocked_date_str).execute()
        if existing.data and len(existing.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This date is already blocked"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to check existing blocked dates")

    availability_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    row = {
        "id": availability_id,
        "vendor_id": vendor_id,
        "blocked_date": blocked_date_str,
        "status": "blocked",
        "created_at": created_at
    }
    
    try:
        result = supabase.table("vendor_availability").insert(row).execute()
        return result.data[0]
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to block date")

def remove_blocked_date(availability_id: str, current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor = get_vendor_profile(current_user, supabase)
    vendor_id = vendor["id"]
    
    # Fetch and verify ownership
    try:
        result = supabase.table("vendor_availability").select("*").eq("id", availability_id).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Blocked date not found"
            )
        if result.data[0]["vendor_id"] != vendor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only remove your own blocked dates"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to verify blocked date ownership")

    try:
        supabase.table("vendor_availability").delete().eq("id", availability_id).execute()
        return {"message": "Blocked date removed successfully"}
    except Exception as e:
        print(f"SUPABASE DELETE ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to remove blocked date")

def get_my_availability(current_user: dict, supabase: Client):
    require_vendor(current_user)
    vendor = get_vendor_profile(current_user, supabase)
    vendor_id = vendor["id"]
    
    try:
        result = supabase.table("vendor_availability").select("*").eq("vendor_id", vendor_id).order("blocked_date").execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch availability")

def get_vendor_availability(vendor_id: str, supabase: Client):
    """Public endpoint — any authenticated user can check a vendor's blocked dates."""
    try:
        result = supabase.table("vendor_availability").select("*").eq("vendor_id", vendor_id).order("blocked_date").execute()
        return result.data
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendor availability")
