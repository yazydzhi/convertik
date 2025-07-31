"""Админские API роуты"""

from fastapi import APIRouter, Depends, HTTPException, Header
from typing import Optional
import structlog

from ..config import settings
from ..tasks.scheduler import task_scheduler
from ..services.rates_service import rates_service

logger = structlog.get_logger()
router = APIRouter()


def verify_admin_token(x_admin_token: Optional[str] = Header(None)):
    """Проверка админского токена"""
    if not x_admin_token or x_admin_token != settings.admin_token:
        raise HTTPException(
            status_code=403,
            detail={
                "code": 403,
                "message": "Forbidden",
                "details": {"error": "Invalid admin token"}
            }
        )


@router.get("/admin/scheduler/status")
async def get_scheduler_status(admin_check=Depends(verify_admin_token)) -> dict:
    """Получить статус планировщика задач"""
    try:
        status = task_scheduler.get_job_status()
        logger.info("Scheduler status requested")
        return status
    except Exception as e:
        logger.error("Error getting scheduler status", error=str(e))
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get scheduler status",
                "details": {"error": str(e)}
            }
        )


@router.post("/admin/rates/update")
async def trigger_rates_update(admin_check=Depends(verify_admin_token)) -> dict:
    """Принудительно запустить обновление курсов"""
    try:
        logger.info("Manual rates update triggered by admin")
        result = await task_scheduler.trigger_rates_update_now()
        return result
    except Exception as e:
        logger.error("Error triggering rates update", error=str(e))
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to trigger rates update",
                "details": {"error": str(e)}
            }
        )


@router.get("/admin/rates/stats")
async def get_rates_stats(admin_check=Depends(verify_admin_token)) -> dict:
    """Получить статистику по курсам валют"""
    try:
        stats = await rates_service.get_rates_stats()
        logger.info("Rates stats requested by admin")
        return stats
    except Exception as e:
        logger.error("Error getting rates stats", error=str(e))
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get rates statistics",
                "details": {"error": str(e)}
            }
        )