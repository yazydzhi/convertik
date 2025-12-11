# 📊 API для отправки аналитических событий

> Полное описание формата и требований для отправки статистики из iOS приложения

## 🔗 Endpoint

```
POST https://api.convertik.ponravilos.ru/api/v1/stats
```

## 📋 Формат запроса

### Content-Type
```
Content-Type: application/json
```

### Структура запроса

**ВАЖНО:** Backend ожидает объект с полем `events`, а не массив напрямую!

```json
{
  "events": [
    {
      "name": "app_open",
      "device_id": "550e8400-e29b-41d4-a716-446655440000",
      "ts": 1690800000,
      "params": null
    },
    {
      "name": "conversion",
      "device_id": "550e8400-e29b-41d4-a716-446655440000",
      "ts": 1690800010,
      "params": {
        "from": "USD",
        "to": "EUR",
        "amount": 150.5
      }
    }
  ]
}
```

### Поля события

| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `name` | `string` | ✅ Да | Название события (макс. 64 символа) |
| `device_id` | `string` (UUID v4) | ✅ Да | Уникальный идентификатор устройства |
| `ts` | `integer` | ✅ Да | Unix timestamp события (секунды с 1970-01-01) |
| `params` | `object` | ❌ Нет | Дополнительные параметры события (JSON объект) |

### Ограничения

- **Максимум событий в одном запросе:** 50
- **Максимальная длина `name`:** 64 символа
- **Формат `device_id`:** UUID v4 (например: `550e8400-e29b-41d4-a716-446655440000`)
- **Типы значений в `params`:** `string`, `number`, `boolean` (вложенные объекты не поддерживаются)

## ✅ Формат ответа

### Успешный ответ (200 OK)

```json
{
  "status": "success",
  "processed_events": 2,
  "message": "Events saved successfully"
}
```

### Ошибки

#### 400 Bad Request
```json
{
  "code": 400,
  "message": "Failed to save analytics events",
  "details": {
    "error": "Invalid device_id format: invalid-uuid"
  }
}
```

#### 422 Unprocessable Entity
```json
{
  "detail": [
    {
      "loc": ["body", "events", 0, "name"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

#### 500 Internal Server Error
```json
{
  "code": 500,
  "message": "Failed to save analytics events",
  "details": {
    "error": "Database connection error"
  }
}
```

## 📱 Примеры использования

### Swift (iOS)

#### Правильная реализация

```swift
import Foundation

struct StatsEvent: Codable {
    let name: String
    let deviceId: String
    let timestamp: Int
    let params: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case name
        case deviceId = "device_id"
        case timestamp = "ts"
        case params
    }
}

struct StatsEventBatch: Codable {
    let events: [StatsEvent]
}

// Отправка событий
func sendStats(_ events: [StatsEvent]) async throws {
    let url = URL(string: "https://api.convertik.ponravilos.ru/api/v1/stats")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // ВАЖНО: Обернуть массив в объект с полем events
    let batch = StatsEventBatch(events: events)

    let encoder = JSONEncoder()
    request.httpBody = try encoder.encode(batch)

    let (_, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          200...299 ~= httpResponse.statusCode else {
        throw APIError.invalidResponse
    }
}
```

#### ❌ Неправильная реализация (текущая в коде)

```swift
// НЕПРАВИЛЬНО - отправка массива напрямую
request.httpBody = try encoder.encode(events)  // ❌ Это не сработает!
```

#### ✅ Правильная реализация

```swift
// ПРАВИЛЬНО - обернуть в объект с полем events
let batch = StatsEventBatch(events: events)
request.httpBody = try encoder.encode(batch)  // ✅ Правильно!
```

### cURL пример

```bash
curl -X POST https://api.convertik.ponravilos.ru/api/v1/stats \
  -H "Content-Type: application/json" \
  -d '{
    "events": [
      {
        "name": "app_open",
        "device_id": "550e8400-e29b-41d4-a716-446655440000",
        "ts": '$(date +%s)',
        "params": null
      }
    ]
  }'
```

### Python пример

```python
import requests
import time

url = "https://api.convertik.ponravilos.ru/api/v1/stats"

events = {
    "events": [
        {
            "name": "app_open",
            "device_id": "550e8400-e29b-41d4-a716-446655440000",
            "ts": int(time.time()),
            "params": None
        },
        {
            "name": "conversion",
            "device_id": "550e8400-e29b-41d4-a716-446655440000",
            "ts": int(time.time()),
            "params": {
                "from": "USD",
                "to": "EUR",
                "amount": 150.5
            }
        }
    ]
}

