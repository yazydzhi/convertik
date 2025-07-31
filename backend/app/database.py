"""Конфигурация базы данных и Redis"""

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase
import redis.asyncio as redis
from .config import settings


# SQLAlchemy Base класс
class Base(DeclarativeBase):
    pass


# Создание async engine для PostgreSQL
engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,  # Логировать SQL запросы в дебаге
    future=True,
)

# Фабрика для создания async сессий
async_sessionmaker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


# Redis соединение
redis_client = None


async def get_redis():
    """Получить Redis клиент"""
    global redis_client
    if redis_client is None:
        redis_client = redis.from_url(settings.redis_url)
    return redis_client


async def get_db():
    """Dependency для получения DB сессии"""
    async with async_sessionmaker() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db():
    """Инициализация базы данных (создание таблиц)"""
    async with engine.begin() as conn:
        # Импортируем все модели чтобы они были зарегистрированы
        from .models import rate, usage_event, iap_receipt, push_token  # noqa
        
        # Создаем все таблицы
        await conn.run_sync(Base.metadata.create_all)


async def close_db():
    """Закрытие соединений"""
    await engine.dispose()
    if redis_client:
        await redis_client.close()