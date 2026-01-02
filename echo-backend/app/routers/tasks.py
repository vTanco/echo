from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional

from ..database import get_db
from ..schemas.task import (
    TaskResponse, TaskProgressUpdate, TaskDispatch,
    MLTaskResponse, TaskResultSubmit
)
from ..services.task_service import TaskService
from ..services.device_service import DeviceService
from ..utils.security import get_current_user_id

router = APIRouter(prefix="/tasks", tags=["Tasks"])


# ============================================
# ML Inference Task Endpoints
# ============================================

@router.post("/dispatch", response_model=MLTaskResponse, status_code=status.HTTP_201_CREATED)
async def dispatch_ml_task(
    task: TaskDispatch,
    db: AsyncSession = Depends(get_db)
):
    """
    Dispatch a new ML inference task to the Echo network.
    
    This endpoint is used by AI clients to submit inference tasks.
    The task will be picked up by an available device.
    """
    task_service = TaskService(db)
    
    try:
        new_task = await task_service.create_inference_task(
            model_url=task.model_url,
            input_data=task.input_data,
            expected_output_type=task.expected_output_type,
            reward=task.reward,
            client_name=task.client_name,
            priority=task.priority
        )
        return new_task
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/next", response_model=Optional[MLTaskResponse])
async def get_next_task(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Get the next available ML task for a device.
    
    Returns None if no tasks are available. The device should poll
    this endpoint periodically when in compute mode.
    """
    device_service = DeviceService(db)
    task_service = TaskService(db)
    
    # Verify device ownership
    device = await device_service.get_device_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    # Get next available task and assign to device
    task = await task_service.get_next_available_task(device_id)
    return task


@router.post("/{task_id}/submit", response_model=TaskResponse)
async def submit_task_result(
    task_id: str,
    result: TaskResultSubmit,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Submit ML inference results from a device.
    
    Called when a device completes (or fails) an inference task.
    """
    task_service = TaskService(db)
    
    try:
        task = await task_service.submit_task_result(
            task_id=task_id,
            output_data=result.output_data,
            inference_time_ms=result.inference_time_ms,
            success=result.success,
            error_message=result.error_message
        )
        return task
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# ============================================
# Existing Task Endpoints
# ============================================

@router.get("/pending", response_model=List[TaskResponse])
async def get_pending_tasks(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get tasks assigned to a device."""
    device_service = DeviceService(db)
    task_service = TaskService(db)
    
    # Verify device ownership
    device = await device_service.get_device_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your device")
    
    tasks = await task_service.get_device_tasks(device_id)
    return tasks


@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(
    task_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get task details."""
    task_service = TaskService(db)
    task = await task_service.get_task_by_id(task_id)
    
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    
    return task


@router.patch("/{task_id}/progress", response_model=TaskResponse)
async def update_task_progress(
    task_id: str,
    progress_data: TaskProgressUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Update task progress."""
    task_service = TaskService(db)
    
    try:
        task = await task_service.update_task_progress(task_id, progress_data.progress)
        return task
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/{task_id}/complete", response_model=TaskResponse)
async def complete_task(
    task_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Mark task as completed."""
    task_service = TaskService(db)
    
    try:
        task = await task_service.complete_task(task_id)
        return task
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/{task_id}/fail", response_model=TaskResponse)
async def fail_task(
    task_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Mark task as failed."""
    task_service = TaskService(db)
    
    try:
        task = await task_service.fail_task(task_id)
        return task
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/generate", response_model=List[TaskResponse], status_code=status.HTTP_201_CREATED)
async def generate_tasks(
    count: int = 3,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Generate mock tasks (for testing/demo)."""
    task_service = TaskService(db)
    tasks = await task_service.create_mock_tasks(min(count, 10))
    return tasks

