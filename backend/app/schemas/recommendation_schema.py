from pydantic import BaseModel
from typing import Optional, List

class RecommendationRequest(BaseModel):
    event_id: str
    category_id: Optional[str] = None

class RecommendationItem(BaseModel):
    vendor_id: str
    business_name: str
    category_id: str
    location: str
    rating: float
    base_price_min: float
    base_price_max: float
    recommendation_score: float
    recommendation_reason: str

class RecommendationResponse(BaseModel):
    event_id: str
    total_recommendations: int
    recommendations: List[RecommendationItem]
