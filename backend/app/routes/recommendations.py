from fastapi import APIRouter, Depends
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.recommendation_schema import RecommendationRequest, RecommendationResponse
from app.services.recommendation_service import generate_recommendations
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/ai", tags=["AI Recommendations"])

@router.post("/recommend", response_model=RecommendationResponse)
def api_recommend_vendors(req: RecommendationRequest, current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """
    Generate intelligent vendor recommendations for an event.
    Scores vendors based on rating, budget fit, location match, and availability.
    Only allowed for organizers who own the event.
    """
    return generate_recommendations(req, current_user, supabase)
