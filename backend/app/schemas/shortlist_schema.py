from pydantic import BaseModel
from datetime import datetime

class ShortlistCreate(BaseModel):
    event_id: str
    vendor_id: str

class ShortlistResponse(BaseModel):
    id: str
    event_id: str
    vendor_id: str
    created_at: datetime
