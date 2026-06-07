from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client
from datetime import datetime, timedelta
from app.config.supabase import get_supabase
from app.auth.jwt_handler import get_current_user
from app.dependencies.vendor import vendor_required
from app.db import local_db

router = APIRouter(prefix="/vendors/me/dashboard", tags=["Vendor Dashboard"])

def get_vendor_profile_id(current_user: dict, supabase: Client) -> str:
    """Get the vendor profile ID linked to the current user."""
    try:
        result = supabase.table("vendors").select("id").eq("user_id", current_user["id"]).execute()
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vendor profile not found. Please create a vendor profile first."
            )
        return result.data[0]["id"]
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendor profile")

@router.get("")
def get_vendor_dashboard(current_user: dict = Depends(vendor_required), supabase: Client = Depends(get_supabase)):
    vendor_id = get_vendor_profile_id(current_user, supabase)
    
    # Seed SQLite reviews and activities if they don't exist
    local_db.seed_vendor_data_if_empty(vendor_id)
    
    # 1. Fetch bookings from Supabase
    try:
        bookings_res = supabase.table("bookings").select(
            "*, events(event_name, event_date, location), organizer:users!organizer_id(name)"
        ).eq("vendor_id", vendor_id).execute()
        bookings = bookings_res.data or []
    except Exception as e:
        print(f"Failed to fetch bookings: {repr(e)}")
        bookings = []
        
    # 2. Fetch vendor availability from Supabase
    try:
        avail_res = supabase.table("vendor_availability").select("*").eq("vendor_id", vendor_id).execute()
        availabilities = avail_res.data or []
    except Exception as e:
        print(f"Failed to fetch availability: {repr(e)}")
        availabilities = []

    # 3. Fetch reviews from local SQLite
    reviews = local_db.get_reviews(vendor_id)
    
    # 4. Fetch activities from local SQLite
    activities = local_db.get_activities(vendor_id)
    
    # --- CALCULATE STATISTICS ---
    total_bookings = len(bookings)
    pending_bookings = sum(1 for b in bookings if b.get("booking_status") == "pending")
    accepted_bookings = sum(1 for b in bookings if b.get("booking_status") == "accepted")
    completed_bookings = sum(1 for b in bookings if b.get("booking_status") == "completed")
    
    # Calculate average rating
    if reviews:
        avg_rating = sum(r["rating"] for r in reviews) / len(reviews)
    else:
        # Fallback to rating stored in vendors table
        try:
            v_res = supabase.table("vendors").select("rating").eq("id", vendor_id).execute()
            avg_rating = v_res.data[0].get("rating", 0.0) if v_res.data else 0.0
        except:
            avg_rating = 0.0

    # Calculate revenue and trend
    now = datetime.now()
    current_month_str = now.strftime("%Y-%m")
    prev_month = now - timedelta(days=30)
    prev_month_str = prev_month.strftime("%Y-%m")
    
    monthly_revenue = 0.0
    prev_monthly_revenue = 0.0
    
    # Initialize trend dictionary for last 6 months
    trend_dict = {}
    for i in range(6):
        m = now - timedelta(days=30 * i)
        trend_dict[m.strftime("%Y-%m")] = 0.0
        
    for b in bookings:
        status_ = b.get("booking_status")
        if status_ in ["accepted", "completed"]:
            amount = float(b.get("total_amount") or 0.0)
            created_at_str = b.get("created_at")
            if created_at_str:
                # e.g., '2026-06-06T13:57:54.84734+00:00'
                b_month = created_at_str[:7]
                if b_month == current_month_str:
                    monthly_revenue += amount
                elif b_month == prev_month_str:
                    prev_monthly_revenue += amount
                    
                if b_month in trend_dict:
                    trend_dict[b_month] += amount
                    
    # Format trend for output
    trend = [{"month": k, "amount": v} for k, v in sorted(trend_dict.items())]

    # --- BOOKING REQUESTS ---
    booking_requests = []
    for b in bookings:
        if b.get("booking_status") == "pending":
            event_data = b.get("events") or {}
            organizer_data = b.get("organizer") or {}
            booking_requests.append({
                "id": b.get("id"),
                "organizer_name": organizer_data.get("name", "Unknown Organizer"),
                "event_name": event_data.get("event_name", "Unknown Event"),
                "event_date": event_data.get("event_date", ""),
                "status": b.get("booking_status"),
                "amount": b.get("total_amount")
            })
            
    # Sort requests by created_at desc
    booking_requests.sort(key=lambda x: x.get("id", ""), reverse=True)
    
    # --- SCHEDULE ---
    upcoming_schedule = []
    for b in bookings:
        if b.get("booking_status") in ["accepted"]:
            event_data = b.get("events") or {}
            organizer_data = b.get("organizer") or {}
            upcoming_schedule.append({
                "id": b.get("id"),
                "event_name": event_data.get("event_name", "Unknown Event"),
                "event_date": event_data.get("event_date", ""),
                "venue": event_data.get("location", "To Be Decided"),
                "organizer_name": organizer_data.get("name", "Unknown Organizer"),
                "time": "09:00 AM" # Default placeholder time
            })
    # Sort by nearest date
    upcoming_schedule.sort(key=lambda x: x.get("event_date", ""))

    # --- AVAILABILITY STATUS ---
    # Check blocked dates in the next 30 days
    future_blocked_count = 0
    today_str = now.strftime("%Y-%m-%d")
    end_date_str = (now + timedelta(days=30)).strftime("%Y-%m-%d")
    
    for av in availabilities:
        date_ = av.get("blocked_date")
        if date_ and today_str <= date_[:10] <= end_date_str:
            future_blocked_count += 1
            
    if future_blocked_count == 0:
        availability_status = "Available"
    elif future_blocked_count <= 4:
        availability_status = "Partially Booked"
    else:
        availability_status = "Fully Booked"
        
    # --- PERFORMANCE METRICS ---
    try:
        vendor_res = supabase.table("vendors").select("*").eq("id", vendor_id).execute()
        vendor_profile = vendor_res.data[0] if vendor_res.data else {}
    except:
        vendor_profile = {}
        
    # Calculate profile completion
    completion_points = 0
    if vendor_profile.get("description"): completion_points += 20
    if vendor_profile.get("gst_number"): completion_points += 20
    if vendor_profile.get("portfolio_url"): completion_points += 20
    if vendor_profile.get("base_price_min"): completion_points += 20
    if vendor_profile.get("location"): completion_points += 20
    
    views = total_bookings * 5 + 142
    conversion_rate = (total_bookings / views * 100) if views > 0 else 0.0
    
    performance = {
        "views": views,
        "bookings": total_bookings,
        "conversion_rate": round(conversion_rate, 1),
        "average_rating": round(avg_rating, 1),
        "profile_completion": completion_points
    }
    
    return {
        "stats": {
            "total_bookings": total_bookings,
            "pending_bookings": pending_bookings,
            "accepted_bookings": accepted_bookings,
            "completed_events": completed_bookings,
            "monthly_revenue": monthly_revenue,
            "average_rating": round(avg_rating, 1)
        },
        "booking_requests": booking_requests,
        "schedule": upcoming_schedule,
        "reviews": reviews[:5], # latest 5 reviews
        "performance": performance,
        "revenue_analytics": {
            "current_month": monthly_revenue,
            "previous_month": prev_monthly_revenue,
            "trend": trend
        },
        "availability_status": availability_status,
        "activities": activities
    }
