from fastapi import APIRouter, Depends, HTTPException
from app.dependencies.vendor import vendor_required
from app.config.supabase import get_supabase
from app.schemas.admin_schemas import VendorStatusResponse

router = APIRouter(prefix="/vendor", tags=["Vendor Approval"])

@router.get("/approval-status", response_model=VendorStatusResponse)
def get_approval_status(current_user: dict = Depends(vendor_required)):
    """Return the approval status for the authenticated vendor.
    Returns status = pending|approved|rejected and optional reason.
    """
    supabase = get_supabase()
    result = (
        supabase.table("vendors")
        .select("approval_status", "rejection_reason")
        .eq("user_id", current_user["id"]).single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="Vendor profile not found")
    return {
        "status": result.data.get("approval_status", "pending"),
        "reason": result.data.get("rejection_reason"),
    }
