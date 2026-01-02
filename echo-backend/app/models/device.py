from sqlalchemy import Column, String, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from ..database import Base


class Device(Base):
    __tablename__ = "devices"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # Device Info
    device_token = Column(String, unique=True, index=True, nullable=False)
    device_name = Column(String, nullable=True)
    device_model = Column(String, nullable=True)
    os_version = Column(String, nullable=True)
    app_version = Column(String, nullable=True)
    
    # Status
    battery_level = Column(Float, default=100.0)
    is_charging = Column(Boolean, default=False)
    is_on_wifi = Column(Boolean, default=True)
    temperature = Column(Float, default=25.0)
    cpu_usage = Column(Float, default=0.0)
    memory_usage = Column(Float, default=0.0)
    
    # Activity
    is_active = Column(Boolean, default=True)
    is_computing = Column(Boolean, default=False)
    last_seen = Column(DateTime, default=datetime.utcnow)
    registered_at = Column(DateTime, default=datetime.utcnow)
    
    # Stats
    total_tasks_completed = Column(Float, default=0)
    total_compute_hours = Column(Float, default=0.0)
    total_earnings = Column(Float, default=0.0)
    
    # Relationships
    user = relationship("User", back_populates="devices")
    sessions = relationship("ComputeSession", back_populates="device", cascade="all, delete-orphan")
    tasks = relationship("Task", back_populates="device")
    
    def __repr__(self):
        return f"<Device {self.device_name or self.id}>"
    
    @property
    def is_ready_for_compute(self) -> bool:
        """Check if device meets requirements for computing."""
        return (
            self.battery_level >= 20 and
            self.is_on_wifi and
            self.temperature < 45 and
            self.is_active
        )
