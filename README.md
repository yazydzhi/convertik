# Конвертер валют (iOS + Python)

## Документация

Полное техническое задание и детальные спецификации находятся в директории [`docs`](docs/).  
Главный документ — [TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md).

## Архитектура системы
```
 Клиент (Swift)              Бэкэнд (FastAPI)
 ┌─────────────────┐  HTTPS  ┌─────────────────────────┐
 │  iOS‑приложение │────────►│      /rates             │
 │                 │◄───────│      /stats             │
 │  • UI/UX        │        │      /iap/verify        │
 │  • расчёты      │        │      /push/register     │
 │  • CoreData     │        └─────────────────────────┘
 └─────────────────┘                 PostgreSQL
```

### Поток данных
1. **Запуск:** читаем курсы из CoreData → мгновенно рендерим список → в фоне запрашиваем `/rates`‐API.  
2. **Pull‑to‑refresh:** ручное обновление курсов тем же эндпоинтом.  
3. **Конвертация:** все вычисления выполняются локально.  
4. **Статистика:** события буферизуются локально и отправляются батчем на `/stats`, когда есть сеть.  
5. **Подписка:** StoreKit → `/iap/verify` → сохраняем статус _Premium_ и скрываем рекламу.

### Локальное хранение
| Сущность                    | Технология  | Назначение                      |
|-----------------------------|-------------|---------------------------------|
| Курсы валют `updated_at`    | CoreData    | Оф‑лайн работа                  |
| Выбор пользователя          | UserDefaults| Последний список валют          |
| Буфер событий               | JSON‑файл   | Очередь для `/stats`            |

### Структура репозитория
```
frontend/ios/            # Swift‑код приложения
  ├ Convertik/           # Исходный код
  ├ project.yml          # Конфигурация xcodegen
  ├ Info.plist           # Настройки приложения
  └ Convertik.xcodeproj/ # Сгенерированный проект
backend/                  # FastAPI‑сервер
  ├ app/
  │ ├ routes/rates.py
  │ ├ routes/stats.py
  │ └ …
  └ requirements.txt
```

### Запуск iOS‑приложения
```bash
git clone https://github.com/yourname/convertik.git
cd convertik/frontend/ios

# Установка зависимостей
brew install xcodegen
xcodebuild -downloadPlatform iOS

# Генерация проекта
xcodegen generate

# Сборка и установка на симулятор
xcodebuild -project Convertik.xcodeproj -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 16 Pro" -derivedDataPath ./build install

# Запуск
xcrun simctl launch <SIMULATOR_UDID> com.azg.Convertik
open -a Simulator
```

**📱 Текущая версия:** 1.2  
**🌐 Production API:** https://convertik.ponravilos.ru

### Запуск бэкэнда
```bash
cd convertik/backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL=postgresql://user:pass@localhost/currency_db
uvicorn app.main:app --reload
```
Доступные эндпоинты: `/rates`, `/stats`, `/iap/verify`.

### Production деплой

🌐 **Live API:** https://convertik.ponravilos.ru  
📖 **Документация:** https://convertik.ponravilos.ru/docs  

Для деплоя на сервер см. [backend/README_DEPLOY.md](backend/README_DEPLOY.md)

### Аналитика и push
* **AppMetrica / Firebase** — сбор DAU/MAU, конверсий, крашей.  
* **APNs (+ FCM при Android)** — доставка push‑уведомлений.  
* Пуш‑кампании можно создавать через AppMetrica Push или Firebase Messaging.

---

## Возможность параллельной разработки
Фронтенд и бэкэнд общаются только через REST, поэтому могут разрабатываться независимо. Swagger‑документация FastAPI облегчает согласование контрактов.
