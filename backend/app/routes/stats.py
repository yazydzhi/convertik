"""API роуты для аналитики"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import List
import structlog
from datetime import datetime
import uuid

from ..database import get_db
from ..models.usage_event import UsageEvent
from ..schemas import UsageEventBatch, UsageEventCreate

logger = structlog.get_logger()
router = APIRouter()


@router.post("/stats")
async def submit_stats(
    event_batch: UsageEventBatch,
    db: AsyncSession = Depends(get_db)
) -> dict:
    """
    Принять batch событий аналитики
    
    Принимает до 50 событий за один запрос для эффективной обработки
    """
    try:
        events_to_insert = []
        
        for event in event_batch.events:
            # Конвертируем timestamp в datetime
            event_time = datetime.fromtimestamp(event.ts)
            
            # Создаем объект события
            usage_event = UsageEvent(
                device_id=event.device_id,
                event_name=event.name,
                payload=event.params,
                created_at=event_time
            )
            events_to_insert.append(usage_event)
        
        # Bulk insert всех событий
        db.add_all(events_to_insert)
        await db.commit()
        
        logger.info(
            "Analytics events saved successfully",
            events_count=len(events_to_insert),
            device_ids=[str(e.device_id) for e in events_to_insert[:5]]  # Логируем только первые 5 для примера
        )
        
        return {
            "status": "success",
            "processed_events": len(events_to_insert),
            "message": "Events saved successfully"
        }
        
    except Exception as e:
        await db.rollback()
        logger.error("Error saving analytics events", error=str(e), exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to save analytics events",
                "details": {"error": str(e)}
            }
        )


@router.get("/stats/summary")
async def get_stats_summary(
    db: AsyncSession = Depends(get_db)
) -> dict:
    """
    Получить краткую сводку по аналитике (для админа)
    """
    try:
        # Подсчитываем общую статистику
        queries = {
            "total_events": "SELECT COUNT(*) FROM usage_events",
            "unique_devices": "SELECT COUNT(DISTINCT device_id) FROM usage_events", 
            "events_today": """
                SELECT COUNT(*) FROM usage_events 
                WHERE created_at >= CURRENT_DATE
            """,
            "top_events": """
                SELECT event_name, COUNT(*) as count 
                FROM usage_events 
                GROUP BY event_name 
                ORDER BY count DESC 
                LIMIT 10
            """
        }
        
        stats = {}
        
        for key, query in queries.items():
            if key == "top_events":
                result = await db.execute(text(query))
                stats[key] = [{"event": row[0], "count": row[1]} for row in result.fetchall()]
            else:
                result = await db.execute(text(query))
                stats[key] = result.scalar()
        
        logger.info("Stats summary requested", stats=stats)
        return stats
        
    except Exception as e:
        logger.error("Error getting stats summary", error=str(e))
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get statistics summary",
                "details": {"error": str(e)}
            }
        )