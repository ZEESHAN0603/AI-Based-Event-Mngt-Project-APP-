from fastapi import HTTPException, status
from supabase import Client
from app.schemas.recommendation_schema import RecommendationRequest, RecommendationItem, RecommendationResponse
from typing import Optional

def require_organizer(user: dict):
    if user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can request recommendations"
        )

def generate_recommendations(req: RecommendationRequest, current_user: dict, supabase: Client) -> RecommendationResponse:
    require_organizer(current_user)

    # ── Step 1: Fetch event details and verify ownership ──
    try:
        event_result = supabase.table("events").select("*").eq("id", req.event_id).eq("organizer_id", current_user["id"]).execute()
        if not event_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found or you don't have access"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR (event): {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch event")

    event = event_result.data[0]
    event_budget = float(event.get("budget", 0))
    event_location = (event.get("location") or "").lower().strip()
    event_date_str = str(event.get("event_date", ""))[:10]  # YYYY-MM-DD

    # ── Step 2: Fetch approved vendors ──
    try:
        vendor_query = supabase.table("vendors").select("*").eq("approved", True)
        if req.category_id:
            vendor_query = vendor_query.eq("category_id", req.category_id)
        vendor_result = vendor_query.execute()
    except Exception as e:
        print(f"SUPABASE SELECT ERROR (vendors): {repr(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch vendors")

    vendors = vendor_result.data or []

    if not vendors:
        return RecommendationResponse(
            event_id=req.event_id,
            total_recommendations=0,
            recommendations=[]
        )

    vendor_ids = [v["id"] for v in vendors]

    # ── Step 3: Fetch blocked dates to exclude unavailable vendors ──
    blocked_vendor_ids = set()
    if event_date_str:
        try:
            avail_result = supabase.table("vendor_availability").select("vendor_id").eq("blocked_date", event_date_str).execute()
            if avail_result.data:
                blocked_vendor_ids = {row["vendor_id"] for row in avail_result.data}
        except Exception as e:
            print(f"SUPABASE SELECT ERROR (availability): {repr(e)}")
            # Non-fatal: continue without availability filtering

    # Filter out unavailable vendors
    available_vendors = [v for v in vendors if v["id"] not in blocked_vendor_ids]

    if not available_vendors:
        return RecommendationResponse(
            event_id=req.event_id,
            total_recommendations=0,
            recommendations=[]
        )

    # ── Step 4-6: Score and rank vendors ──
    scored_vendors = []
    for vendor in available_vendors:
        score, reasons = _calculate_score(vendor, event_budget, event_location)
        scored_vendors.append((vendor, score, reasons))

    # Sort by score descending
    scored_vendors.sort(key=lambda x: x[1], reverse=True)

    recommendations = []
    for vendor, score, reasons in scored_vendors:
        reason_text = ". ".join(reasons) if reasons else "Available on your event date"
        recommendations.append(
            RecommendationItem(
                vendor_id=vendor["id"],
                business_name=vendor["business_name"],
                category_id=vendor.get("category_id", ""),
                location=vendor.get("location", ""),
                rating=float(vendor.get("rating", 0)),
                base_price_min=float(vendor.get("base_price_min", 0)),
                base_price_max=float(vendor.get("base_price_max", 0)),
                recommendation_score=round(score, 2),
                recommendation_reason=reason_text
            )
        )

    return RecommendationResponse(
        event_id=req.event_id,
        total_recommendations=len(recommendations),
        recommendations=recommendations
    )


def _calculate_score(vendor: dict, event_budget: float, event_location: str) -> tuple:
    """
    Scoring formula:
      Score = (0.4 × rating_score) + (0.3 × budget_score) + (0.3 × location_score)

    Each component is normalized to 0.0 – 1.0 range.
    Returns (score, list_of_reasons).
    """
    reasons = []

    # ── Rating score (0.0 – 1.0) ──
    vendor_rating = float(vendor.get("rating", 0))
    rating_score = min(vendor_rating / 5.0, 1.0)  # Assuming 5.0 is max rating
    if vendor_rating >= 4.0:
        reasons.append("Highly rated vendor")

    # ── Budget score (0.0 – 1.0) ──
    base_price_min = float(vendor.get("base_price_min", 0))
    base_price_max = float(vendor.get("base_price_max", 0))
    budget_score = 0.0
    if event_budget > 0:
        if base_price_min <= event_budget:
            if base_price_max <= event_budget:
                budget_score = 1.0
                reasons.append("Fits within your event budget")
            else:
                # Partial fit: vendor's min is within budget but max exceeds
                budget_score = 0.6
                reasons.append("Partially fits your budget range")
        else:
            # Vendor is above budget
            budget_score = 0.0
    else:
        # No budget info, give neutral score
        budget_score = 0.5

    # ── Location score (0.0 – 1.0) ──
    vendor_location = (vendor.get("location") or "").lower().strip()
    location_score = 0.0
    if event_location and vendor_location:
        if vendor_location == event_location:
            location_score = 1.0
            reasons.append("Located in your event city")
        elif event_location in vendor_location or vendor_location in event_location:
            location_score = 0.6
            reasons.append("Near your event location")
        else:
            location_score = 0.1
    else:
        location_score = 0.3

    # Always add availability reason
    reasons.append("Available on your event date")

    # Final weighted score
    score = (0.4 * rating_score) + (0.3 * budget_score) + (0.3 * location_score)
    return score, reasons
