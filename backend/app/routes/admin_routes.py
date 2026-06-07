from fastapi import APIRouter, Depends
from app.dependencies.admin import admin_required
from app.services.admin_service import (
    get_dashboard_stats,
    list_vendors,
    list_pending_vendors,
    set_vendor_approval,
    list_users,
    set_user_status,
)
from app.schemas.admin_schemas import (
    DashboardStats, 
    UserStatusUpdate, 
    VendorRejectRequest,
    AnalyticsStats,
    AdminProfile,
    AdminProfileUpdate
)
from app.config.supabase import get_supabase

router = APIRouter(prefix="/admin", tags=["admin"], dependencies=[Depends(admin_required)])

@router.get("/dashboard", response_model=DashboardStats)
def dashboard():
    client = get_supabase()
    return get_dashboard_stats(client)

@router.get("/vendors")
def get_vendors():
    client = get_supabase()
    return list_vendors(client)

@router.get("/vendors/pending")
def get_pending_vendors():
    client = get_supabase()
    return list_pending_vendors(client)

@router.patch("/vendors/{vendor_id}/approve")
def approve_vendor(vendor_id: str, admin: dict = Depends(admin_required)):
    client = get_supabase()
    set_vendor_approval(vendor_id, True, admin["id"], client)
    return {"message": "Vendor approved successfully"}

@router.patch("/vendors/{vendor_id}/reject")
def reject_vendor(vendor_id: str, payload: VendorRejectRequest, admin: dict = Depends(admin_required)):
    client = get_supabase()
    set_vendor_approval(vendor_id, False, admin["id"], client, reason=payload.reason)
    return {"message": "Vendor rejected"}

@router.get("/users")
def get_users():
    client = get_supabase()
    return list_users(client)

@router.put("/users/{user_id}/status")
def update_user_status(user_id: str, payload: UserStatusUpdate):
    client = get_supabase()
    return set_user_status(user_id, payload.enabled, client)

@router.get("/events")
def get_all_events():
    from app.services.admin_service import list_events
    client = get_supabase()
    return list_events(client).data

@router.get("/bookings")
def get_all_bookings():
    from app.services.admin_service import list_bookings
    client = get_supabase()
    return list_bookings(client).data

@router.get("/analytics", response_model=AnalyticsStats)
def get_analytics():
    from app.services.admin_service import get_analytics_stats
    client = get_supabase()
    return get_analytics_stats(client)

@router.get("/profile", response_model=AdminProfile)
def get_profile(admin: dict = Depends(admin_required)):
    from app.services.admin_service import get_admin_profile
    client = get_supabase()
    return get_admin_profile(admin["id"], client)

@router.put("/profile", response_model=AdminProfile)
def update_profile(payload: AdminProfileUpdate, admin: dict = Depends(admin_required)):
    from app.services.admin_service import update_admin_profile
    client = get_supabase()
    return update_admin_profile(admin["id"], payload.model_dump(exclude_unset=True), client)
