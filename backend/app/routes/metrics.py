from fastapi import APIRouter
from datetime import datetime
import psutil
import os

router = APIRouter()


@router.get("/metrics")
async def get_metrics():
    """Получение технических метрик сервиса"""
    # Получаем метрики системы
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')

    # Получаем информацию о процессе
    process = psutil.Process(os.getpid())
    process_memory = process.memory_info()

    return {
        "timestamp": datetime.utcnow().isoformat(),
        "metrics": {
            "cpu_usage_percent": cpu_percent,
            "memory_total_mb": memory.total / (1024 * 1024),
            "memory_used_mb": memory.used / (1024 * 1024),
            "memory_available_mb": memory.available / (1024 * 1024),
            "memory_usage_percent": memory.percent,
            "disk_total_gb": disk.total / (1024 * 1024 * 1024),
            "disk_used_gb": disk.used / (1024 * 1024 * 1024),
            "disk_free_gb": disk.free / (1024 * 1024 * 1024),
            "disk_usage_percent": (disk.used / disk.total) * 100,
            "process_memory_mb": process_memory.rss / (1024 * 1024),
        }
    }

















