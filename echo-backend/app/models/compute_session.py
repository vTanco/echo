from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from ..database import Base


class SessionStatus(str, enum.Enum):
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"


class ComputeSession(Base):
    __tablename__ = "compute_sessions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    device_id = Column(String, ForeignKey("devices.id"), nullable=False)
    
    # Timing
    start_time = Column(DateTime, default=datetime.utcnow)
    end_time = Column(DateTime, nullable=True)
    
    # Status
    status = Column(String, default=SessionStatus.ACTIVE.value)
    
    # Stats
    tasks_completed = Column(Float, default=0)
    tasks_failed = Column(Float, default=0)
    earnings = Column(Float, default=0.0)
    compute_hours = Column(Float, default=0.0)
    
    # Relationships
    user = relationship("User", back_populates="sessions")
    device = relationship("Device", back_populates="sessions")
    tasks = relationship("Task", back_populates="session")
    
    def __repr__(self):
        return f"<ComputeSession {self.id} - {self.status}>"
    
    @property
    def duration_hours(self) -> float:
        """Calculate session duration in hours."""
        end = self.end_time or datetime.utcnow()
        delta = end - self.start_time
        return delta.total_seconds() / 3600
