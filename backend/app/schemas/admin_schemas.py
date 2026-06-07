from pydantic import BaseModel
from typing import Optional

class DashboardStats(BaseModel):
    total_users: int
    total_vendors: int
    total_events: int
    total_bookings: int
    pending_vendors: int

class VendorStatusUpdate(BaseModel):
    approved: bool

class VendorRejectRequest(BaseModel):
    reason: str

class VendorStatusResponse(BaseModel):
    status: str
    reason: Optional[str] = None

class UserStatusUpdate(BaseModel):
    enabled: bool
