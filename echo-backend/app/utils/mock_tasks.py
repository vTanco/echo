import random
from typing import List
from datetime import datetime

from ..models.task import TaskType, TaskStatus
from ..config import settings


# Mock client names for simulated tasks
MOCK_CLIENTS = [
    {"name": "TensorFlow Labs", "logo": "tf"},
    {"name": "OpenAI Research", "logo": "openai"},
    {"name": "DeepMind", "logo": "deepmind"},
    {"name": "Anthropic", "logo": "anthropic"},
    {"name": "Meta AI", "logo": "meta"},
    {"name": "Stability AI", "logo": "stability"},
    {"name": "Hugging Face", "logo": "hf"},
    {"name": "Midjourney", "logo": "mj"},
    {"name": "NVIDIA Research", "logo": "nvidia"},
    {"name": "Google Research", "logo": "google"},
]

TASK_DESCRIPTIONS = {
    TaskType.AI_TRAINING.value: [
        "Training neural network layer",
        "Fine-tuning language model",
        "Optimizing model weights",
        "Processing training batch",
        "Gradient computation task",
    ],
    TaskType.RENDERING_3D.value: [
        "Rendering scene frame",
        "Ray tracing computation",
        "Texture mapping task",
        "Lighting calculation",
        "Shadow rendering",
    ],
    TaskType.SCIENTIFIC.value: [
        "Protein folding simulation",
        "Climate model computation",
        "Molecular dynamics",
        "Genome sequence analysis",
        "Astronomical data processing",
    ],
    TaskType.CRYPTOGRAPHY.value: [
        "Hash verification",
        "Encryption key generation",
        "Cryptographic proof verification",
        "Zero-knowledge proof computation",
        "Digital signature validation",
    ],
    TaskType.DATA_PROCESSING.value: [
        "Data normalization",
        "Feature extraction",
        "Pattern recognition",
        "Data aggregation",
        "Index building",
    ],
}


def generate_mock_task() -> dict:
    """Generate a mock compute task."""
    task_type = random.choice(list(TaskType))
    client = random.choice(MOCK_CLIENTS)
    description = random.choice(TASK_DESCRIPTIONS.get(task_type.value, ["Processing data"]))
    
    # Reward based on task type complexity
    base_reward = random.uniform(settings.task_reward_min, settings.task_reward_max)
    type_multiplier = {
        TaskType.AI_TRAINING.value: 1.5,
        TaskType.RENDERING_3D.value: 1.3,
        TaskType.SCIENTIFIC.value: 1.4,
        TaskType.CRYPTOGRAPHY.value: 1.2,
        TaskType.DATA_PROCESSING.value: 1.0,
    }
    reward = base_reward * type_multiplier.get(task_type.value, 1.0)
    
    return {
        "type": task_type.value,
        "description": description,
        "client_name": client["name"],
        "client_logo": client["logo"],
        "reward": round(reward, 6),
        "status": TaskStatus.PENDING.value,
        "progress": 0.0,
        "created_at": datetime.utcnow(),
    }


def generate_mock_tasks(count: int = 3) -> List[dict]:
    """Generate multiple mock tasks."""
    return [generate_mock_task() for _ in range(count)]
