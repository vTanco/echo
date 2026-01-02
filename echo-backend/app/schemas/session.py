from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class SessionStart(BaseModel):
    device_id: str


class SessionResponse(BaseModel):
    id: str
    user_id: str
    device_id: str
    start_time: datetime
    end_time: Optional[datetime]
    status: str
    tasks_completed: float
    tasks_failed: float
    earnings: float
    compute_hours: float
    duration_hours: float
    
    class Config:
        from_attributes = True


class SessionHistory(BaseModel):
    sessions: List[SessionResponse]
    total_count: int
    total_earnings: float
    total_hours: float
