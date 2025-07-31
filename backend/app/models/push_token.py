"""Модель push-токенов устройств"""

from sqlalchemy import Column, String, Boolean, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import text
from ..database import Base


class PushToken(Base):
    """Модель push-токенов для уведомлений"""
    __tablename__ = "push_tokens"
    
    device_id = Column(UUID(as_uuid=True), primary_key=True)  # Анонимный UUID клиента
    token = Column(String(255), nullable=False)  # Push-токен устройства  
    platform = Column(String(10), nullable=False)  # "ios" или "android"
    locale = Column(String(10), nullable=True)  # Язык интерфейса (ru-RU, en-US)
    is_premium = Column(Boolean, nullable=False, default=False)  # Статус подписки
    app_version = Column(String(20), nullable=True)  # Версия приложения
    created_at = Column(
        DateTime(timezone=True), 
        nullable=False,
        default=func.now(),
        server_default=text('CURRENT_TIMESTAMP')
    )
    updated_at = Column(
        DateTime(timezone=True), 
        nullable=False,
        default=func.now(),
        onupdate=func.now(),
        server_default=text('CURRENT_TIMESTAMP')
    )

    def __repr__(self):
        return f"<PushToken(device_id='{self.device_id}', platform='{self.platform}')>"