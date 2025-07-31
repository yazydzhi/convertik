"""Pydantic схемы для API"""

from pydantic import BaseModel, Field, ConfigDict
from typing import Dict, Any, List, Optional
from datetime import datetime
import uuid


# Схемы для курсов валют
class RateResponse(BaseModel):
    """Ответ с курсами валют"""
    model_config = ConfigDict(from_attributes=True)
    
    updated_at: datetime
    base: str = "RUB"  # Базовая валюта
    rates: Dict[str, float]  # Курсы валют: {"USD": 0.0112, "EUR": 0.0101}


class RateSchema(BaseModel):
    """Схема отдельного курса валюты"""
    model_config = ConfigDict(from_attributes=True)
    
    code: str = Field(..., max_length=3, description="ISO код валюты")
    value: float = Field(..., gt=0, description="Курс валюты к рублю")
    updated_at: datetime


# Схемы для аналитики
class UsageEventCreate(BaseModel):
    """Создание события аналитики"""
    name: str = Field(..., max_length=64, description="Название события")
    device_id: uuid.UUID = Field(..., description="ID устройства")
    ts: int = Field(..., description="Unix timestamp события")
    params: Optional[Dict[str, Any]] = Field(None, description="Дополнительные параметры")


class UsageEventBatch(BaseModel):
    """Batch событий аналитики (до 50 событий)"""
    events: List[UsageEventCreate] = Field(..., max_items=50, description="Список событий")


# Схемы для IAP
class IAPVerifyRequest(BaseModel):
    """Запрос на проверку квитанции IAP"""
    receipt_data: str = Field(..., description="Base64 данные квитанции")
    device_id: uuid.UUID = Field(..., description="ID устройства")


class IAPVerifyResponse(BaseModel):
    """Ответ проверки квитанции IAP"""
    premium: bool = Field(..., description="Статус Premium подписки")
    expires_at: Optional[datetime] = Field(None, description="Дата окончания подписки")


# Схемы для push-уведомлений
class PushTokenRegister(BaseModel):
    """Регистрация push-токена"""
    device_id: uuid.UUID = Field(..., description="ID устройства")
    token: str = Field(..., max_length=255, description="Push-токен")
    platform: str = Field(..., pattern="^(ios|android)$", description="Платформа")
    locale: Optional[str] = Field(None, max_length=10, description="Локаль (ru-RU)")
    app_version: Optional[str] = Field(None, max_length=20, description="Версия приложения")


class PushSendRequest(BaseModel):
    """Запрос на отправку push-уведомления"""
    message: str = Field(..., max_length=200, description="Текст уведомления")
    title: Optional[str] = Field(None, max_length=100, description="Заголовок")
    segment: Optional[str] = Field("all", description="Сегмент пользователей")
    payload: Optional[Dict[str, Any]] = Field(None, description="Дополнительные данные")


# Общие схемы
class HealthResponse(BaseModel):
    """Ответ health check"""
    status: str = "healthy"
    version: str
    timestamp: float


class ErrorResponse(BaseModel):
    """Стандартный ответ с ошибкой"""
    error: Dict[str, Any] = Field(
        ..., 
        description="Информация об ошибке",
        example={
            "code": 400,
            "message": "Bad Request",
            "details": {"field": "validation error"}
        }
    )