from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Настройки приложения"""
    
    # База данных
    database_url: str = "postgresql+asyncpg://convertik:convertik@localhost/convertik"
    
    # Redis
    redis_url: str = "redis://localhost:6379/0"
    
    # Внешние API
    rates_api_url: str = "https://openexchangerates.org/api/latest.json"
    rates_api_key: Optional[str] = None
    
    # Безопасность
    admin_token: str = "your-secret-admin-token"
    
    # APNs (Apple Push Notification service)
    apns_key: Optional[str] = None
    apns_key_id: Optional[str] = None
    apns_team_id: Optional[str] = None
    
    # Rate Limiting (Free Plan: 900 requests/month)
    rates_update_interval_minutes: int = 60  # минимум 1 час между запросами к API
    rates_check_interval_minutes: int = 30   # проверка каждые 30 минут
    
    # Приложение
    app_name: str = "Convertik API"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Логирование
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


# Глобальный экземпляр настроек
settings = Settings() 