from fastapi import APIRouter, Depends, Query
from typing import List, Optional

from app.auth.jwt_handler import get_current_user
from app.schemas.blog_schemas import BlogResponse
from app.services.blog_service import get_event_news

router = APIRouter(
    prefix="/blogs",
    tags=["Blogs"]
)

@router.get("", response_model=List[BlogResponse])
async def get_blogs(
    category: Optional[str] = Query(None, description="Supported categories: wedding, birthday, corporate, photography, catering, decoration, events"),
    current_user: dict = Depends(get_current_user)
):
    """Return up to 20 latest event‑related articles.
    The endpoint is protected by JWT authentication like other routes.
    """
    return get_event_news(category)
