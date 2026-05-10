from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class EventCreate(BaseModel):
    event_name: str
    event_type: str
    event_date: datetime
    location: str
    budget: float
    guest_count: int
    description: Optional[str] = None

class EventUpdate(BaseModel):
    event_name: Optional[str] = None
    event_type: Optional[str] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = None
    budget: Optional[float] = None
    guest_count: Optional[int] = None
    description: Optional[str] = None

class EventResponse(EventCreate):
    id: str
    organizer_id: str
    created_at: datetime
