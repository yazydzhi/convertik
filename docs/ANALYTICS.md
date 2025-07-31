

# ANALYTICS.md  
> 📊 Спецификация сбора и использования аналитических данных в «Конвертик»  
> Версия: 1.0 · 31 июля 2025

---

## 1. Цель

Аналитика нужна для:

1. Измерения активности пользователей (DAU, WAU, MAU).  
2. Оценки эффективности монетизации (реклама vs подписка).  
3. Контроля ретеншна, времени до первой подписки, churn.  
4. Принятия продуктовых решений (какие валюты популярны, почему уходят).  
5. Запуска таргетированных push‑кампаний (уведомить «спящих»).

Сбор происходит **анонимно**: единственный идентификатор — `device_id` (UUID v4,
генерируется при первом запуске). Личных данных (имя, email, IP‑адрес) не
сохраняем.

---

## 2. Платформа и поток данных

| Уровень   | Инструмент                        | Назначение                                 |
|-----------|-----------------------------------|--------------------------------------------|
| Клиент    | **AppMetrica SDK**               | realtime‑дашборды, push‑кампании           |
| Клиент    | **Firebase Crashlytics** (опц.)  | сбор крашей                                |
| Сервер    | `/stats` endpoint (+PostgreSQL)  | сырые события для оффлайн‑BI / BigQuery    |
| BI        | Superset / Metabase              | сводные отчёты (MAU, ARPU, LTV, churn)     |

### Поток

```
App            ──►  AppMetrica cloud  ──►  web‑дашборд
 │ \ batched
 │  \_json──►  /stats  ──► PostgreSQL ──►  ETL → BI
 └─ Crashlytics cloud
```

* В онлайне SDK AppMetrica отправляет события сразу.  
* Если оф‑лайн — события накапливаются и читерно отправляются в `/stats`.
* Сервер агрегирует массив (≤ 50) за один call → copy‑from в `usage_events`.

---

## 3. Схема события

```jsonc
{
  "name": "conversion",          // строка ≤ 64
  "device_id": "uuid-v4",        // обязательный
  "ts": 1690801012,              // unix time (sec)
  "params": {                    // необязательно
    "from": "USD",
    "to": "EUR",
    "amount": 150
  },
  "app_ver": "1.0.1",            // major.minor.patch
  "os_ver": "17.5",              // iOS
  "locale": "ru-RU",             // preferred locale
  "is_premium": false
}
```

> При вставке в БД поля `app_ver`, `os_ver`, `locale`, `is_premium`
> нормализуются в отдельные колонки для витрины.

---

## 4. Список событий

| Событие              | Триггер                                         | Параметры              |
|----------------------|-------------------------------------------------|------------------------|
| `app_open`           | При каждом `scenePhase == .active`             | —                      |
| `conversion`         | Пользователь ввёл сумму и нажал Return         | from, to, amount       |
| `currency_added`     | Добавлена валюта в список                      | code                   |
| `currency_removed`   | Удалена валюта                                 | code                   |
| `ad_impression`      | AdMob delegate `didRecordImpression`           | ad_unit_id             |
| `ad_click`           | delegate `didRecordClick`                      | ad_unit_id             |
| `subscribe_start`    | Открыт Paywall                                 | plan_id                |
| `subscribe_success`  | StoreKit транзакция успешна                    | plan_id, price, trial  |
| `subscribe_renew`    | S2S‑нотификация `DID_RENEW`                    | plan_id, period        |
| `subscribe_cancel`   | Detect expiry (receipt) или S2S `CANCEL`       | reason                 |
| `rates_refresh`      | pull‑to‑refresh успешен                        | network_ms             |
| `push_open`          | Пользователь тапнул на push                    | campaign_id            |

---

## 5. Метрики и KPI

| Показатель                | Формула / описание                                    |
|---------------------------|-------------------------------------------------------|
| **DAU**                   | `COUNT(DISTINCT device_id) WHERE date = today`        |
| **WAU / MAU**             | аналогично по 7 / 30 дням                             |
| **Stickiness**            | `DAU / MAU`                                           |
| **Conversion to premium** | `premium_users / total_users`                         |
| **ARPU**                  | `revenue / total_users`                               |
| **LTV (cohort)**          | накопленная выручка когорты / количество в когорте   |
| **Time_to_subscribe**     | median(`subscribe_ts - install_ts`)                   |
| **Churn premium**         | 1 – ( renewals / active_subs_prev_period )            |
| **Ad eCPM**               | из AdMob dashboard                                    |

---

## 6. BI‑вытяжка (пример SQL)

```sql
-- MAU last 12 months
SELECT date_trunc('month', created_at)  AS month,
       COUNT(DISTINCT device_id)        AS mau
FROM usage_events
GROUP BY month
ORDER BY month DESC
LIMIT 12;
```

```sql
-- Median time to first subscribe (дни)
WITH installs AS (
  SELECT device_id, MIN(created_at) AS install_ts
  FROM usage_events
  WHERE event_name = 'app_open'
  GROUP BY device_id
), subs AS (
  SELECT device_id, MIN(created_at) AS first_sub
  FROM usage_events
  WHERE event_name = 'subscribe_success'
  GROUP BY device_id
)
SELECT PERCENTILE_CONT(0.5)
  WITHIN GROUP (ORDER BY (first_sub - install_ts)) / 86400 AS median_days
FROM installs
JOIN subs USING(device_id);
```

---

## 7. Алерты

| Метрика                     | Порог                  | Действие                   |
|-----------------------------|------------------------|----------------------------|
| Daily `ad_impression`       | < 50 % от среднего     | Slack «реклама не работает»|
| Cron `update_rates` > 6 ч   | неверные курсы         | PagerDuty                  |
| Crash‑free users            | < 98 %                 | Расследовать в Crashlytics |
| Premium churn ↑ > 15 %      | рост оттока            | Проверить StoreKit логи    |

---

## 8. Dashboards

* **Product KPI (AppMetrica):** DAU, WAU, MAU, Stickiness.  
* **Monetization (BI):** eCPM, рекламный доход, MRR подписки, ARPU.  
* **Cohort Retention:** график удержания 30‑дней по неделям установки.  
* **Funnel:** install → app_open → paywall_open → subscribe_success.  
* **Performance:** HTTP latency `/rates`, success ratio cron.

---

## 9. Privacy & GDPR

* device_id = UUID v4, не связывается с IDFA (ATT) до согласия.  
* Пользователь может отключить аналитические события в Settings → Privacy.  
* Data retention правила: сырые usage_events очищаются через 12 мес, агрегаты остаются.  
* Пользовательская экспорт / удаление данных: endpoint `DELETE /gdpr/device/{device_id}`.  

---

## 10. Roadmap улучшений

* Deep Link Attribution через AppMetrica SmartLink.  
* Amplitude/Segment интеграция для маркетинга.  
* Recommendation service «курс недели» с ML.  
* Auto‑push «Добавьте валюту X» на основе поведения.

---