from pydantic import BaseModel
from datetime import date, datetime

class BlockDateCreate(BaseModel):
    blocked_date: date

class AvailabilityResponse(BaseModel):
    id: str
    vendor_id: str
    blocked_date: date
    status: str
    created_at: datetime
