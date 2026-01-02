from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from typing import Optional, List
from datetime import datetime

from ..models.device import Device
from ..schemas.device import DeviceRegister, DeviceStatusUpdate


class DeviceService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_device_by_id(self, device_id: str) -> Optional[Device]:
        """Get device by ID."""
        result = await self.db.execute(
            select(Device).where(Device.id == device_id)
        )
        return result.scalar_one_or_none()
    
    async def get_device_by_token(self, device_token: str) -> Optional[Device]:
        """Get device by token."""
        result = await self.db.execute(
            select(Device).where(Device.device_token == device_token)
        )
        return result.scalar_one_or_none()
    
    async def get_user_devices(self, user_id: str) -> List[Device]:
        """Get all devices for a user."""
        result = await self.db.execute(
            select(Device).where(Device.user_id == user_id)
        )
        return list(result.scalars().all())
    
    async def register_device(self, user_id: str, data: DeviceRegister) -> Device:
        """Register a new device or update existing."""
        # Check if device already exists
        existing = await self.get_device_by_token(data.device_token)
        
        if existing:
            # Update existing device
            existing.user_id = user_id
            existing.device_name = data.device_name or existing.device_name
            existing.device_model = data.device_model or existing.device_model
            existing.os_version = data.os_version or existing.os_version
            existing.app_version = data.app_version or existing.app_version
            existing.last_seen = datetime.utcnow()
            existing.is_active = True
            await self.db.flush()
            await self.db.refresh(existing)
            return existing
        
        # Create new device
        device = Device(
            user_id=user_id,
            device_token=data.device_token,
            device_name=data.device_name,
            device_model=data.device_model,
            os_version=data.os_version,
            app_version=data.app_version
        )
        self.db.add(device)
        await self.db.flush()
        await self.db.refresh(device)
        return device
    
    async def update_device_status(self, device_id: str, data: DeviceStatusUpdate) -> Device:
        """Update device status (battery, wifi, etc)."""
        device = await self.get_device_by_id(device_id)
        if not device:
            raise ValueError("Device not found")
        
        if data.battery_level is not None:
            device.battery_level = data.battery_level
        if data.is_charging is not None:
            device.is_charging = data.is_charging
        if data.is_on_wifi is not None:
            device.is_on_wifi = data.is_on_wifi
        if data.temperature is not None:
            device.temperature = data.temperature
        if data.cpu_usage is not None:
            device.cpu_usage = data.cpu_usage
        if data.memory_usage is not None:
            device.memory_usage = data.memory_usage
        
        device.last_seen = datetime.utcnow()
        await self.db.flush()
        await self.db.refresh(device)
        return device
    
    async def set_computing_status(self, device_id: str, is_computing: bool) -> Device:
        """Set device computing status."""
        device = await self.get_device_by_id(device_id)
        if not device:
            raise ValueError("Device not found")
        
        device.is_computing = is_computing
        device.last_seen = datetime.utcnow()
        await self.db.flush()
        await self.db.refresh(device)
        return device
