from sqlalchemy import Column, String, Float, Boolean, DateTime, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from ..database import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    
    # Profile
    display_name = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    
    # Earnings
    total_earnings = Column(Float, default=0.0)
    available_balance = Column(Float, default=0.0)
    pending_withdrawal = Column(Float, default=0.0)
    total_compute_hours = Column(Float, default=0.0)
    
    # Preferences (JSON)
    preferences = Column(JSON, default=lambda: {
        "auto_start": False,
        "min_battery_level": 20,
        "wifi_only": True,
        "schedule_enabled": False,
        "schedule_start": "23:00",
        "schedule_end": "07:00",
        "notifications_enabled": True
    })
    
    # Relationships
    devices = relationship("Device", back_populates="user", cascade="all, delete-orphan")
    sessions = relationship("ComputeSession", back_populates="user", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<User {self.email}>"
