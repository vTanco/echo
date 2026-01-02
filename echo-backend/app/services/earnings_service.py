from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional, List
from datetime import datetime, timedelta

from ..models.user import User
from ..models.transaction import Transaction, TransactionType, TransactionStatus
from ..models.compute_session import ComputeSession
from ..schemas.transaction import WithdrawalRequest, BalanceResponse, EarningsProjection
from ..config import settings


class EarningsService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_user_balance(self, user_id: str) -> BalanceResponse:
        """Get user's current balance."""
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError("User not found")
        
        return BalanceResponse(
            available_balance=user.available_balance,
            pending_withdrawal=user.pending_withdrawal,
            total_earnings=user.total_earnings
        )
    
    async def get_transaction_history(
        self, 
        user_id: str, 
        limit: int = 50,
        offset: int = 0
    ) -> List[Transaction]:
        """Get user's transaction history."""
        result = await self.db.execute(
            select(Transaction)
            .where(Transaction.user_id == user_id)
            .order_by(Transaction.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        return list(result.scalars().all())
    
    async def get_earnings_for_period(
        self, 
        user_id: str, 
        days: int = 7
    ) -> float:
        """Get total earnings for a period."""
        start_date = datetime.utcnow() - timedelta(days=days)
        result = await self.db.execute(
            select(func.sum(Transaction.amount))
            .where(Transaction.user_id == user_id)
            .where(Transaction.type == TransactionType.EARNING.value)
            .where(Transaction.created_at >= start_date)
        )
        total = result.scalar_one_or_none()
        return total or 0.0
    
    async def get_earnings_projection(self, user_id: str) -> EarningsProjection:
        """Calculate earnings projections based on history."""
        # Get average daily earnings from last 7 days
        week_earnings = await self.get_earnings_for_period(user_id, 7)
        daily_average = week_earnings / 7 if week_earnings > 0 else 0.0
        
        return EarningsProjection(
            daily_average=round(daily_average, 4),
            weekly_projection=round(daily_average * 7, 2),
            monthly_projection=round(daily_average * 30, 2),
            yearly_projection=round(daily_average * 365, 2)
        )
    
    async def add_earning(
        self, 
        user_id: str, 
        amount: float, 
        session_id: Optional[str] = None,
        description: Optional[str] = None
    ) -> Transaction:
        """Add an earning transaction."""
        transaction = Transaction(
            user_id=user_id,
            session_id=session_id,
            type=TransactionType.EARNING.value,
            amount=amount,
            fee=0.0,
            net_amount=amount,
            status=TransactionStatus.COMPLETED.value,
            description=description or "Compute task reward"
        )
        self.db.add(transaction)
        
        # Update user balance
        user_result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = user_result.scalar_one_or_none()
        if user:
            user.total_earnings += amount
            user.available_balance += amount
        
        await self.db.flush()
        await self.db.refresh(transaction)
        return transaction
    
    async def request_withdrawal(
        self, 
        user_id: str, 
        request: WithdrawalRequest
    ) -> Transaction:
        """Process a withdrawal request."""
        # Get user
        user_result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = user_result.scalar_one_or_none()
        if not user:
            raise ValueError("User not found")
        
        # Check balance
        if user.available_balance < request.amount:
            raise ValueError("Insufficient balance")
        
        # Calculate fee
        fee = request.amount * (settings.withdrawal_fee_percent / 100)
        net_amount = request.amount - fee
        
        # Create transaction
        transaction = Transaction(
            user_id=user_id,
            type=TransactionType.WITHDRAWAL.value,
            amount=request.amount,
            fee=fee,
            net_amount=net_amount,
            status=TransactionStatus.PENDING.value,
            withdrawal_method=request.method,
            withdrawal_address=request.address,
            description=f"Withdrawal to {request.method}"
        )
        self.db.add(transaction)
        
        # Update user balance
        user.available_balance -= request.amount
        user.pending_withdrawal += request.amount
        
        await self.db.flush()
        await self.db.refresh(transaction)
        return transaction
    
    async def process_withdrawal(self, transaction_id: str, success: bool = True) -> Transaction:
        """Process a pending withdrawal (simulate payment)."""
        result = await self.db.execute(
            select(Transaction).where(Transaction.id == transaction_id)
        )
        transaction = result.scalar_one_or_none()
        if not transaction:
            raise ValueError("Transaction not found")
        
        if success:
            transaction.status = TransactionStatus.COMPLETED.value
            transaction.processed_at = datetime.utcnow()
            
            # Update user pending
            user_result = await self.db.execute(
                select(User).where(User.id == transaction.user_id)
            )
            user = user_result.scalar_one_or_none()
            if user:
                user.pending_withdrawal -= transaction.amount
        else:
            transaction.status = TransactionStatus.FAILED.value
            
            # Refund to available balance
            user_result = await self.db.execute(
                select(User).where(User.id == transaction.user_id)
            )
            user = user_result.scalar_one_or_none()
            if user:
                user.available_balance += transaction.amount
                user.pending_withdrawal -= transaction.amount
        
        await self.db.flush()
        await self.db.refresh(transaction)
        return transaction
