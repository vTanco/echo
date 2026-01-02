from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class DeviceBase(BaseModel):
    device_name: Optional[str] = None
    device_model: Optional[str] = None
    os_version: Optional[str] = None
    app_version: Optional[str] = None


class DeviceRegister(DeviceBase):
    device_token: str


class DeviceStatusUpdate(BaseModel):
    battery_level: Optional[float] = None
    is_charging: Optional[bool] = None
    is_on_wifi: Optional[bool] = None
    temperature: Optional[float] = None
    cpu_usage: Optional[float] = None
    memory_usage: Optional[float] = None


class DeviceResponse(DeviceBase):
    id: str
    user_id: str
    device_token: str
    battery_level: float
    is_charging: bool
    is_on_wifi: bool
    temperature: float
    cpu_usage: float
    memory_usage: float
    is_active: bool
    is_computing: bool
    is_ready_for_compute: bool
    last_seen: datetime
    registered_at: datetime
    total_tasks_completed: float
    total_compute_hours: float
    total_earnings: float
    
    class Config:
        from_attributes = True
