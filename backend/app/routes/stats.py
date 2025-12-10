"""API роуты для аналитики"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import List, Optional
import structlog
from datetime import datetime, timezone, timedelta
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
            # Конвертируем timestamp в datetime с UTC часовым поясом
            event_time = datetime.fromtimestamp(event.ts, tz=timezone.utc)

            # Конвертируем device_id из строки в UUID
            try:
                device_uuid = uuid.UUID(event.device_id)
            except ValueError:
                logger.warning(f"Invalid device_id format: {event.device_id}")
                continue

            # Создаем объект события
            usage_event = UsageEvent(
                device_id=device_uuid,
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
                WHERE created_at >= (NOW() AT TIME ZONE 'UTC')::date
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


@router.get("/stats/metrics")
async def get_metrics_for_monitoring(
    period: str = Query("day", regex="^(day|week|month)$", description="Период для метрик: day, week, month"),
    start_date: Optional[str] = Query(None, description="Начальная дата в формате ISO (YYYY-MM-DD или YYYY-MM-DDTHH:MM:SS). Если не указана, используется текущий период."),
    end_date: Optional[str] = Query(None, description="Конечная дата в формате ISO (YYYY-MM-DD или YYYY-MM-DDTHH:MM:SS). Если не указана, используется текущее время."),
    db: AsyncSession = Depends(get_db)
) -> dict:
    """
    Получить метрики для системы мониторинга (azg_admin)

    Возвращает продуктовые метрики в формате, совместимом с azg_admin.
    Метрики вычисляются за указанный период (не накопительные).

    Формат ответа:
    {
        "timestamp": "2025-12-10T12:00:00Z",
        "metrics": {
            "dau": 150,
            "wau": 850,
            "mau": 3500,
            "events_last_24h": 200,
            "events_per_user": 2.86,
            "event_app_open": 8000,
            "event_conversion": 1500,
            ...
        }
    }
    """
    try:
        now = datetime.now(timezone.utc)

        # Парсим даты, если указаны
        if start_date:
            try:
                # Пробуем парсить с временем
                if 'T' in start_date:
                    start_datetime = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
                else:
                    # Только дата - начало дня
                    start_datetime = datetime.fromisoformat(start_date).replace(hour=0, minute=0, second=0, microsecond=0)
                    start_datetime = start_datetime.replace(tzinfo=timezone.utc)
            except ValueError:
                raise HTTPException(
                    status_code=400,
                    detail={
                        "code": 400,
                        "message": "Invalid start_date format. Use ISO format: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS",
                        "details": {"start_date": start_date}
                    }
                )
        else:
            start_datetime = None

        if end_date:
            try:
                # Пробуем парсить с временем
                if 'T' in end_date:
                    end_datetime = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
                else:
                    # Только дата - конец дня
                    end_datetime = datetime.fromisoformat(end_date).replace(hour=23, minute=59, second=59, microsecond=999999)
                    end_datetime = end_datetime.replace(tzinfo=timezone.utc)
            except ValueError:
                raise HTTPException(
                    status_code=400,
                    detail={
                        "code": 400,
                        "message": "Invalid end_date format. Use ISO format: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS",
                        "details": {"end_date": end_date}
                    }
                )
        else:
            end_datetime = now

        # Если указаны конкретные даты, используем их
        if start_datetime:
            start_date = start_datetime
            # Вычисляем количество дней для названия метрики
            if end_datetime:
                interval_days = (end_datetime - start_datetime).days + 1
            else:
                interval_days = (now - start_datetime).days + 1
        else:
            # Определяем период для вычисления метрик (по умолчанию)
            if period == "day":
                start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
                interval_days = 1
            elif period == "week":
                start_date = now - timedelta(days=7)
                interval_days = 7
            elif period == "month":
                start_date = now - timedelta(days=30)
                interval_days = 30
            else:
                start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
                interval_days = 1
            end_datetime = now

        # Валидация: start_date не должна быть позже end_date
        if start_date > end_datetime:
            raise HTTPException(
                status_code=400,
                detail={
                    "code": 400,
                    "message": "start_date cannot be later than end_date",
                    "details": {
                        "start_date": start_date.isoformat(),
                        "end_date": end_datetime.isoformat()
                    }
                }
            )

        # Вычисляем DAU (Daily Active Users) - уникальные устройства за выбранный день
        # Если указана конкретная дата, используем её, иначе сегодня
        dau_date = start_date.date() if start_datetime else now.date()
        dau_query = """
            SELECT COUNT(DISTINCT device_id)
            FROM usage_events
            WHERE created_at >= :dau_start AND created_at < :dau_end
        """
        dau_start = datetime.combine(dau_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        dau_end = dau_start + timedelta(days=1)
        dau_result = await db.execute(
            text(dau_query),
            {"dau_start": dau_start, "dau_end": dau_end}
        )
        dau = dau_result.scalar() or 0

        # Вычисляем WAU (Weekly Active Users) - уникальные устройства за последние 7 дней от end_date
        wau_start = end_datetime.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=7)
        wau_query = """
            SELECT COUNT(DISTINCT device_id)
            FROM usage_events
            WHERE created_at >= :wau_start AND created_at <= :wau_end
        """
        wau_result = await db.execute(
            text(wau_query),
            {"wau_start": wau_start, "wau_end": end_datetime}
        )
        wau = wau_result.scalar() or 0

        # Вычисляем MAU (Monthly Active Users) - уникальные устройства за последние 30 дней от end_date
        mau_start = end_datetime.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=30)
        mau_query = """
            SELECT COUNT(DISTINCT device_id)
            FROM usage_events
            WHERE created_at >= :mau_start AND created_at <= :mau_end
        """
        mau_result = await db.execute(
            text(mau_query),
            {"mau_start": mau_start, "mau_end": end_datetime}
        )
        mau = mau_result.scalar() or 0

        # Вычисляем события за период (не накопительные)
        events_period_query = """
            SELECT COUNT(*)
            FROM usage_events
            WHERE created_at >= :start_date AND created_at <= :end_date
        """
        events_result = await db.execute(
            text(events_period_query),
            {"start_date": start_date, "end_date": end_datetime}
        )
        events_period = events_result.scalar() or 0

        # Вычисляем события за последние 24 часа от end_date
        events_24h_start = end_datetime - timedelta(hours=24)
        events_24h_query = """
            SELECT COUNT(*)
            FROM usage_events
            WHERE created_at >= :events_24h_start AND created_at <= :events_24h_end
        """
        events_24h_result = await db.execute(
            text(events_24h_query),
            {"events_24h_start": events_24h_start, "events_24h_end": end_datetime}
        )
        events_24h = events_24h_result.scalar() or 0

        # Вычисляем уникальные устройства за период
        unique_devices_period_query = """
            SELECT COUNT(DISTINCT device_id)
            FROM usage_events
            WHERE created_at >= :start_date AND created_at <= :end_date
        """
        unique_devices_result = await db.execute(
            text(unique_devices_period_query),
            {"start_date": start_date, "end_date": end_datetime}
        )
        unique_devices_period = unique_devices_result.scalar() or 0

        # Вычисляем события на пользователя за период
        events_per_user = round(events_period / unique_devices_period, 2) if unique_devices_period > 0 else 0

        # Вычисляем Stickiness (DAU/MAU)
        stickiness = round((dau / mau * 100), 2) if mau > 0 else 0

        # Получаем топ событий за период
        top_events_query = """
            SELECT event_name, COUNT(*) as count
            FROM usage_events
            WHERE created_at >= :start_date AND created_at <= :end_date
            GROUP BY event_name
            ORDER BY count DESC
            LIMIT 10
        """
        top_events_result = await db.execute(
            text(top_events_query),
            {"start_date": start_date, "end_date": end_datetime}
        )
        top_events = top_events_result.fetchall()

        # Формируем метрики
        metrics = {
            "dau": dau,
            "wau": wau,
            "mau": mau,
            "stickiness_percent": stickiness,
            f"events_last_{interval_days}d": events_period,
            "events_last_24h": events_24h,
            "unique_devices_period": unique_devices_period,
            "events_per_user": events_per_user,
        }

        # Добавляем метрики для каждого события из top_events
        for event_name, count in top_events:
            metrics[f"event_{event_name}"] = count

        logger.info(
            "Metrics requested for monitoring",
            period=period,
            start_date=start_date.isoformat() if start_datetime else None,
            end_date=end_datetime.isoformat(),
            dau=dau,
            wau=wau,
            mau=mau,
            events_period=events_period
        )

        return {
            "timestamp": end_datetime.isoformat(),
            "period": {
                "start": start_date.isoformat(),
                "end": end_datetime.isoformat(),
                "days": interval_days
            },
            "metrics": metrics
        }

    except Exception as e:
        logger.error("Error getting metrics for monitoring", error=str(e), exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get metrics for monitoring",
                "details": {"error": str(e)}
            }
        )
