from supabase import Client
from ..schemas.admin_schemas import DashboardStats, VendorRejectRequest, VendorStatusResponse
from datetime import datetime
from typing import Optional


def _extract_count(response):
    """Helper to get count from Supabase APIResponse."""
    if hasattr(response, 'count'):
        return response.count
    return len(response.data) if response.data else 0


def get_dashboard_stats(supabase: Client) -> DashboardStats:
    users_res = supabase.table("users").select("id", count="exact").execute()
    vendors_res = supabase.table("vendors").select("id", count="exact").execute()
    events_res = supabase.table("events").select("id", count="exact").execute()
    bookings_res = supabase.table("bookings").select("id", count="exact").execute()
    pending_vendors_res = supabase.table("vendors").select("id", count="exact").eq("approved", False).execute()

    return DashboardStats(
        total_users=_extract_count(users_res),
        total_vendors=_extract_count(vendors_res),
        total_events=_extract_count(events_res),
        total_bookings=_extract_count(bookings_res),
        pending_vendors=_extract_count(pending_vendors_res),
    )

def list_vendors(supabase: Client):
    return supabase.table("vendors").select("*").execute()

def list_pending_vendors(supabase: Client):
    return supabase.table("vendors").select("*").eq("approved", False).execute()

def set_vendor_approval(vendor_id: str, approved: bool, admin_id: str, supabase: Client, reason: Optional[str] = None):
    """Update vendor approval status.
    Parameters:
        vendor_id: ID of the vendor to update.
        approved: True for approval, False for rejection.
        admin_id: ID of the admin performing the action.
        supabase: Supabase client.
        reason: Optional rejection reason when approved is False.
    """
    update_fields = {
        "approved": approved,
        "approval_status": "approved" if approved else "rejected",
    }
    if approved:
        update_fields["approved_by"] = admin_id
        update_fields["approved_at"] = datetime.utcnow().isoformat()
        update_fields["rejection_reason"] = None
    else:
        update_fields["rejection_reason"] = reason or ""
        update_fields["approved_by"] = None
        update_fields["approved_at"] = None
    return supabase.table("vendors").update(update_fields).eq("id", vendor_id).execute()

def list_users(supabase: Client):
    return supabase.table("users").select("*").execute()

def set_user_status(user_id: str, enabled: bool, supabase: Client):
    return supabase.table("users").update({"enabled": enabled}).eq("id", user_id).execute()

def list_events(supabase: Client):
    return supabase.table("events").select("*").execute()

def list_bookings(supabase: Client):
    return supabase.table("bookings").select("*").execute()

def get_analytics_stats(supabase: Client):
    # Dummy computation to avoid complex heavy db aggregations for now.
    # In a real scenario, this would aggregate data from bookings, users, and events.
    # We will simulate the growth data structure required by the frontend but fetch actual totals.
    users_res = supabase.table("users").select("id", count="exact").execute()
    vendors_res = supabase.table("vendors").select("id", count="exact").execute()
    events_res = supabase.table("events").select("id", count="exact").execute()
    
    total_users = _extract_count(users_res)
    total_vendors = _extract_count(vendors_res)
    total_events = _extract_count(events_res)
    
    # Let's sum up total amount of confirmed bookings if we can. Or just dummy it.
    bookings_res = supabase.table("bookings").select("total_amount").eq("booking_status", "confirmed").execute()
    net_revenue = sum([b.get("total_amount", 0) for b in bookings_res.data]) if bookings_res.data else 0

    return {
        "monthly_growth": 15.5,
        "active_users": total_users + total_vendors,
        "event_volume": total_events,
        "net_revenue": net_revenue,
        "growth_data": [
            {"month": "Jan", "vendors": 10, "organizers": 2, "revenue": 5000},
            {"month": "Feb", "vendors": 15, "organizers": 4, "revenue": 8000},
            {"month": "Mar", "vendors": 22, "organizers": 6, "revenue": 15000},
            {"month": "Apr", "vendors": 31, "organizers": 8, "revenue": 28000},
            {"month": "May", "vendors": 42, "organizers": 10, "revenue": 42000},
            {"month": "Jun", "vendors": total_vendors, "organizers": total_users, "revenue": net_revenue},
        ],
        "category_stats": [
            {"name": "Wedding Hall", "value": 45, "color": "#5B4CF0"},
            {"name": "Catering", "value": 30, "color": "#3EA0FF"},
            {"name": "Decoration", "value": 15, "color": "#F4A622"},
            {"name": "Photographer", "value": 10, "color": "#C56CE6"},
        ]
    }

def get_admin_profile(admin_id: str, supabase: Client):
    res = supabase.table("admin_settings").select("*").eq("admin_id", admin_id).execute()
    if res.data:
        return res.data[0]
    return {
        "admin_id": admin_id,
        "display_name": "Admin User",
        "timezone": "UTC",
        "theme": "light",
        "notifications_enabled": True
    }

def update_admin_profile(admin_id: str, profile_data: dict, supabase: Client):
    # Check if exists
    res = supabase.table("admin_settings").select("id").eq("admin_id", admin_id).execute()
    payload = {k: v for k, v in profile_data.items() if v is not None}
    
    if res.data:
        updated = supabase.table("admin_settings").update(payload).eq("admin_id", admin_id).execute()
        return updated.data[0] if updated.data else {}
    else:
        payload["admin_id"] = admin_id
        inserted = supabase.table("admin_settings").insert(payload).execute()
        return inserted.data[0] if inserted.data else {}
