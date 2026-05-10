from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import datetime

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str
    phone: Optional[str] = None
    city: Optional[str] = None

    @field_validator('role')
    @classmethod
    def validate_role(cls, v: str) -> str:
        v = v.lower()
        if v not in ['organizer', 'vendor', 'admin']:
            raise ValueError('Role must be organizer, vendor, or admin')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserResponse(BaseModel):
    id: str
    name: str
    email: EmailStr
    role: str
    phone: Optional[str] = None
    city: Optional[str] = None
    created_at: datetime
