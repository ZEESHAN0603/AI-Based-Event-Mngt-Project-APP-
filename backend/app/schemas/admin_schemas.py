from pydantic import BaseModel

class DashboardStats(BaseModel):
    total_users: int
    total_vendors: int
    total_events: int
    total_bookings: int
    pending_vendors: int

class VendorStatusUpdate(BaseModel):
    approved: bool

class UserStatusUpdate(BaseModel):
    enabled: bool
