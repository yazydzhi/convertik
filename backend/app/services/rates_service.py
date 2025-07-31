"""Сервис для обновления курсов валют"""

import httpx
import structlog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any, Optional
from datetime import datetime
import json

from ..config import settings
from ..database import async_sessionmaker, get_redis
from ..models.rate import Rate

logger = structlog.get_logger()


class RatesService:
    """Сервис для работы с курсами валют"""
    
    def __init__(self):
        self.api_url = settings.rates_api_url
        self.api_key = settings.rates_api_key
        
    async def should_update_rates(self) -> bool:
        """
        Проверяет, нужно ли обновлять курсы валют (rate limiting)
        Обновляем не чаще чем раз в час для соблюдения лимитов Free Plan
        
        Returns:
            bool: True если можно обновлять, False если нужно подождать
        """
        try:
            # Получаем последнюю запись из БД
            async with async_sessionmaker() as session:
                result = await session.execute(
                    select(Rate).order_by(Rate.updated_at.desc()).limit(1)
                )
                latest_rate = result.scalar_one_or_none()
                
                if not latest_rate:
                    logger.info("No rates in database, update needed")
                    return True
                
                # Проверяем время последнего обновления
                time_since_update = datetime.utcnow() - latest_rate.updated_at.replace(tzinfo=None)
                minutes_since_update = time_since_update.total_seconds() / 60
                min_interval = settings.rates_update_interval_minutes
                
                if minutes_since_update >= min_interval:
                    logger.info(
                        "Rate limiting check: update allowed",
                        minutes_since_last_update=round(minutes_since_update, 1),
                        min_interval_minutes=min_interval
                    )
                    return True
                else:
                    logger.info(
                        "Rate limiting check: update skipped",
                        minutes_since_last_update=round(minutes_since_update, 1),
                        min_interval_minutes=min_interval,
                        wait_minutes=round(min_interval - minutes_since_update, 1)
                    )
                    return False
                    
        except Exception as e:
            logger.error("Error checking rate limiting", error=str(e))
            # В случае ошибки разрешаем обновление
            return True

    async def update_rates_from_external_api(self, force: bool = False) -> Dict[str, Any]:
        """
        Обновляет курсы валют из внешнего API с учетом rate limiting
        
        Args:
            force: bool - принудительное обновление (игнорировать rate limiting)
        
        Returns:
            Dict с результатом операции
        """
        try:
            # Проверка rate limiting (если не принудительное обновление)
            if not force and not await self.should_update_rates():
                return {
                    "success": False, 
                    "skipped": True,
                    "reason": "Rate limiting: too soon since last update"
                }
            
            logger.info("Starting rates update from external API", forced=force)
            
            # Запрашиваем данные из внешнего API
            rates_data = await self._fetch_rates_from_api()
            
            if not rates_data:
                logger.error("No data received from external API")
                return {"success": False, "error": "No data from external API"}
            
            # Обновляем курсы в базе данных
            updated_count = await self._update_rates_in_database(rates_data)
            
            # Очищаем кэш
            await self._clear_rates_cache()
            
            logger.info(
                "Rates update completed successfully",
                updated_count=updated_count,
                rates_count=len(rates_data.get("rates", {}))
            )
            
            return {
                "success": True,
                "updated_count": updated_count,
                "rates_count": len(rates_data.get("rates", {})),
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error("Error updating rates", error=str(e), exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat()
            }
    
    async def _fetch_rates_from_api(self) -> Optional[Dict[str, Any]]:
        """Запрашивает курсы из внешнего API"""
        
        if not self.api_key:
            logger.warning("API key not configured, using mock data")
            # Возвращаем тестовые данные если нет ключа API
            return {
                "rates": {
                    "USD": 0.0112,  # 89.3 RUB за 1 USD
                    "EUR": 0.0101,  # 99.0 RUB за 1 EUR  
                    "GBP": 0.0087,  # 115.0 RUB за 1 GBP
                    "CNY": 0.1534,  # 6.52 RUB за 1 CNY
                    "JPY": 0.8203,  # 1.22 RUB за 1 JPY
                },
                "timestamp": int(datetime.utcnow().timestamp())
            }
        
        try:
            params = {
                "app_id": self.api_key,
                # Free plan only supports USD as base currency
                # We'll convert to RUB base in the code below
            }
            
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.get(self.api_url, params=params)
                response.raise_for_status()
                
                data = response.json()
                logger.info("External API response received", status_code=response.status_code)
                
                # Convert from USD-based rates to RUB-based rates
                if "rates" in data and "RUB" in data["rates"]:
                    usd_to_rub = data["rates"]["RUB"]  # e.g., 1 USD = 90 RUB
                    
                    # Convert all rates to RUB base
                    # If USD->EUR = 0.85 and USD->RUB = 90, then RUB->EUR = 0.85/90
                    rub_based_rates = {}
                    for currency, usd_rate in data["rates"].items():
                        if currency != "RUB":  # Skip RUB itself
                            rub_based_rates[currency] = usd_rate / usd_to_rub
                    
                    # Update the response to have RUB as base
                    data["base"] = "RUB"
                    data["rates"] = rub_based_rates
                    
                    logger.info("Converted rates from USD to RUB base", 
                              usd_to_rub_rate=usd_to_rub, 
                              currencies_count=len(rub_based_rates))
                
                return data
                
        except httpx.RequestError as e:
            logger.error("Network error fetching rates", error=str(e))
            raise
        except httpx.HTTPStatusError as e:
            logger.error("HTTP error fetching rates", status_code=e.response.status_code)
            raise
        except json.JSONDecodeError as e:
            logger.error("Invalid JSON in API response", error=str(e))
            raise
    
    async def _update_rates_in_database(self, rates_data: Dict[str, Any]) -> int:
        """Обновляет курсы в базе данных"""
        
        rates = rates_data.get("rates", {})
        if not rates:
            logger.warning("No rates in API response")
            return 0
        
        updated_count = 0
        
        async with async_sessionmaker() as session:
            try:
                for currency_code, rate_value in rates.items():
                    # Ищем существующую запись
                    result = await session.execute(
                        select(Rate).where(Rate.code == currency_code)
                    )
                    existing_rate = result.scalar_one_or_none()
                    
                    if existing_rate:
                        # Обновляем существующую
                        existing_rate.value = rate_value
                        existing_rate.updated_at = datetime.utcnow()
                        logger.debug("Updated existing rate", currency=currency_code, value=rate_value)
                    else:
                        # Создаем новую
                        new_rate = Rate(
                            code=currency_code,
                            value=rate_value,
                            updated_at=datetime.utcnow()
                        )
                        session.add(new_rate)
                        logger.debug("Created new rate", currency=currency_code, value=rate_value)
                    
                    updated_count += 1
                
                await session.commit()
                logger.info("Database transaction committed", updated_count=updated_count)
                
            except Exception as e:
                await session.rollback()
                logger.error("Database transaction failed", error=str(e))
                raise
        
        return updated_count
    
    async def _clear_rates_cache(self) -> None:
        """Очищает кэш курсов в Redis"""
        try:
            redis_client = await get_redis()
            await redis_client.delete("rates_cache")
            logger.info("Rates cache cleared")
        except Exception as e:
            logger.warning("Failed to clear rates cache", error=str(e))
            # Не критичная ошибка, не прерываем выполнение
    
    async def get_rates_stats(self) -> Dict[str, Any]:
        """Получает статистику по курсам валют"""
        async with async_sessionmaker() as session:
            try:
                result = await session.execute(select(Rate))
                rates = result.scalars().all()
                
                if not rates:
                    return {"total_currencies": 0, "last_updated": None}
                
                last_updated = max(rate.updated_at for rate in rates)
                
                return {
                    "total_currencies": len(rates),
                    "last_updated": last_updated.isoformat(),
                    "currencies": [rate.code for rate in rates]
                }
                
            except Exception as e:
                logger.error("Error getting rates stats", error=str(e))
                raise


# Глобальный экземпляр сервиса
rates_service = RatesService()