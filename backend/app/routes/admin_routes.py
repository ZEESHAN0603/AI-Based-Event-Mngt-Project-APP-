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
from app.schemas.admin_schemas import DashboardStats, UserStatusUpdate
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

@router.put("/vendors/{vendor_id}/approve")
def approve_vendor(vendor_id: str):
    client = get_supabase()
    return set_vendor_approval(vendor_id, True, client)

@router.put("/vendors/{vendor_id}/reject")
def reject_vendor(vendor_id: str):
    client = get_supabase()
    return set_vendor_approval(vendor_id, False, client)

@router.get("/users")
def get_users():
    client = get_supabase()
    return list_users(client)

@router.put("/users/{user_id}/status")
def update_user_status(user_id: str, payload: UserStatusUpdate):
    client = get_supabase()
    return set_user_status(user_id, payload.enabled, client)
