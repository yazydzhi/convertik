## Документация

Полное техническое задание и детальные спецификации находятся в директории [`docs`](docs/).  
Главный документ — [TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md).

## Архитектура системы

# agents.md — AI‑агенты проекта «Конвертик»

## Контекст
- **Продукт:** оф‑лайн‑first конвертер валют с рекламой и подпиской.
- **Пользовательская боль:** быстро пересчитать суммы, даже без интернета.
- **Монетизация:** AdMob (free) + авто‑продляемая подписка Premium (no ads).
- **Метрики:** DAU, WAU, MAU, время до подписки, ретеншн, churn, ARPU.
- **Инфраструктура:** iOS (SwiftUI, CoreData, StoreKit2) + FastAPI + PostgreSQL.

## Модули и их цели
| Модуль   | Цель                                              |
|----------|---------------------------------------------------|
| iOS‑клиент | UI/UX, кэш курсов, локальная конвертация, реклама, IAP |
| Бэкэнд     | `/rates`, `/stats`, `/iap/verify`, cron обновления курсов |
| Аналитика  | Дашборды, алерты, когортный анализ               |
| Маркетинг  | App Store контент, push‑кампании, A/B‐тесты       |
| Дизайн     | Макеты SwiftUI, тёмная/светлая тема, UX‑flow      |

## 1. Агент iOS‑разработки
**Задачи:**
- Репозиторий `RatesRepository` с CoreData‑кэшем.
- Фоновое обновление курсов при запуске и по pull‑to‑refresh.
- Интеграция AdMob: баннер + условие `if !isPremium`.
- Экран Paywall с StoreKit2 покупкой подписки.

**Prompt‑пример**
```
/agent ios
Реализуй ViewModel для списка валют с Combine‑pipeline:
fetchLocal→render→fetchRemote→save→render.
```

## 2. Агент backend‑разработки
**Задачи:**
- FastAPI эндпоинт `/rates` (GET) и `/stats` (POST batch).
- Планировщик (APScheduler) для обновления курсов каждые 6 ч.
- Проверка IAP чека `/iap/verify`.
- Таблица `usage_events` + materialized view MAU.

**Prompt‑пример**
```
/agent backend
Добавь в /stats режим async bulk insert и тест PyTest.
```

## 3. Агент аналитики
**Задачи:**
- Настроить отчёты DAU/WAU/MAU, времени до покупки, churn.
- Cohort analysis: install_date vs. subscribe_date.
- Push‑триггер «не заходил 7 дней».

**Prompt‑пример**
```
/agent analytics
SQL для median time_to_subscribe по cohort install_week.
```

## 4. Агент маркетинга
**Задачи:**
- Описание фич для App Store RU/EN, скриншоты.
- Стратегия push‑кампаний: welcome, remind, upsell.
- Paywall A/B: текст «Отключите рекламу» vs. «Премиум‑функции».

**Prompt‑пример**
```
/agent marketing
Сгенерируй 3 варианта push «Курсы обновились — проверь выгодный EUR».
```

## 5. Агент UI/UX‑дизайна
**Задачи:**
- SwiftUI‑макеты: главный экран, экран добавления валют, Paywall.
- Анимация pull‑to‑refresh и индикатор «офф‑лайн».
- Тёмная/светлая тема.

**Prompt‑пример**
```
/agent design
Нарисуй wireframe списка валют с баннером ads внизу и датой курса.
```