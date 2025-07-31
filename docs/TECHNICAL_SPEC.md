# Technical Specification

## Содержание
1. [Обзор](#обзор)
2. [Архитектура](#архитектура)
3. [Системные требования](#системные-требования)
4. [Технологический стек](#технологический-стек)
5. [Модели данных](#модели-данных)
6. [REST API](#rest-api)
7. [Безопасность](#безопасность)
8. [Нефункциональные требования](#нефункциональные-требования)
9. [Тестирование](#тестирование)
10. [Развёртывание и CI/CD](#развёртывание-и-ci-cd)

---

## Обзор

«Конвертик» — **оф‑лайн‑first** мобильный конвертер валют.  
*Ключевые особенности:*

* мгновенный запуск и расчёт без интернета благодаря локальному кэшу курсов;
* автоматическое фоновое обновление курсов при наличии сети;
* монетизация через баннеры **AdMob** + ежемесячная подписка **Premium** (отключает рекламу);
* сбор минимально‑необходимой анонимной аналитики (DAU/WAU/MAU, конверсии подписки, ретеншн);
* пуш‑уведомления для удержания и маркетинга.

Бэкенд предоставляет свежие курсы валют, принимает batched‑события аналитики и проверяет квитанции IAP.

---

## Архитектура

### Высокоуровневая схема

```
┌─────────────────────────────┐
│          iOS‑Клиент         │
│  • SwiftUI / Combine        │
│  • CoreData                 │
│  • StoreKit2 + AdMob        │
└─────────▲───────────┬───────┘
          │ HTTPS     │
          │           │
┌─────────┴───────────▼───────┐
│        FastAPI Backend      │
│ /rates      /stats          │
│ /iap/verify /push/register  │
│  ────────────┬────────────  │
│  Cron: update_rates()       │
└─────────▲───▲─┬─▲───────────┘
          │   │ │ │
  PostgreSQL   │ │  APNs
 (rates, stats)│ │
      Redis (*)│ │
               FCM (Android later)
```

> `(*)` — Redis опционально для кэша и rate‑limiting.

### Потоки

1. **Запуск приложения** → чтение `RateEntity` из CoreData → UI готов < 0.3 с.  
2. Параллельно `RatesService` запрашивает `/rates`; при успехе сохраняет новые значения.  
3. Пользователь вводит сумму → расчёт в `ConverterViewModel`, без сети.  
4. Каждое событие (`app_open`, `conversion`, `ad_impression` …) складывается в локальную очередь.  
   При появлении интернета очередь шлётся POST `/stats` (batch ≤ 50 событий).  
5. Подписка: квитанция → `/iap/verify` → ответ `{"premium": true}` → флаг сохранён в Keychain.  

---

## Системные требования

| Компонент            | Минимум                | Рекомендовано      |
|----------------------|------------------------|--------------------|
| **iOS**              | iOS 14.0, 100 МБ ОЗУ   | iOS 15+, A12 CPU   |
| **Backend**          | 1 vCPU, 512 МБ RAM     | 2 vCPU, 1 ГБ RAM   |
| **PostgreSQL**       | 12                     | 15                 |
| **Свободное место**  | 200 МБ (база + логи)   | 1 ГБ               |
| **Пропускная способность** | 1 Мбит/с           | 5 Мбит/с           |

---

## Технологический стек

| Слой          | Технологии                         |
|---------------|------------------------------------|
| iOS‑клиент    | Swift 5.9, SwiftUI, Combine, CoreData, StoreKit2, Google AdMob SDK, AppMetrica SDK |
| Backend       | Python 3.11, FastAPI, Uvicorn, SQLAlchemy 2.0, Pydantic |
| База данных   | PostgreSQL 15, Alembic (миграции)  |
| Кэш / очередь | Redis 7 (опц.)                     |
| Аналитика     | AppMetrica + собственный `/stats`  |
| Push          | APNs (HTTP/2 JWT), FCM (позже)     |
| Мониторинг    | Prometheus + Grafana (план)        |
| CI/CD         | GitHub Actions, Docker Compose     |

---

## Модели данных

### Таблица `rates`
| Поле        | Тип         | Описание                    |
|-------------|-------------|-----------------------------|
| id          | serial PK   |                             |
| code        | varchar(3)  | ISO валюта (EUR, USD …)     |
| value       | numeric(18,6)| Сколько рублей за 1 единицу |
| updated_at  | timestamp   | Дата последнего обновления  |

### Таблица `usage_events`
| Поле        | Тип          | Описание                    |
|-------------|--------------|-----------------------------|
| id          | serial PK    |                             |
| device_id   | uuid         | Анонимный UUID клиента      |
| event_name  | varchar(64)  | `app_open`, `conversion`…   |
| payload     | jsonb        | Параметры события           |
| created_at  | timestamp    | UTC                         |

### Таблица `iap_receipts`
| Поле            | Тип        | Описание                     |
|-----------------|------------|------------------------------|
| original_tx_id  | varchar PK | Уникальный ID покупки Apple  |
| device_id       | uuid       | Ссылка на устройство         |
| product_id      | varchar    | SKU подписки                 |
| expires_at      | timestamp  | Дата окончания               |
| last_check      | timestamp  | Последняя валидация          |

---

## REST API

### `GET /rates`
Возвращает последние курсы.

```json
{
  "updated_at": "2025-07-31T10:00:00Z",
  "rates": {
    "USD": 0.0112,
    "EUR": 0.0101,
    "GBP": 0.0087
  }
}
```

### `POST /stats`
Принимает массив событий.

```json
[
  {"name":"app_open","ts":1690800000,"device_id":"…"},
  {"name":"conversion","params":{"from":"USD","amount":100},"ts":…}
]
```

### `POST /iap/verify`
```jsonc
// Request
{
  "receipt_data": "<base64>",
  "device_id": "…"
}
// Response
{ "premium": true, "expires_at": "2025‑09‑01T12:00:00Z" }
```

> Полная OpenAPI‑схема — в [API.md](API.md).

---

## Безопасность

* **HTTPS TLS 1.2+** для всех соединений.  
* Валидация входных данных (Pydantic).  
* Rate‑limit IP и DeviceID (Redis + sliding window).  
* Логика IAP‑валидации выполняется только на сервере.  
* Защита админ‑эндпоинтов `X‑Admin‑Token` + VPN.  
* Хранение персональных данных: минимизация (device_id — анонимный UUID), нет email/телефонов.  

---

## Нефункциональные требования

| Метрика                      | Цель                                   |
|------------------------------|----------------------------------------|
| Время запуска приложения     | < 0.5 с (cold start на iPhone X)       |
| Время ответа `/rates`        | < 200 мс (P95)                         |
| Доступность backend          | 99.5 %/месяц                           |
| Обновление курсов            | каждые 6 ч (cron)                      |
| Потребление RAM клиента      | < 120 МБ                               |
| Покрытие Unit‑тестами        | ≥ 70 % backend, ≥ 60 % iOS             |

---

## Тестирование

| Уровень            | Инструменты                    |
|--------------------|--------------------------------|
| Unit (backend)     | PyTest, coverage.py            |
| Unit (iOS)         | XCTest, ViewInspector          |
| Интеграционные     | httpx + TestClient (FastAPI)   |
| UI‑тесты           | XCUITest                      |
| Lint / Static      | Ruff (Python), SwiftLint       |
| CI‑pipeline        | GitHub Actions: `test → lint → build` |

---

## Развёртывание и CI/CD

| Сервис          | Шаги                                                          |
|-----------------|--------------------------------------------------------------|
| **Backend**     | Docker image → GH Container Registry → `docker compose pull && up -d` |
| **Database**    | Managed PostgreSQL (DigitalOcean) + автоматический backup    |
| **iOS**         | Archive в Xcode → *TestFlight* → App Store Connect           |
| **Secrets**     | GitHub Secrets + `doppler run --` локально                   |

Pipeline: `push → tests → docker build → deploy (staging) → manual prod`.

---