"""Модель квитанций IAP (In-App Purchase)"""

from sqlalchemy import Column, String, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import text
from ..database import Base


class IAPReceipt(Base):
    """Модель квитанций покупок в приложении"""
    __tablename__ = "iap_receipts"
    
    original_tx_id = Column(String, primary_key=True)  # Уникальный ID покупки от Apple
    device_id = Column(UUID(as_uuid=True), nullable=False, index=True)  # Ссылка на устройство
    product_id = Column(String, nullable=False)  # SKU подписки (например, convertik_premium_month)
    expires_at = Column(DateTime(timezone=True), nullable=False)  # Дата окончания подписки
    last_check = Column(
        DateTime(timezone=True), 
        nullable=False,
        default=func.now(),
        onupdate=func.now(),
        server_default=text('CURRENT_TIMESTAMP')
    )  # Последняя валидация квитанции

    def __repr__(self):
        return f"<IAPReceipt(tx_id='{self.original_tx_id}', product='{self.product_id}')>"