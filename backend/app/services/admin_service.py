from supabase import Client
from ..schemas.admin_schemas import DashboardStats

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

def set_vendor_approval(vendor_id: str, approved: bool, supabase: Client):
    return supabase.table("vendors").update({"approved": approved}).eq("id", vendor_id).execute()

def list_users(supabase: Client):
    return supabase.table("users").select("*").execute()

def set_user_status(user_id: str, enabled: bool, supabase: Client):
    return supabase.table("users").update({"enabled": enabled}).eq("id", user_id).execute()
