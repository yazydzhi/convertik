"""Модель курса валют"""

from sqlalchemy import Column, Integer, String, Numeric, DateTime, func
from sqlalchemy.sql import text
from ..database import Base


class Rate(Base):
    """Модель курса валют"""
    __tablename__ = "rates"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(3), nullable=False, unique=True, index=True)  # ISO код валюты (USD, EUR, etc.)
    value = Column(Numeric(18, 6), nullable=False)  # Сколько рублей за 1 единицу валюты
    updated_at = Column(
        DateTime(timezone=True), 
        nullable=False,
        default=func.now(),
        onupdate=func.now(),
        server_default=text('CURRENT_TIMESTAMP')
    )

    def __repr__(self):
        return f"<Rate(code='{self.code}', value={self.value})>"