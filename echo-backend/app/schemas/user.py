from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    display_name: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    preferences: Optional[Dict[str, Any]] = None


class UserResponse(UserBase):
    id: str
    is_active: bool
    is_verified: bool
    total_earnings: float
    available_balance: float
    pending_withdrawal: float
    total_compute_hours: float
    preferences: Dict[str, Any]
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserStats(BaseModel):
    total_earnings: float
    available_balance: float
    pending_withdrawal: float
    total_compute_hours: float
    total_sessions: int
    total_tasks_completed: int
    devices_count: int
    today_earnings: float
    week_earnings: float
    month_earnings: float
    
    class Config:
        from_attributes = True
