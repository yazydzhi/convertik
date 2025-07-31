"""Планировщик фоновых задач"""

import asyncio
from contextlib import asynccontextmanager
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
import structlog

from ..services.rates_service import rates_service
from ..config import settings

logger = structlog.get_logger()


class TaskScheduler:
    """Планировщик фоновых задач приложения"""
    
    def __init__(self):
        self.scheduler = AsyncIOScheduler(timezone="UTC")
        self._is_running = False
    
    async def start(self):
        """Запускает планировщик и добавляет задачи"""
        if self._is_running:
            logger.warning("Scheduler is already running")
            return
        
        try:
            # Добавляем задачу умной проверки обновления курсов каждые 30 минут
            # (но обновляем только если прошло достаточно времени для rate limiting)
            check_interval = settings.rates_check_interval_minutes
            self.scheduler.add_job(
                self._smart_rates_update_job,
                trigger=IntervalTrigger(minutes=check_interval),
                id="smart_update_rates",
                name=f"Smart exchange rates update check (every {check_interval}min)",
                replace_existing=True,
                max_instances=1  # Не запускать одновременно
            )
            
            # Добавляем задачу для первого обновления через 30 секунд после запуска
            self.scheduler.add_job(
                self._initial_rates_update,
                trigger="date",
                run_date=None,  # Запустить немедленно при старте
                id="initial_update_rates",
                name="Initial exchange rates update",
                replace_existing=True
            )
            
            # Запускаем планировщик
            self.scheduler.start()
            self._is_running = True
            
            logger.info("Task scheduler started successfully")
            logger.info("Scheduled jobs", jobs=[job.name for job in self.scheduler.get_jobs()])
            
        except Exception as e:
            logger.error("Failed to start scheduler", error=str(e))
            raise
    
    async def stop(self):
        """Останавливает планировщик"""
        if not self._is_running:
            return
        
        try:
            self.scheduler.shutdown(wait=True)
            self._is_running = False
            logger.info("Task scheduler stopped successfully")
        except Exception as e:
            logger.error("Error stopping scheduler", error=str(e))
    
    async def _smart_rates_update_job(self):
        """Умная задача обновления курсов валют с rate limiting"""
        try:
            logger.info("Starting smart scheduled rates update check")
            result = await rates_service.update_rates_from_external_api()
            
            if result.get("success"):
                logger.info(
                    "Scheduled rates update completed successfully",
                    updated_count=result.get("updated_count"),
                    rates_count=result.get("rates_count")
                )
            elif result.get("skipped"):
                logger.debug(
                    "Scheduled rates update skipped due to rate limiting",
                    reason=result.get("reason")
                )
            else:
                logger.error(
                    "Scheduled rates update failed",
                    error=result.get("error")
                )
                
        except Exception as e:
            logger.error("Error in scheduled rates update", error=str(e), exc_info=True)
    
    async def _initial_rates_update(self):
        """Первоначальное обновление курсов при запуске приложения"""
        try:
            logger.info("Starting initial rates update")
            
            # Ждем немного, чтобы дать приложению полностью запуститься
            await asyncio.sleep(5)
            
            result = await rates_service.update_rates_from_external_api()
            
            if result.get("success"):
                logger.info(
                    "Initial rates update completed successfully",
                    updated_count=result.get("updated_count"),
                    rates_count=result.get("rates_count")
                )
            else:
                logger.warning(
                    "Initial rates update failed (will retry in 6 hours)",
                    error=result.get("error")
                )
                
        except Exception as e:
            logger.error("Error in initial rates update", error=str(e), exc_info=True)
    
    def get_job_status(self) -> dict:
        """Возвращает статус всех задач"""
        if not self._is_running:
            return {"scheduler_running": False, "jobs": []}
        
        jobs_info = []
        for job in self.scheduler.get_jobs():
            jobs_info.append({
                "id": job.id,
                "name": job.name,
                "next_run": job.next_run_time.isoformat() if job.next_run_time else None,
                "trigger": str(job.trigger)
            })
        
        return {
            "scheduler_running": True,
            "jobs": jobs_info
        }
    
    async def trigger_rates_update_now(self) -> dict:
        """Принудительно запускает обновление курсов (игнорирует rate limiting)"""
        try:
            logger.info("Manual rates update triggered (forced)")
            result = await rates_service.update_rates_from_external_api(force=True)
            return result
        except Exception as e:
            logger.error("Error in manual rates update", error=str(e))
            return {"success": False, "error": str(e)}


# Глобальный экземпляр планировщика
task_scheduler = TaskScheduler()


@asynccontextmanager
async def scheduler_lifespan():
    """Context manager для управления жизненным циклом планировщика"""
    try:
        await task_scheduler.start()
        yield task_scheduler
    finally:
        await task_scheduler.stop()