response = requests.post(url, json=events)
print(response.json())
```

## 🎯 Типы событий

### Стандартные события

| Событие | Описание | Параметры |
|---------|----------|-----------|
| `app_open` | Открытие приложения | `null` |
| `conversion` | Выполнение конвертации | `from` (string), `to` (string), `amount` (number) |
| `currency_added` | Добавление валюты в список | `currency` (string) |
| `currency_removed` | Удаление валюты из списка | `currency` (string) |
| `settings_changed` | Изменение настроек | `setting` (string), `value` (string/number/boolean) |

### Кастомные события

Вы можете отправлять любые события с любыми названиями (до 64 символов) и параметрами.

## 🔄 Batch отправка

Рекомендуется накапливать события и отправлять их батчами (до 50 событий) для экономии трафика и снижения нагрузки на сервер.

### Пример реализации очереди событий

```swift
class AnalyticsService {
    private var eventQueue: [StatsEvent] = []
    private let maxBatchSize = 50

    func track(event: String, params: [String: Any]? = nil) {
        let statsEvent = StatsEvent(
            name: event,
            deviceId: getDeviceId(),
            timestamp: Int(Date().timeIntervalSince1970),
            params: params?.mapValues(AnyCodable.init)
        )

        eventQueue.append(statsEvent)

        // Отправляем батч если достигли лимита
        if eventQueue.count >= maxBatchSize {
            Task {
                await sendQueuedEvents()
            }
        }
    }

    func sendQueuedEvents() async {
        guard !eventQueue.isEmpty else { return }

        let eventsToSend = Array(eventQueue.prefix(maxBatchSize))

        do {
            try await sendStats(eventsToSend)
            eventQueue.removeFirst(eventsToSend.count)
        } catch {
            print("Failed to send analytics: \(error)")
            // События остаются в очереди для повторной отправки
        }
    }
}
```

## ⚠️ Важные замечания

### 1. Формат запроса

**КРИТИЧНО:** Backend ожидает объект с полем `events`, а не массив напрямую!

```json
// ❌ НЕПРАВИЛЬНО
[
  {"name": "app_open", "device_id": "...", "ts": 123}
]

// ✅ ПРАВИЛЬНО
{
  "events": [
    {"name": "app_open", "device_id": "...", "ts": 123}
  ]
}
```

### 2. Device ID

- Должен быть валидным UUID v4
- Должен быть одинаковым для всех событий с одного устройства
- Рекомендуется генерировать один раз при первом запуске и сохранять в UserDefaults

### 3. Timestamp

- Используйте Unix timestamp в секундах (не миллисекундах)
- Время должно быть актуальным (не в будущем, не слишком в прошлом)
- Backend автоматически конвертирует в UTC

### 4. Параметры события

- Поддерживаются только простые типы: `string`, `number`, `boolean`
- Вложенные объекты и массивы не поддерживаются
- `null` значения допустимы

## 🐛 Известные проблемы

### Проблема: iOS приложение отправляет неправильный формат

**Текущая реализация в `APIService.swift`:**
```swift
request.httpBody = try encoder.encode(events)  // ❌ Отправляет массив напрямую
```

**Ожидаемый формат backend:**
```json
{
  "events": [...]  // ✅ Ожидает объект с полем events
}
```

**Решение:** Обернуть массив событий в объект `StatsEventBatch`:

```swift
struct StatsEventBatch: Codable {
    let events: [StatsEvent]
}

// В методе sendStats:
let batch = StatsEventBatch(events: events)
request.httpBody = try encoder.encode(batch)
```

## 📚 Связанная документация

- [API.md](API.md) - Общая документация API
- [ANALYTICS.md](ANALYTICS.md) - Документация по аналитике
- [API_STATS_SUMMARY.md](API_STATS_SUMMARY.md) - Описание endpoint для получения статистики
- [FIX_METRICS_ISSUE.md](FIX_METRICS_ISSUE.md) - Решение проблемы с метриками

## ✅ Чек-лист для iOS разработчика

- [ ] События обернуты в объект с полем `events`
- [ ] `device_id` - валидный UUID v4
- [ ] `ts` - Unix timestamp в секундах
- [ ] `name` - не более 64 символов
- [ ] В батче не более 50 событий
- [ ] Параметры содержат только простые типы (string, number, boolean)
- [ ] Обрабатываются ошибки отправки
- [ ] Реализована очередь событий для batch отправки
- [ ] События отправляются при достижении лимита или при закрытии приложения


