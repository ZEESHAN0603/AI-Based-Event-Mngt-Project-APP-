from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class VendorProfileCreate(BaseModel):
    category_id: str
    business_name: str
    description: str
    location: str
    base_price_min: float
    base_price_max: float
    gst_number: str
    portfolio_url: Optional[str] = None

class VendorProfileUpdate(BaseModel):
    category_id: Optional[str] = None
    business_name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    base_price_min: Optional[float] = None
    base_price_max: Optional[float] = None
    gst_number: Optional[str] = None
    portfolio_url: Optional[str] = None

class VendorResponse(VendorProfileCreate):
    id: str
    user_id: str
    rating: float
    total_reviews: int
    approved: bool
    approval_status: str
    approved_by: Optional[int] = None
    approved_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    created_at: datetime

class CategoryResponse(BaseModel):
    id: str
    name: str
