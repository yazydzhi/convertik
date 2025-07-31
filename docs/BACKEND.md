

# BACKEND.md  
> 🖥️ Подробная спецификация серверной части «Конвертик»  
> Версия: 1.0 (31 июля 2025)

---

## 1. Обзор

Бэкэнд реализован на **Python 3.11** с использованием **FastAPI** и служит
единым источником данных для мобильного приложения:

* отдаёт актуальные курсы валют (`/rates`);
* принимает batched‑события аналитики (`/stats`);
* валидирует квитанции StoreKit 2 (`/iap/verify`);
* хранит push‑токены и по запросу рассылает уведомления (`/admin/push/send`);
* по cron‑задаче обновляет курсы из внешнего API.

Архитектура сервиса stateless; горизонтальное масштабирование достигается
раскруткой нескольких инстансов за балансировщиком. Состояние хранится
в PostgreSQL; Redis используется для кеша и rate‑limit.

---

## 2. Каталоги и структура проекта

```
backend/
│
├ app/
│   ├ __init__.py
│   ├ main.py              # create_app(), маршруты, middlewares
│   ├ config.py            # Pydantic Settings
│   ├ db.py                # AsyncSession, engine, Base
│   ├ models/              # SQLAlchemy ORM модели
│   │     ├ rate.py
│   │     ├ usage_event.py
│   │     └ iap_receipt.py
│   ├ routes/
│   │     ├ rates.py
│   │     ├ stats.py
│   │     ├ iap.py
│   │     ├ push.py
│   │     └ admin.py
│   ├ services/
│   │     ├ rates_service.py   # логика обновления курсов
│   │     ├ iap_service.py     # проверка чека StoreKit
│   │     ├ analytics_service.py
│   │     └ push_service.py
│   ├ tasks/
│   │     └ scheduler.py       # APScheduler cron‑job
│   └ utils/
│         └ security.py        # rate‑limit, token check
│
├ alembic/            # миграции БД
├ requirements.txt
└ docker-compose.yml
```

---

## 3. Зависимости (`requirements.txt`)

| Пакет          | Версия | Назначение                               |
|----------------|--------|------------------------------------------|
| fastapi        | 0.111  | ASGI‑фреймворк                           |
| uvicorn[standard]| 0.29 | ASGI‑сервер                              |
| sqlalchemy     | 2.0    | ORM                                      |
| asyncpg        | 0.29   | async‑драйвер PostgreSQL                 |
| apscheduler    | 3.10   | планировщик cron‑задач                   |
| httpx          | 0.27   | HTTP‑клиент для внешних API              |
| pydantic       | 2.7    | схемы / валидация                        |
| redis          | 5.0    | кэш, limiter                             |
| python‑jose    | 3.3    | подписание JWT для APNs                  |
| boto3*         | —      | S3 backup dumps (опц.)                   |
| pytest         | 8.2    | тестирование                             |

\* при необходимости S3‑бэкапов.

---

## 4. Конфигурация (`config.py`)

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    db_url: str
    redis_url: str = "redis://localhost:6379/0"
    rates_api_url: str = "https://openexchangerates.org/api/latest.json"
    rates_api_key: str
    admin_token: str
    apns_key: str
    apns_key_id: str
    apns_team_id: str

    class Config:
        env_file = ".env"
```

---

## 5. Обновление курсов

*Задача `update_rates()`*

1. Запрашивает внешнее API `rates_api_url?app_id=<key>&base=RUB`.
2. Парсит JSON `{ "timestamp": 1690812000, "rates": { "USD": 0.0112, … } }`.
3. В транзакции:
   * удаляет старую запись валюты `code` или обновляет её `value`, `updated_at`.
4. Сохраняет `updated_at` в Redis для быстрого ответа `/rates`.
5. Планировщик APScheduler запускает задачу каждые 6 часов.

*Отказоустойчивость*: при неудаче запрос повторяется с backoff до 3 раз; лог
ошибки отправляется в Sentry/Grafana alert.

---

## 6. Бизнес‑логика эндпоинтов

### 6.1 `/rates` (GET)

```python
@router.get("/rates", response_model=RateResponse)
async def get_rates():
    cache = await redis.get("rates_cache")
    if cache:
        return json.loads(cache)
    # fallback к БД
    async with async_sessionmaker() as session:
        rows = await session.execute(select(Rate))
        data = {r.code: float(r.value) for r in rows.scalars()}
    updated_at = max(r.updated_at for r in rows.scalars())
    resp = {"updated_at": updated_at, "rates": data}
    await redis.set("rates_cache", json.dumps(resp), ex=3600)
    return resp
