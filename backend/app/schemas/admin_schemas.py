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

class CategoryDistribution(BaseModel):
    name: str
    value: int
    color: str

class MonthlyGrowth(BaseModel):
    month: str
    vendors: int
    organizers: int
    revenue: float

class AnalyticsStats(BaseModel):
    monthly_growth: float
    active_users: int
    event_volume: int
    net_revenue: float
    growth_data: list[MonthlyGrowth]
    category_stats: list[CategoryDistribution]

class AdminProfile(BaseModel):
    display_name: str
    timezone: str
    theme: str
    notifications_enabled: bool

class AdminProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    timezone: Optional[str] = None
    theme: Optional[str] = None
    notifications_enabled: Optional[bool] = None
