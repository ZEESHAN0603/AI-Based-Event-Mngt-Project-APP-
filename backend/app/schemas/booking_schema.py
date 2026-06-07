from pydantic import BaseModel, field_validator
from typing import Optional
from datetime import datetime

class BookingCreate(BaseModel):
    event_id: str
    vendor_id: str
    total_amount: float
    notes: Optional[str] = None

class BookingRejectRequest(BaseModel):
    reason: Optional[str] = None

class BookingStatusUpdate(BaseModel):
    booking_status: str

    @field_validator('booking_status')
    @classmethod
    def validate_status(cls, v: str) -> str:
        v = v.lower()
        allowed = ['pending', 'accepted', 'rejected', 'cancelled', 'completed']
        if v not in allowed:
            raise ValueError(f'Status must be one of: {", ".join(allowed)}')
        return v

class BookingResponse(BaseModel):
    id: str
    event_id: str
    vendor_id: str
    organizer_id: str
    booking_status: str
    total_amount: float
    notes: Optional[str] = None
    rejection_reason: Optional[str] = None
    created_at: datetime
