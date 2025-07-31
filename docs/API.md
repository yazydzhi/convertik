

# API.md  
> 🌐 REST‑API бекэнда «Конвертик» (версия v1)  
> Все ответы — `application/json; charset=utf‑8`  
> Базовый URL в продакшене: `https://api.convertik.app/api/v1`

## Сводка эндпоинтов

| Эндпоинт                 | Метод | Авторизация | Назначение                             |
|--------------------------|-------|-------------|----------------------------------------|
| `/rates`                 | GET   | —           | Последние курсы валют                  |
| `/stats`                 | POST  | —           | Приём batched‑событий аналитики        |
| `/iap/verify`            | POST  | —           | Валидация квитанции IAP (StoreKit2)    |
| `/push/register`         | POST  | —           | Регистрация push‑токена устройства     |
| `/admin/push/send`       | POST  | `X-Admin`   | Отправка push‑уведомления выбранному сегменту |
| `/health`                | GET   | —           | Liveness / readiness probe            |

> 🔒  Эндпоинты `/admin/*` защищены заголовком `X-Admin-Token: <secret>`  
> (токен задаётся в переменной окружения `ADMIN_TOKEN` на сервере).

---

## 1. GET `/rates`

Возвращает хэш актуальных курсов и дату их обновления.

### Запрос  
```
GET /api/v1/rates
```

### Ответ `200 OK`
```json
{
  "updated_at": "2025-07-31T10:00:00Z",
  "base": "RUB",
  "rates": {
    "USD": 0.01119,
    "EUR": 0.01007,
    "GBP": 0.00870
  }
}
```

### Коды ошибок  
| Код | Описание                             |
|-----|--------------------------------------|
| 503 | Курсы временно недоступны (нет свежих данных) |

---

## 2. POST `/stats`

Принимает массив событий аналитики (≤ 50 объектов за запрос).  
Идентификация устройства осуществляется полем `device_id` (UUID v4), передаваемым в каждом событии.

### Запрос  
`Content‑Type: application/json`
```json
[
  {
    "name": "app_open",
    "ts": 1690800000,
    "device_id": "2cb4e0d4‑b3cf‑46e2‑942c‑0e7d2fc8dcdd"
  },
  {
    "name": "conversion",
    "device_id": "2cb4e0d4‑b3cf‑46e2‑942c‑0e7d2fc8dcdd",
    "ts": 1690800010,
    "params": { "from": "USD", "to": "EUR", "amount": 150 }
  }
]
```

### Ответ `202 Accepted`
```json
{ "accepted": 2 }
```

### Коды ошибок  
| Код | Описание                           |
|-----|------------------------------------|
| 400 | JSON‑синтаксис или структура невалидна |
| 429 | Слишком много запросов (rate‑limit)  |

---

## 3. POST `/iap/verify`

Проверяет подписку Premium на стороне сервера через App Store Server API.

### Запрос  
`Content‑Type: application/json`
```json
{
  "receipt_data": "<base64-receipt>",
  "device_id": "2cb4e0d4‑b3cf‑46e2‑942c‑0e7d2fc8dcdd",
  "app_account_token": "c1d4…",  // optional, UUID
  "sandbox": false                // true для TestFlight / Sandbox
}
```

### Ответы  
*`200 OK`* — подписка активна  
```json
{
  "premium": true,
  "expires_at": "2025-09-01T12:00:00Z",
  "original_tx_id": "360001234567890",
  "plan": "convertik_premium_month"
}
```

*`402 Payment Required`* — подписка не найдена или истекла  
```json
{ "premium": false, "reason": "expired" }
```

*`400`* — неверный base64 / reçeipt повреждён.  
*`500`* — ошибка связи с App Store Server API.

---

## 4. POST `/push/register`

Регистрирует push‑токен устройства (APNs) для дальнейших рассылок.

### Запрос  
```json
{
  "device_id": "2cb4e0d4‑b3cf‑46e2‑942c‑0e7d2fc8dcdd",
  "token": "3f39da672b6e3d7bd4f…",   // hex‑строка
  "platform": "ios",                // ios | android
  "locale": "ru-RU",
  "is_premium": false,
  "app_version": "1.0.1"
}
```

### Ответ `201 Created`
```json
{ "registered": true }
```

---

## 5. POST `/admin/push/send`  🔒

> Требуется заголовок `X-Admin-Token`.

Отправляет push‑уведомление выбранному сегменту.

### Запрос  
```json
{
  "title": "Курсы обновились!",
  "body": "Проверьте выгодный курс EUR прямо сейчас.",
  "segment": {
    "is_premium": false,
    "last_seen_days_gt": 3
  }
}
```

### Ответ `202 Accepted`
```json
{ "queued": 4821, "platforms": { "ios": 4300, "android": 521 } }
```

### Параметры `segment`
| Поле                | Тип   | Значение                                   |
|---------------------|-------|--------------------------------------------|
| `is_premium`        | bool  | true / false / null (=не важно)            |
| `locale_in`         | array | ["ru", "en"]                               |
| `last_seen_days_gt` | int   | > N дней с момента `app_open`              |
| `currency_in`       | array | ["USD","EUR"] — валюта есть в списке у пользователя |

---

## 6. GET `/health`

Проба живости (используется Kubernetes / мониторинг).

* `200 OK` — сервис готов  
* `500`    — проблемы (например, нет соединения с БД)

---

## Стандарты ошибок

```jsonc
{
  "error": {
    "code": 400,
    "message": "Invalid JSON",
    "details": { "field": "receipt_data" }
  }
}
```

| Поле     | Описание                            |
|----------|-------------------------------------|
| `code`   | HTTP‑код                            |
| `message`| Человекочитаемое описание           |
| `details`| Доп. информация для дебага (опц.)   |

---

## Версионирование

* **URI‑версия** (`/api/v1`) — при мажорных изменениях контрактов.  
* Минорные поля могут добавляться без изменения версии (добавлены опционально).

---

## CORS

По умолчанию CORS выключен (API используется только нативным приложением).  
Для целей отладки можно включить заголовок:
```
Access-Control-Allow-Origin: *
```
на staging‑окружении.

---