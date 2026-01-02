from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from datetime import datetime
import uuid
import enum

from ..database import Base


class TransactionType(str, enum.Enum):
    EARNING = "earning"
    WITHDRAWAL = "withdrawal"
    BONUS = "bonus"
    REFERRAL = "referral"
    FEE = "fee"


class TransactionStatus(str, enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    session_id = Column(String, ForeignKey("compute_sessions.id"), nullable=True)
    
    # Transaction Details
    type = Column(String, default=TransactionType.EARNING.value)
    amount = Column(Float, nullable=False)
    fee = Column(Float, default=0.0)
    net_amount = Column(Float, nullable=False)
    
    # Status
    status = Column(String, default=TransactionStatus.COMPLETED.value)
    
    # For withdrawals
    withdrawal_method = Column(String, nullable=True)  # paypal, bank, crypto
    withdrawal_address = Column(String, nullable=True)
    
    # Metadata
    description = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    processed_at = Column(DateTime, nullable=True)
    
    # Relationships
    from sqlalchemy.orm import relationship
    user = relationship("User", back_populates="transactions")
    
    def __repr__(self):
        return f"<Transaction {self.id} - {self.type} - €{self.amount}>"
