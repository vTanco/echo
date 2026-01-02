from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from ..database import get_db
from ..schemas.transaction import (
    TransactionResponse, 
    WithdrawalRequest, 
    BalanceResponse,
    EarningsProjection,
    TransactionHistory
)
from ..services.earnings_service import EarningsService
from ..utils.security import get_current_user_id

router = APIRouter(prefix="/earnings", tags=["Earnings"])


@router.get("/balance", response_model=BalanceResponse)
async def get_balance(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get current balance."""
    earnings_service = EarningsService(db)
    try:
        return await earnings_service.get_user_balance(user_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.get("/history", response_model=TransactionHistory)
async def get_transaction_history(
    limit: int = 50,
    offset: int = 0,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get transaction history."""
    earnings_service = EarningsService(db)
    transactions = await earnings_service.get_transaction_history(user_id, limit, offset)
    
    from sqlalchemy import select, func
    from ..models.transaction import Transaction
    
    count_result = await db.execute(
        select(func.count()).select_from(Transaction).where(Transaction.user_id == user_id)
    )
    total_count = count_result.scalar_one() or 0
    
    return TransactionHistory(
        transactions=transactions,
        total_count=total_count
    )


@router.get("/projections", response_model=EarningsProjection)
async def get_projections(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get earnings projections."""
    earnings_service = EarningsService(db)
    return await earnings_service.get_earnings_projection(user_id)


@router.post("/withdraw", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
async def request_withdrawal(
    withdrawal_data: WithdrawalRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Request a withdrawal."""
    earnings_service = EarningsService(db)
    
    try:
        transaction = await earnings_service.request_withdrawal(user_id, withdrawal_data)
        return transaction
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/today", response_model=dict)
async def get_today_earnings(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get today's earnings."""
    earnings_service = EarningsService(db)
    amount = await earnings_service.get_earnings_for_period(user_id, days=1)
    return {"today_earnings": amount}


@router.get("/week", response_model=dict)
async def get_week_earnings(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get this week's earnings."""
    earnings_service = EarningsService(db)
    amount = await earnings_service.get_earnings_for_period(user_id, days=7)
    return {"week_earnings": amount}
