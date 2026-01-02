from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text, Integer
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from ..database import Base


class TaskType(str, enum.Enum):
    AI_TRAINING = "AI Training"
    RENDERING_3D = "3D Rendering"
    SCIENTIFIC = "Scientific Research"
    CRYPTOGRAPHY = "Cryptography"
    DATA_PROCESSING = "Data Processing"
    ML_INFERENCE = "ML Inference"  # New type for CoreML inference


class TaskStatus(str, enum.Enum):
    PENDING = "pending"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String, ForeignKey("compute_sessions.id"), nullable=True)
    device_id = Column(String, ForeignKey("devices.id"), nullable=True)
    
    # Task Info
    type = Column(String, default=TaskType.DATA_PROCESSING.value)
    description = Column(String, nullable=True)
    payload = Column(Text, nullable=True)  # JSON string for task data
    
    # Client Info
    client_name = Column(String, default="Echo Network")
    client_logo = Column(String, nullable=True)
    
    # Reward
    reward = Column(Float, default=0.005)
    
    # Progress
    status = Column(String, default=TaskStatus.PENDING.value)
    progress = Column(Float, default=0.0)  # 0.0 to 1.0
    
    # ML Inference specific fields
    model_url = Column(String, nullable=True)           # URL to CoreML model
    input_data = Column(Text, nullable=True)            # JSON: input for model
    output_data = Column(Text, nullable=True)           # JSON: model output/predictions
    expected_output_type = Column(String, nullable=True)  # classification, regression, etc.
    priority = Column(Integer, default=0)               # Task priority (higher = more urgent)
    inference_time_ms = Column(Float, nullable=True)    # Time taken for inference
    error_message = Column(String, nullable=True)       # Error message if task failed
    
    # Timing
    created_at = Column(DateTime, default=datetime.utcnow)
    assigned_at = Column(DateTime, nullable=True)
    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    
    # Relationships
    session = relationship("ComputeSession", back_populates="tasks")
    device = relationship("Device", back_populates="tasks")
    
    def __repr__(self):
        return f"<Task {self.id} - {self.type} - {self.status}>"

