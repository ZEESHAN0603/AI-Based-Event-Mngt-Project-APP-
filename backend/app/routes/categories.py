from fastapi import APIRouter, Depends
from typing import List
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.vendor_schema import CategoryResponse
from app.services.vendor_service import get_categories
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryResponse])
def api_get_categories(current_user: dict = Depends(get_current_user), supabase: Client = Depends(get_supabase)):
    """Get all vendor categories. Requires authentication."""
    return get_categories(supabase)
