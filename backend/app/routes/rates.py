"""API роуты для курсов валют"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
import json
import structlog

from ..database import get_db, get_redis
from ..models.rate import Rate
from ..schemas import RateResponse, RateSchema, CurrencyNamesResponse

logger = structlog.get_logger()
router = APIRouter()


@router.get("/rates", response_model=RateResponse)
async def get_rates(
    db: AsyncSession = Depends(get_db),
) -> RateResponse:
    """
    Получить актуальные курсы валют
    
    Сначала проверяет кэш Redis, если нет - обращается к базе данных
    """
    try:
        # Получаем Redis клиент
        redis_client = await get_redis()
        
        # Проверяем кэш
        cached_rates = await redis_client.get("rates_cache")
        if cached_rates:
            logger.info("Returning rates from cache")
            return RateResponse.model_validate_json(cached_rates)
        
        # Если кэша нет, читаем из БД
        logger.info("Reading rates from database")
        result = await db.execute(select(Rate))
        rates = result.scalars().all()
        
        if not rates:
            logger.warning("No rates found in database")
            # Возвращаем пустой результат с текущим временем
            response_data = {
                "updated_at": datetime.utcnow(),
                "base": "RUB", 
                "rates": {}
            }
            return RateResponse(**response_data)
        
        # Формируем ответ
        rates_dict = {rate.code: float(rate.value) for rate in rates}
        updated_at = max(rate.updated_at for rate in rates)
        
        response_data = {
            "updated_at": updated_at,
            "base": "RUB",
            "rates": rates_dict
        }
        
        # Кэшируем результат на 1 час (3600 секунд)
        await redis_client.setex(
            "rates_cache",
            3600,  # TTL в секундах
            json.dumps(response_data, default=str)
        )
        
        logger.info("Rates cached successfully", rates_count=len(rates_dict))
        return RateResponse(**response_data)
        
    except Exception as e:
        logger.error("Error getting rates", error=str(e), exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get exchange rates",
                "details": {"error": str(e)}
            }
        )


@router.get("/currency-names", response_model=CurrencyNamesResponse)
async def get_currency_names(
    db: AsyncSession = Depends(get_db),
) -> CurrencyNamesResponse:
    """
    Получить названия валют
    
    Возвращает словарь с названиями всех доступных валют
    """
    try:
        # Получаем Redis клиент
        redis_client = await get_redis()
        
        # Проверяем кэш
        cached_names = await redis_client.get("currency_names_cache")
        if cached_names:
            logger.info("Returning currency names from cache")
            return CurrencyNamesResponse.model_validate_json(cached_names)
        
        # Если кэша нет, читаем из БД
        logger.info("Reading currency names from database")
        result = await db.execute(select(Rate))
        rates = result.scalars().all()
        
        if not rates:
            logger.warning("No rates found in database")
            # Возвращаем пустой результат с текущим временем
            response_data = {
                "updated_at": datetime.utcnow(),
                "names": {}
            }
            return CurrencyNamesResponse(**response_data)
        
        # Формируем словарь названий
        names_dict = {rate.code: rate.name for rate in rates}
        updated_at = max(rate.updated_at for rate in rates)
        
        response_data = {
            "updated_at": updated_at,
            "names": names_dict
        }
        
        # Кэшируем результат на 24 часа (86400 секунд)
        await redis_client.setex(
            "currency_names_cache",
            86400,  # TTL в секундах
            json.dumps(response_data, default=str)
        )
        
        logger.info("Currency names cached successfully", names_count=len(names_dict))
        return CurrencyNamesResponse(**response_data)
        
    except Exception as e:
        logger.error("Error getting currency names", error=str(e), exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get currency names",
                "details": {"error": str(e)}
            }
        )


@router.get("/rates/{currency_code}", response_model=RateSchema)  
async def get_rate_by_code(
    currency_code: str,
    db: AsyncSession = Depends(get_db)
) -> RateSchema:
    """
    Получить курс конкретной валюты по коду
    """
    try:
        currency_code = currency_code.upper()
        
        result = await db.execute(
            select(Rate).where(Rate.code == currency_code)
        )
        rate = result.scalar_one_or_none()
        
        if not rate:
            raise HTTPException(
                status_code=404,
                detail={
                    "code": 404,
                    "message": f"Currency rate not found",
                    "details": {"currency_code": currency_code}
                }
            )
        
        return RateSchema.model_validate(rate)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error getting rate by code", currency_code=currency_code, error=str(e))
        raise HTTPException(
            status_code=500,
            detail={
                "code": 500,
                "message": "Failed to get currency rate",
                "details": {"error": str(e)}
            }
        )