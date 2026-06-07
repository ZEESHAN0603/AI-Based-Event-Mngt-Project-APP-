from pydantic import BaseModel
from typing import Optional

class BlogResponse(BaseModel):
    title: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    source: Optional[str] = None
    published_at: Optional[str] = None
    url: str
