from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from datetime import datetime

from ..database import get_db
from ..models.compute_session import ComputeSession, SessionStatus
from ..models.device import Device
from ..models.user import User
from ..schemas.session import SessionStart, SessionResponse, SessionHistory
from ..services.device_service import DeviceService
from ..services.task_service import TaskService
from ..utils.security import get_current_user_id

router = APIRouter(prefix="/sessions", tags=["Compute Sessions"])


@router.post("/start", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def start_session(
    session_data: SessionStart,
    background_tasks: BackgroundTasks,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Start a new compute session."""
    device_service = DeviceService(db)
    task_service = TaskService(db)
    
    # Verify device ownership
    device = await device_service.get_device_by_id(session_data.device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    # Check if device is ready
    if not device.is_ready_for_compute:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Device not ready for computing. Check battery, WiFi, and temperature."
        )
    
    # Check for existing active session
    existing = await db.execute(
        select(ComputeSession)
        .where(ComputeSession.device_id == device.id)
        .where(ComputeSession.status == SessionStatus.ACTIVE.value)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Device already has an active session"
        )
    
    # Create session
    session = ComputeSession(
        user_id=user_id,
        device_id=device.id,
        status=SessionStatus.ACTIVE.value
    )
    db.add(session)
    
    # Update device status
    device.is_computing = True
    
    await db.flush()
    await db.refresh(session)
    
    # Generate initial tasks in background
    background_tasks.add_task(generate_initial_tasks, db, session.id, device.id)
    
    return session


async def generate_initial_tasks(db: AsyncSession, session_id: str, device_id: str):
    """Background task to generate initial tasks for session."""
    async with db.begin():
        task_service = TaskService(db)
        tasks = await task_service.create_mock_tasks(3)
        for task in tasks:
            await task_service.assign_task_to_device(task.id, device_id, session_id)


@router.post("/stop", response_model=SessionResponse)
async def stop_session(
    session_data: SessionStart,  # Reusing for device_id
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Stop an active compute session."""
    device_service = DeviceService(db)
    
    # Get active session for device
    result = await db.execute(
        select(ComputeSession)
        .where(ComputeSession.device_id == session_data.device_id)
        .where(ComputeSession.status == SessionStatus.ACTIVE.value)
    )
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active session found")
    
    if session.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your session")
    
    # Calculate duration and update
    session.end_time = datetime.utcnow()
    session.status = SessionStatus.COMPLETED.value
    session.compute_hours = session.duration_hours
    
    # Update device status
    device = await device_service.get_device_by_id(session_data.device_id)
    if device:
        device.is_computing = False
        device.total_compute_hours += session.compute_hours
    
    # Update user stats
    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()
    if user:
        user.total_compute_hours += session.compute_hours
    
    await db.flush()
    await db.refresh(session)
    return session


@router.get("/current", response_model=SessionResponse)
async def get_current_session(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get active session for a device."""
    result = await db.execute(
        select(ComputeSession)
        .where(ComputeSession.device_id == device_id)
        .where(ComputeSession.status == SessionStatus.ACTIVE.value)
    )
    session = result.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active session")
    
    if session.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your session")
    
    return session


@router.get("/history", response_model=SessionHistory)
async def get_session_history(
    limit: int = 20,
    offset: int = 0,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get session history for current user."""
    # Get sessions
    result = await db.execute(
        select(ComputeSession)
        .where(ComputeSession.user_id == user_id)
        .order_by(ComputeSession.start_time.desc())
        .limit(limit)
        .offset(offset)
    )
    sessions = list(result.scalars().all())
    
    # Get totals
    from sqlalchemy import func
    count_result = await db.execute(
        select(func.count()).select_from(ComputeSession).where(ComputeSession.user_id == user_id)
    )
    total_count = count_result.scalar_one() or 0
    
    earnings_result = await db.execute(
        select(func.sum(ComputeSession.earnings)).where(ComputeSession.user_id == user_id)
    )
    total_earnings = earnings_result.scalar_one() or 0.0
    
    hours_result = await db.execute(
        select(func.sum(ComputeSession.compute_hours)).where(ComputeSession.user_id == user_id)
    )
    total_hours = hours_result.scalar_one() or 0.0
    
    return SessionHistory(
        sessions=sessions,
        total_count=total_count,
        total_earnings=total_earnings,
        total_hours=total_hours
    )
