from pydantic import BaseModel, field_validator
from typing import Optional, Any
from datetime import datetime
from urllib.parse import urlparse


# Allowed domains for model URL validation
ALLOWED_MODEL_DOMAINS = [
    "docs-assets.developer.apple.com",
    "ml-assets.apple.com",
    "huggingface.co",
    "echocompute.com",
    "localhost",  # For development
]


class TaskCreate(BaseModel):
    type: str
    description: Optional[str] = None
    reward: float = 0.005
    client_name: str = "Echo Network"


class TaskProgressUpdate(BaseModel):
    progress: float  # 0.0 to 1.0


class TaskResponse(BaseModel):
    id: str
    session_id: Optional[str]
    device_id: Optional[str]
    type: str
    description: Optional[str]
    client_name: str
    client_logo: Optional[str]
    reward: float
    status: str
    progress: float
    created_at: datetime
    assigned_at: Optional[datetime]
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    
    class Config:
        from_attributes = True


# ============================================
# ML Inference Task Schemas
# ============================================

class TaskDispatch(BaseModel):
    """Schema for dispatching an ML inference task to the network."""
    model_url: str                              # URL to .mlmodel or .mlpackage
    input_data: dict[str, Any]                  # Input tensors/data for model
    expected_output_type: str = "classification"  # classification, regression, embedding
    reward: float = 0.01
    client_name: str = "Echo AI Network"
    priority: int = 0                           # Higher = more urgent
    
    @field_validator('model_url')
    @classmethod
    def validate_model_url(cls, v: str) -> str:
        """Validate that model URL is from an allowed domain."""
        parsed = urlparse(v)
        domain = parsed.netloc.lower()
        
        # Check if domain matches any allowed domain
        if not any(domain == allowed or domain.endswith(f".{allowed}") 
                   for allowed in ALLOWED_MODEL_DOMAINS):
            raise ValueError(
                f"Model URL domain '{domain}' not allowed. "
                f"Allowed domains: {ALLOWED_MODEL_DOMAINS}"
            )
        return v
    
    @field_validator('expected_output_type')
    @classmethod
    def validate_output_type(cls, v: str) -> str:
        """Validate expected output type."""
        allowed_types = ["classification", "regression", "embedding", "detection", "segmentation"]
        if v.lower() not in allowed_types:
            raise ValueError(f"Output type must be one of: {allowed_types}")
        return v.lower()


class MLTaskResponse(BaseModel):
    """Response schema for ML inference tasks including model details."""
    id: str
    model_url: str
    input_data: dict[str, Any]
    expected_output_type: str
    reward: float
    client_name: str
    client_logo: Optional[str]
    status: str
    priority: int
    created_at: datetime
    assigned_at: Optional[datetime]
    
    @field_validator('input_data', mode='before')
    @classmethod
    def parse_input_data(cls, v):
        """Parse input_data from JSON string if needed."""
        import json
        if isinstance(v, str):
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return {}
        return v or {}
    
    class Config:
        from_attributes = True


class TaskResultSubmit(BaseModel):
    """Schema for submitting ML inference results from a device."""
    output_data: dict[str, Any]     # Model prediction output
    inference_time_ms: float        # Time taken for inference in milliseconds
    success: bool                   # Whether inference succeeded
    error_message: Optional[str] = None  # Error message if failed