```

### 6.2 `/stats` (POST)

*Получает список событий → валидация схемы → copy‑from bulk insert в
`usage_events` (SQLAlchemy `session.execute(values_list))`.  
*Rate‑limit* 100 запросов в 5 минут с одного IP.

### 6.3 `/iap/verify` (POST)

1. Принимает base64‑квитанцию.  
2. Отправляет к App Store Server API v2 `POST /verifyReceipt`.  
3. Парсит `latest_receipt_info` → ищет product_id `convertik_premium_month`.  
4. Если найдено и не истекло («expires_date_ms» > now) → OK.  
5. Записывает/обновляет `iap_receipts` (upsert).  
6. В Redis помечает `device_id:premium=true` TTL=30 дней для оптимизации.

### 6.4 `/push/register` (POST)

Сохраняет токен устройства в `push_tokens`  
`(device_id, token, platform, locale, is_premium)` с on conflict do update.

### 6.5 `/admin/push/send` (POST)

*Требует заголовок `X-Admin-Token`*.

Формирует выборку токенов по сегменту → шардирует по batch 1000 →
шлёт в APNs (`apns2`) или FCM.

---

## 7. Безопасность и защита

* CORS выключен.  
* Все эндпоинты принимает JSON ≤ 32 КиБ; валидация Pydantic.  
* Redis‑based rate‑limiter (ip + device_id).  
* Заголовок `User-Agent` проверяется на мобильное приложение.  
* `/admin/*` — Basic‑auth или токен в заголовке + VPN ACL.  
* Логи хранятся 14 дней (GDPR‑комплаенс).  
* База — ролевая модель доступа, только сервис‑аккаунт внутри VPC.

---

## 8. Логирование и мониторинг

* **structlog** → stdout → Docker JSON logs.  
* **Prometheus** metrics:  
  * `requests_total{path="/rates"}`  
  * `stats_events_total`  
  * `iap_verify_failures_total`.  
* **Grafana** дашборды: latency, 5xx rate, cron success.  
* Алерты: `/rates` P95 > 500 мс, `update_rates` > 6 ч неуспешен.

---

## 9. Тесты

| Категория | Фреймворк | Охват |
|-----------|-----------|-------|
| Unit      | PyTest    | бизнес‑логика сервисов ≥ 80 % |
| API       | httpx     | все позитивные + негативные сценарии |
| DB        | alembic revision test | миграции «вниз‑вверх» |
| Contract  | Schemathesis | тест JSON‑схем OpenAPI |

CI на GitHub Actions: `lint → pytest –cov → build docker → push`.

---

## 10. Локальный запуск

```bash
git clone https://github.com/yourname/convertik.git
cd convertik/backend
cp .env.example .env   # заполните ключи
docker compose up --build
```

Контейнеры:
* `api` – FastAPI (порт 8000)  
* `db` – PostgreSQL 15 (порт 5432)  
* `redis` – Redis 7 (порт 6379)  

Swagger UI: <http://localhost:8000/docs>

---

## 11. Деплой (prod)

* Образ публикуется в GHCR: `ghcr.io/yourname/convertik-api:sha`  
* Helm‑chart или docker compose на VPS.  
* Env‑vars через GitHub Secrets + docker swarm secrets.  
* Migrations — `alembic upgrade head` в entrypoint.

---

## 12. Будущее развитие

* Поддержка **Android** push (FCM).  
* Кэш Cloudflare Workers для `/rates`.  
* Расчёт MAU/WAU materialized view + API `/metrics`.  
* gRPC‑stream для live‑курсов (возможно, WebSocket).

---