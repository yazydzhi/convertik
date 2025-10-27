"""API роуты для In-App Purchases"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional
import structlog
import httpx
import base64
from datetime import datetime, timezone

from ..database import get_db
from ..models.iap_receipt import IAPReceipt
from ..schemas import IAPVerifyRequest, IAPVerifyResponse
from ..config import settings

logger = structlog.get_logger()
router = APIRouter()


async def verify_receipt_with_apple(
    receipt_data: str,
    use_sandbox: bool = False
) -> dict:
    """
    Проверка квитанции через Apple App Store
    
    Args:
        receipt_data: Base64-encoded receipt data
        use_sandbox: Whether to use sandbox environment
    
    Returns:
        Apple's verification response
    """
    # Определяем URL для проверки
    if use_sandbox:
        verify_url = "https://sandbox.itunes.apple.com/verifyReceipt"
    else:
        verify_url = "https://buy.itunes.apple.com/verifyReceipt"
    
    # Секретный ключ для проверки (если используется)
    verify_payload = {
        "receipt-data": receipt_data,
        "password": getattr(settings, "app_store_shared_secret", None),  # Опционально
        "exclude-old-transactions": True
    }
    
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(verify_url, json=verify_payload)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPError as e:
        logger.error(
            "Failed to verify receipt with Apple",
            error=str(e),
            use_sandbox=use_sandbox
        )
        raise HTTPException(
            status_code=503,
            detail={
                "code": 503,
                "message": "Failed to verify receipt with Apple",
                "details": {"error": str(e)}
            }
        )


@router.post("/iap/verify", response_model=IAPVerifyResponse)
async def verify_iap_receipt(
    request: IAPVerifyRequest,
    db: AsyncSession = Depends(get_db)
) -> IAPVerifyResponse:
    """
    Проверка квитанции IAP
    
    Алгоритм проверки согласно рекомендациям Apple:
    1. Сначала проверяем в production
    2. Если получаем код ошибки 21007 (sandbox receipt used in production),
       проверяем в sandbox
    """
    logger.info(
        "Verifying IAP receipt",
        device_id=str(request.device_id)
    )
    
    # Сначала пробуем production
    apple_response = await verify_receipt_with_apple(
        request.receipt_data,
        use_sandbox=False
    )
    
    status = apple_response.get("status")
    
    # Если получили код 21007, значит это sandbox receipt, проверяем в sandbox
    if status == 21007:
        logger.info(
            "Received sandbox receipt in production, verifying in sandbox",
            device_id=str(request.device_id)
        )
        apple_response = await verify_receipt_with_apple(
            request.receipt_data,
            use_sandbox=True
        )
        status = apple_response.get("status")
    
    # Проверяем статус ответа от Apple
    if status != 0:
        logger.error(
            "Apple verification failed",
            status=status,
            device_id=str(request.device_id)
        )
        raise HTTPException(
            status_code=400,
            detail={
                "code": 400,
                "message": "Receipt verification failed",
                "details": {"apple_status": status}
            }
        )
    
    # Извлекаем информацию о покупках
    receipt = apple_response.get("receipt", {})
    in_app = receipt.get("in_app", [])
    
    # Проверяем наличие подписки
    is_premium = False
    expires_at: Optional[datetime] = None
    
    for purchase in in_app:
        # Проверяем product_id
        product_id = purchase.get("product_id")
        if product_id == "com.azg.Convertik":
            # Проверяем транзакцию
            transaction_id = purchase.get("original_transaction_id")
            
            # Получаем или создаем запись в БД
            stmt = select(IAPReceipt).where(
                IAPReceipt.original_tx_id == transaction_id
            )
            result = await db.execute(stmt)
            iap_receipt = result.scalar_one_or_none()
            
            # Определяем дату истечения подписки
            expires_date_ms = purchase.get("expires_date_ms")
            if expires_date_ms:
                expires_at = datetime.fromtimestamp(
                    int(expires_date_ms) / 1000,
                    tz=timezone.utc
                )
                
                # Проверяем, не истекла ли подписка
                if expires_at > datetime.now(tz=timezone.utc):
                    is_premium = True
                    
                    # Обновляем или создаем запись в БД
                    if iap_receipt:
                        iap_receipt.expires_at = expires_at
                        iap_receipt.last_check = datetime.now(tz=timezone.utc)
                    else:
                        iap_receipt = IAPReceipt(
                            original_tx_id=transaction_id,
                            device_id=request.device_id,
                            product_id=product_id,
                            expires_at=expires_at,
                            last_check=datetime.now(tz=timezone.utc)
                        )
                        db.add(iap_receipt)
                    
                    await db.commit()
                    
                    logger.info(
                        "Premium subscription found",
                        device_id=str(request.device_id),
                        expires_at=expires_at.isoformat()
                    )
    
    logger.info(
        "Receipt verification completed",
        device_id=str(request.device_id),
        is_premium=is_premium,
        expires_at=expires_at.isoformat() if expires_at else None
    )
    
    return IAPVerifyResponse(
        premium=is_premium,
        expires_at=expires_at
    )

