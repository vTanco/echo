from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from ..database import get_db
from ..models.user import User
from ..models.device import Device
from ..models.compute_session import ComputeSession
from ..models.transaction import Transaction, TransactionType
from ..schemas.user import UserResponse, UserUpdate, UserStats
from ..utils.security import get_current_user_id
from ..services.auth_service import AuthService
from datetime import datetime, timedelta

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get current user profile."""
    auth_service = AuthService(db)
    user = await auth_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


@router.patch("/me", response_model=UserResponse)
async def update_user(
    update_data: UserUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Update current user profile and preferences."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    if update_data.display_name is not None:
        user.display_name = update_data.display_name
    
    if update_data.preferences is not None:
        # Merge preferences
        current_prefs = user.preferences or {}
        current_prefs.update(update_data.preferences)
        user.preferences = current_prefs
    
    await db.flush()
    await db.refresh(user)
    return user


@router.get("/me/stats", response_model=UserStats)
async def get_user_stats(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get user statistics."""
    # Get user
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    # Count devices
    devices_result = await db.execute(
        select(func.count()).select_from(Device).where(Device.user_id == user_id)
    )
    devices_count = devices_result.scalar_one() or 0
    
    # Count sessions
    sessions_result = await db.execute(
        select(func.count()).select_from(ComputeSession).where(ComputeSession.user_id == user_id)
    )
    total_sessions = sessions_result.scalar_one() or 0
    
    # Sum completed tasks
    tasks_result = await db.execute(
        select(func.sum(ComputeSession.tasks_completed))
        .where(ComputeSession.user_id == user_id)
    )
    total_tasks = tasks_result.scalar_one() or 0
    
    # Calculate period earnings
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=now.weekday())
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    # Today earnings
    today_result = await db.execute(
        select(func.sum(Transaction.amount))
        .where(Transaction.user_id == user_id)
        .where(Transaction.type == TransactionType.EARNING.value)
        .where(Transaction.created_at >= today_start)
    )
    today_earnings = today_result.scalar_one() or 0.0
    
    # Week earnings
    week_result = await db.execute(
        select(func.sum(Transaction.amount))
        .where(Transaction.user_id == user_id)
        .where(Transaction.type == TransactionType.EARNING.value)
        .where(Transaction.created_at >= week_start)
    )
    week_earnings = week_result.scalar_one() or 0.0
    
    # Month earnings
    month_result = await db.execute(
        select(func.sum(Transaction.amount))
        .where(Transaction.user_id == user_id)
        .where(Transaction.type == TransactionType.EARNING.value)
        .where(Transaction.created_at >= month_start)
    )
    month_earnings = month_result.scalar_one() or 0.0
    
    return UserStats(
        total_earnings=user.total_earnings,
        available_balance=user.available_balance,
        pending_withdrawal=user.pending_withdrawal,
        total_compute_hours=user.total_compute_hours,
        total_sessions=total_sessions,
        total_tasks_completed=int(total_tasks),
        devices_count=devices_count,
        today_earnings=today_earnings,
        week_earnings=week_earnings,
        month_earnings=month_earnings
    )
