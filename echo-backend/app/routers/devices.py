from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from ..database import get_db
from ..schemas.device import DeviceRegister, DeviceResponse, DeviceStatusUpdate
from ..services.device_service import DeviceService
from ..utils.security import get_current_user_id

router = APIRouter(prefix="/devices", tags=["Devices"])


@router.post("/register", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def register_device(
    device_data: DeviceRegister,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Register a new device or update existing."""
    device_service = DeviceService(db)
    device = await device_service.register_device(user_id, device_data)
    return device


@router.get("/", response_model=List[DeviceResponse])
async def list_devices(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """List all devices for current user."""
    device_service = DeviceService(db)
    devices = await device_service.get_user_devices(user_id)
    return devices


@router.get("/{device_id}", response_model=DeviceResponse)
async def get_device(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get device details."""
    device_service = DeviceService(db)
    device = await device_service.get_device_by_id(device_id)
    
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    return device


@router.patch("/{device_id}/status", response_model=DeviceResponse)
async def update_device_status(
    device_id: str,
    status_data: DeviceStatusUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Update device status (battery, wifi, etc)."""
    device_service = DeviceService(db)
    
    # Verify ownership
    device = await device_service.get_device_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    try:
        device = await device_service.update_device_status(device_id, status_data)
        return device
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Remove a device."""
    device_service = DeviceService(db)
    device = await device_service.get_device_by_id(device_id)
    
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    await db.delete(device)
    await db.flush()
