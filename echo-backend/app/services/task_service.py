from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional, List, Any
from datetime import datetime
import json

from ..models.task import Task, TaskStatus, TaskType
from ..models.compute_session import ComputeSession
from ..models.device import Device
from ..models.user import User
from ..utils.mock_tasks import generate_mock_task, generate_mock_tasks


class TaskService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_task_by_id(self, task_id: str) -> Optional[Task]:
        """Get task by ID."""
        result = await self.db.execute(
            select(Task).where(Task.id == task_id)
        )
        return result.scalar_one_or_none()
    
    async def get_pending_tasks(self, limit: int = 5) -> List[Task]:
        """Get pending tasks waiting for assignment."""
        result = await self.db.execute(
            select(Task)
            .where(Task.status == TaskStatus.PENDING.value)
            .limit(limit)
        )
        return list(result.scalars().all())
    
    async def get_device_tasks(self, device_id: str) -> List[Task]:
        """Get tasks assigned to a device."""
        result = await self.db.execute(
            select(Task)
            .where(Task.device_id == device_id)
            .where(Task.status.in_([TaskStatus.ASSIGNED.value, TaskStatus.IN_PROGRESS.value]))
        )
        return list(result.scalars().all())
    
    # ============================================
    # ML Inference Task Methods
    # ============================================
    
    async def create_inference_task(
        self,
        model_url: str,
        input_data: dict[str, Any],
        expected_output_type: str = "classification",
        reward: float = 0.01,
        client_name: str = "Echo AI Network",
        priority: int = 0
    ) -> Task:
        """Create a new ML inference task."""
        task = Task(
            type=TaskType.ML_INFERENCE.value,
            description=f"ML Inference: {expected_output_type}",
            model_url=model_url,
            input_data=json.dumps(input_data),
            expected_output_type=expected_output_type,
            reward=reward,
            client_name=client_name,
            client_logo="brain.head.profile",
            priority=priority,
            status=TaskStatus.PENDING.value,
            created_at=datetime.utcnow()
        )
        self.db.add(task)
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def get_next_available_task(self, device_id: str) -> Optional[Task]:
        """
        Get the next available ML task and assign it to the device.
        Tasks are selected by priority (higher first), then by creation time.
        """
        # Find pending ML inference tasks, ordered by priority and age
        result = await self.db.execute(
            select(Task)
            .where(Task.status == TaskStatus.PENDING.value)
            .where(Task.type == TaskType.ML_INFERENCE.value)
            .order_by(Task.priority.desc(), Task.created_at.asc())
            .limit(1)
        )
        task = result.scalar_one_or_none()
        
        if not task:
            return None
        
        # Assign task to device
        task.device_id = device_id
        task.status = TaskStatus.ASSIGNED.value
        task.assigned_at = datetime.utcnow()
        
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def submit_task_result(
        self,
        task_id: str,
        output_data: dict[str, Any],
        inference_time_ms: float,
        success: bool,
        error_message: Optional[str] = None
    ) -> Task:
        """Submit ML inference results and update task status."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        # Store result data
        task.output_data = json.dumps(output_data)
        task.inference_time_ms = inference_time_ms
        
        if success:
            task.status = TaskStatus.COMPLETED.value
            task.progress = 1.0
            task.completed_at = datetime.utcnow()
            
            # Update device/user stats
            await self._update_completion_stats(task)
        else:
            task.status = TaskStatus.FAILED.value
            task.error_message = error_message
            
            # Update failure stats
            await self._update_failure_stats(task)
        
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def _update_completion_stats(self, task: Task) -> None:
        """Update device and user stats on task completion."""
        if task.device_id:
            device_result = await self.db.execute(
                select(Device).where(Device.id == task.device_id)
            )
            device = device_result.scalar_one_or_none()
            if device:
                device.total_tasks_completed += 1
                device.total_earnings += task.reward
                
                # Update user stats
                user_result = await self.db.execute(
                    select(User).where(User.id == device.user_id)
                )
                user = user_result.scalar_one_or_none()
                if user:
                    user.total_earnings += task.reward
                    user.available_balance += task.reward
        
        # Update session stats if applicable
        if task.session_id:
            session_result = await self.db.execute(
                select(ComputeSession).where(ComputeSession.id == task.session_id)
            )
            session = session_result.scalar_one_or_none()
            if session:
                session.tasks_completed += 1
                session.earnings += task.reward
    
    async def _update_failure_stats(self, task: Task) -> None:
        """Update stats on task failure."""
        if task.session_id:
            session_result = await self.db.execute(
                select(ComputeSession).where(ComputeSession.id == task.session_id)
            )
            session = session_result.scalar_one_or_none()
            if session:
                session.tasks_failed += 1
    
    # ============================================
    # Existing Methods
    # ============================================
    
    async def create_mock_tasks(self, count: int = 3) -> List[Task]:
        """Create mock tasks for testing/demo."""
        tasks = []
        for task_data in generate_mock_tasks(count):
            task = Task(**task_data)
            self.db.add(task)
            tasks.append(task)
        await self.db.flush()
        return tasks
    
    async def assign_task_to_device(self, task_id: str, device_id: str, session_id: str) -> Task:
        """Assign a task to a device."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        task.device_id = device_id
        task.session_id = session_id
        task.status = TaskStatus.ASSIGNED.value
        task.assigned_at = datetime.utcnow()
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def start_task(self, task_id: str) -> Task:
        """Mark task as started."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        task.status = TaskStatus.IN_PROGRESS.value
        task.started_at = datetime.utcnow()
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def update_task_progress(self, task_id: str, progress: float) -> Task:
        """Update task progress (0.0 to 1.0)."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        task.progress = min(max(progress, 0.0), 1.0)
        
        # Auto-start if updating progress
        if task.status == TaskStatus.ASSIGNED.value:
            task.status = TaskStatus.IN_PROGRESS.value
            task.started_at = datetime.utcnow()
        
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def complete_task(self, task_id: str) -> Task:
        """Mark task as completed and update related records."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        task.status = TaskStatus.COMPLETED.value
        task.progress = 1.0
        task.completed_at = datetime.utcnow()
        
        await self._update_completion_stats(task)
        
        await self.db.flush()
        await self.db.refresh(task)
        return task
    
    async def fail_task(self, task_id: str) -> Task:
        """Mark task as failed."""
        task = await self.get_task_by_id(task_id)
        if not task:
            raise ValueError("Task not found")
        
        task.status = TaskStatus.FAILED.value
        
        await self._update_failure_stats(task)
        
        await self.db.flush()
        await self.db.refresh(task)
        return task

