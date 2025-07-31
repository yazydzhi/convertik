"""Модель событий аналитики"""

from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import text
import uuid
from ..database import Base


class UsageEvent(Base):
    """Модель событий пользователя для аналитики"""
    __tablename__ = "usage_events"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(UUID(as_uuid=True), nullable=False, index=True)  # Анонимный UUID клиента
    event_name = Column(String(64), nullable=False, index=True)  # app_open, conversion, ad_impression, etc.
    payload = Column(JSONB, nullable=True)  # Параметры события в JSON формате
    created_at = Column(
        DateTime(timezone=True), 
        nullable=False,
        default=func.now(),
        server_default=text('CURRENT_TIMESTAMP')
    )

    def __repr__(self):
        return f"<UsageEvent(device_id='{self.device_id}', event='{self.event_name}')>"