from pydantic import BaseModel, field_validator
from typing import Optional, List
from datetime import datetime

from ..config import settings


class WithdrawalRequest(BaseModel):
    amount: float
    method: str  # paypal, bank, crypto
    address: str  # email, IBAN, wallet address
    
    @field_validator('amount')
    @classmethod
    def validate_amount(cls, v):
        if v < settings.min_withdrawal_amount:
            raise ValueError(f"Minimum withdrawal is €{settings.min_withdrawal_amount}")
        return v
    
    @field_validator('method')
    @classmethod
    def validate_method(cls, v):
        valid_methods = ['paypal', 'bank', 'crypto']
        if v.lower() not in valid_methods:
            raise ValueError(f"Method must be one of: {valid_methods}")
        return v.lower()


class TransactionResponse(BaseModel):
    id: str
    user_id: str
    session_id: Optional[str]
    type: str
    amount: float
    fee: float
    net_amount: float
    status: str
    withdrawal_method: Optional[str]
    description: Optional[str]
    created_at: datetime
    processed_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class BalanceResponse(BaseModel):
    available_balance: float
    pending_withdrawal: float
    total_earnings: float


class EarningsProjection(BaseModel):
    daily_average: float
    weekly_projection: float
    monthly_projection: float
    yearly_projection: float


class TransactionHistory(BaseModel):
    transactions: List[TransactionResponse]
    total_count: int
