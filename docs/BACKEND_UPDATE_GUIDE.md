# 🚀 Руководство по обновлению бэкенда Convertik на ponravilos.ru

> 📋 Пошаговая инструкция по безопасному обновлению бэкенда на продакшн сервере
> Версия: 1.0 · Обновлено: 2025-12-10

---

## 📊 Текущая архитектура

### Серверная инфраструктура

- **Сервер:** ponravilos.ru (185.70.105.198)
- **Путь бэкенда:** `/opt/convertik`
- **Прокси:** Caddy (через сеть `caddy`)
- **Домен:** `convertik.ponravilos.ru`
- **Порты:**
  - API: `8001:8000` (внутренний порт 8000)
  - PostgreSQL: `5433:5432`
  - Redis: `6380:6379`

### Docker контейнеры

- `convertik-api` — FastAPI приложение
- `convertik-db` — PostgreSQL 15
- `convertik-redis` — Redis 7

---

## 🔄 Процесс обновления

### Вариант 1: Автоматический деплой (рекомендуется)

Используйте скрипт деплоя из корня проекта:

```bash
# Из корня проекта convertik
./deploy.sh backend
```

**Что делает скрипт:**
1. ✅ Копирует файлы бэкенда на сервер через `rsync`
2. ✅ Копирует `.env.production` (если существует локально)
3. ✅ Запускает `server-deploy.sh` на сервере, который:
   - Останавливает контейнеры
   - Собирает новый Docker образ
   - Запускает сервисы
   - Выполняет миграции БД
   - Проверяет работоспособность

**Требования:**
- Файл `.env` в корне проекта с настройками деплоя
- Файл `backend/.env.production` (опционально, если нужно обновить переменные)

---

### Вариант 2: Ручное обновление

Если нужно больше контроля или автоматический деплой недоступен:

#### Шаг 1: Подготовка на локальной машине

```bash
# Убедитесь что все изменения закоммичены
cd /Users/azg/repository/convertik
git status

# Проверьте что нет незакоммиченных изменений
git diff backend/
```

#### Шаг 2: Копирование файлов на сервер

```bash
# Копируем файлы бэкенда (исключая ненужные)
rsync -avz --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.env' \
    --exclude='.env.production' \
    --exclude='venv' \
    --exclude='.pytest_cache' \
    --exclude='*.log' \
    backend/ root@ponravilos.ru:/opt/convertik/
```

#### Шаг 3: Обновление на сервере

```bash
# Подключаемся к серверу
ssh root@ponravilos.ru

# Переходим в директорию проекта
cd /opt/convertik

# Проверяем текущий статус
docker-compose -f docker-compose.production.yml ps

# Смотрим логи перед обновлением (опционально)
docker-compose -f docker-compose.production.yml logs --tail=50 convertik-api
```

#### Шаг 4: Остановка и обновление

```bash
# Останавливаем контейнеры (без удаления volumes)
docker-compose -f docker-compose.production.yml down

# Собираем новый образ (с очисткой кэша)
docker-compose -f docker-compose.production.yml build --no-cache

# Запускаем контейнеры
docker-compose -f docker-compose.production.yml up -d

# Ждем запуска (5-10 секунд)
sleep 10

# Проверяем статус
docker-compose -f docker-compose.production.yml ps
```

#### Шаг 5: Применение миграций БД

```bash
# Применяем миграции
./migrate.sh upgrade

# Или вручную:
docker-compose -f docker-compose.production.yml exec convertik-api alembic upgrade head
```

#### Шаг 6: Проверка работоспособности

```bash
# Проверяем логи
docker-compose -f docker-compose.production.yml logs -f convertik-api

# Проверяем health check
curl http://localhost:8001/health

# Проверяем через домен
curl https://convertik.ponravilos.ru/health
```

---

## 🔍 Проверка перед обновлением

### 1. Проверка текущей версии

```bash
# На сервере
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml exec convertik-api python -c "from app.config import settings; print(settings.app_version)"'
```

### 2. Проверка изменений

```bash
# Локально
cd /Users/azg/repository/convertik
git log --oneline backend/ | head -10

# Смотрим что изменилось
git diff origin/main...HEAD backend/
```

### 3. Проверка миграций

```bash
# На сервере - текущая ревизия
ssh root@ponravilos.ru 'cd /opt/convertik && ./migrate.sh current'

# Локально - какие миграции будут применены
cd backend
docker-compose exec convertik-api alembic history
```

---

## 🛡️ Безопасное обновление (с бэкапом)

### Шаг 1: Создание бэкапа БД

```bash
# На сервере
ssh root@ponravilos.ru << 'EOF'
cd /opt/convertik

# Создаем бэкап базы данных
docker-compose -f docker-compose.production.yml exec convertik-db \
    pg_dump -U convertik convertik > \
    /tmp/convertik_backup_$(date +%Y%m%d_%H%M%S).sql

# Копируем бэкап локально (опционально)
# scp root@ponravilos.ru:/tmp/convertik_backup_*.sql ./
EOF
```

### Шаг 2: Обновление с возможностью отката

```bash
# На сервере
ssh root@ponravilos.ru << 'EOF'
cd /opt/convertik

# Сохраняем текущий образ (опционально)
docker tag convertik-api:latest convertik-api:backup-$(date +%Y%m%d)

# Останавливаем
docker-compose -f docker-compose.production.yml down

# Собираем новый образ
docker-compose -f docker-compose.production.yml build --no-cache

# Запускаем
docker-compose -f docker-compose.production.yml up -d

# Ждем запуска
sleep 10

# Применяем миграции
./migrate.sh upgrade
EOF
```

### Шаг 3: Проверка после обновления

```bash
# Проверяем что все работает
curl https://convertik.ponravilos.ru/health
curl https://convertik.ponravilos.ru/api/v1/stats/summary
curl https://convertik.ponravilos.ru/api/v1/stats/metrics
```

### Шаг 4: Откат (если что-то пошло не так)

```bash
# На сервере
ssh root@ponravilos.ru << 'EOF'
cd /opt/convertik

# Останавливаем
docker-compose -f docker-compose.production.yml down

# Откатываем миграции (если нужно)
./migrate.sh downgrade

# Используем старый образ
docker tag convertik-api:backup-YYYYMMDD convertik-api:latest

# Запускаем
docker-compose -f docker-compose.production.yml up -d

# Восстанавливаем БД из бэкапа (если нужно)
docker-compose -f docker-compose.production.yml exec -i convertik-db \
    psql -U convertik convertik < /tmp/convertik_backup_*.sql
EOF
```

---

## 📝 Чек-лист обновления

### Перед обновлением

- [ ] Все изменения закоммичены в git
- [ ] Проверены изменения в коде
- [ ] Проверены новые миграции БД
- [ ] Создан бэкап базы данных
- [ ] Проверена работоспособность текущей версии

### Во время обновления

- [ ] Файлы скопированы на сервер
- [ ] Контейнеры остановлены
- [ ] Новый Docker образ собран
- [ ] Контейнеры запущены
- [ ] Миграции применены

### После обновления

- [ ] Health check проходит успешно
- [ ] API endpoints отвечают корректно
- [ ] Логи не содержат критических ошибок
- [ ] Новые функции работают (если были добавлены)
- [ ] Проверены метрики и аналитика

---

## 🔧 Обновление переменных окружения

Если нужно обновить `.env.production`:

### Вариант 1: Через локальный файл

```bash
# Редактируем локально
nano backend/.env.production

# Копируем на сервер
scp backend/.env.production root@ponravilos.ru:/opt/convertik/.env.production

# Перезапускаем контейнеры
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml restart convertik-api'
```

### Вариант 2: Напрямую на сервере

```bash
ssh root@ponravilos.ru
cd /opt/convertik
nano .env.production

# Перезапускаем
docker-compose -f docker-compose.production.yml restart convertik-api
```

**Важно:** После изменения `.env.production` нужно перезапустить контейнер `convertik-api`.

---

## 🚨 Troubleshooting

### Проблема: Контейнер не запускается

```bash
# Проверяем логи
docker-compose -f docker-compose.production.yml logs convertik-api

# Проверяем переменные окружения
docker-compose -f docker-compose.production.yml config

# Проверяем что порты свободны
netstat -tuln | grep -E '8001|5433|6380'
```

### Проблема: Миграции не применяются

```bash
# Проверяем текущую ревизию
./migrate.sh current

# Смотрим историю миграций
./migrate.sh history

# Применяем вручную с подробным выводом
docker-compose -f docker-compose.production.yml exec convertik-api \
    alembic upgrade head --verbose
```

### Проблема: API недоступен после обновления

```bash
# Проверяем что контейнер запущен
docker-compose -f docker-compose.production.yml ps

# Проверяем логи
docker-compose -f docker-compose.production.yml logs -f convertik-api

# Проверяем подключение к БД
docker-compose -f docker-compose.production.yml exec convertik-api \
    python -c "from app.database import engine; import asyncio; asyncio.run(engine.connect())"

# Проверяем сеть Caddy
docker network inspect caddy | grep convertik-api
```

### Проблема: Новый endpoint не работает

```bash
# Проверяем что код обновился
docker-compose -f docker-compose.production.yml exec convertik-api \
    cat app/routes/stats.py | grep -A 5 "get_metrics_for_monitoring"

# Проверяем что контейнер перезапущен
docker-compose -f docker-compose.production.yml ps convertik-api

# Проверяем логи при запросе
docker-compose -f docker-compose.production.yml logs -f convertik-api
# В другом терминале:
curl -v https://convertik.ponravilos.ru/api/v1/stats/metrics
```

---

## 📊 Мониторинг после обновления

### Проверка метрик

```bash
# Проверяем новый endpoint
curl https://convertik.ponravilos.ru/api/v1/stats/metrics

# Проверяем старый endpoint
curl https://convertik.ponravilos.ru/api/v1/stats/summary

# Проверяем health
curl https://convertik.ponravilos.ru/health
```

### Просмотр логов

```bash
# Логи в реальном времени
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs -f convertik-api'

# Последние 100 строк
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs --tail=100 convertik-api'
```

### Проверка производительности

```bash
# Время ответа API
time curl -s https://convertik.ponravilos.ru/api/v1/stats/summary > /dev/null

# Статус контейнеров
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml ps'

# Использование ресурсов
ssh root@ponravilos.ru 'docker stats convertik-api --no-stream'
```

---

## 🎯 Рекомендуемый процесс обновления

### Для обычных обновлений (безопасно)

```bash
# 1. Локально: проверяем изменения
cd /Users/azg/repository/convertik
git log --oneline backend/ | head -5

# 2. Локально: создаем бэкап (опционально, но рекомендуется)
# (бэкап создается автоматически на сервере)

# 3. Локально: запускаем деплой
./deploy.sh backend

# 4. Проверяем результат
curl https://convertik.ponravilos.ru/health
curl https://convertik.ponravilos.ru/api/v1/stats/metrics?period=day
```

### Для критических обновлений (максимальная безопасность)

```bash
# 1. Создаем бэкап БД
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml exec convertik-db pg_dump -U convertik convertik > /tmp/convertik_backup_$(date +%Y%m%d_%H%M%S).sql'

# 2. Сохраняем текущий образ
ssh root@ponravilos.ru 'cd /opt/convertik && docker tag convertik-api:latest convertik-api:backup-$(date +%Y%m%d)'

# 3. Обновляем
./deploy.sh backend

# 4. Тщательно проверяем
curl https://convertik.ponravilos.ru/health
curl https://convertik.ponravilos.ru/api/v1/stats/summary
curl https://convertik.ponravilos.ru/api/v1/stats/metrics

# 5. Мониторим логи 5-10 минут
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs -f convertik-api'
```

---

## 🔄 Обновление только кода (без пересборки образа)

Если изменился только Python код (не зависимости):

```bash
# На сервере
ssh root@ponravilos.ru << 'EOF'
cd /opt/convertik

# Копируем только код (если уже скопирован через rsync)
# Или перезапускаем контейнер для применения изменений
docker-compose -f docker-compose.production.yml restart convertik-api

# Проверяем
sleep 5
docker-compose -f docker-compose.production.yml logs --tail=20 convertik-api
EOF
```

**Важно:** Если изменились `requirements.txt` или `Dockerfile`, нужна полная пересборка образа.

---

## 📋 Быстрая справка команд

### Обновление (автоматическое)

```bash
./deploy.sh backend
```

### Обновление (ручное)

```bash
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml down && docker-compose -f docker-compose.production.yml build --no-cache && docker-compose -f docker-compose.production.yml up -d && sleep 10 && ./migrate.sh upgrade'
```

### Проверка статуса

```bash
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml ps'
```

### Просмотр логов

```bash
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs -f convertik-api'
```

### Перезапуск

```bash
ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml restart convertik-api'
```

---

## ✅ Финальная проверка

После обновления проверьте:

1. **Health check:**
   ```bash
   curl https://convertik.ponravilos.ru/health
   ```

2. **Новый endpoint:**
   ```bash
   curl https://convertik.ponravilos.ru/api/v1/stats/metrics?period=day
   ```

3. **Старый endpoint:**
   ```bash
   curl https://convertik.ponravilos.ru/api/v1/stats/summary
   ```

4. **Документация:**
   ```bash
   curl https://convertik.ponravilos.ru/docs
   ```

5. **Логи:**
   ```bash
   ssh root@ponravilos.ru 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs --tail=50 convertik-api | grep -i error'
   ```

---

## 🎯 Рекомендации

### ✅ Делайте всегда

1. **Создавайте бэкап БД** перед критическими обновлениями
2. **Проверяйте миграции** перед применением
3. **Мониторьте логи** после обновления (5-10 минут)
4. **Тестируйте новые endpoints** сразу после деплоя

### ⚠️ Будьте осторожны

1. **Не обновляйте в пиковые часы** (если возможно)
2. **Не пропускайте миграции** — они могут быть критичны
3. **Не удаляйте старые образы** сразу — может понадобиться откат

### ❌ Не делайте

1. **Не обновляйте `.env.production`** без перезапуска контейнера
2. **Не пропускайте проверки** после обновления
3. **Не удаляйте volumes** при `docker-compose down` (данные БД!)

---

## 📚 Связанные документы

- [DEPLOY_INSTRUCTIONS.md](../backend/DEPLOY_INSTRUCTIONS.md) — Подробная инструкция по первому деплою
- [BACKEND.md](./BACKEND.md) — Архитектура бэкенда
- [API_STATS_SUMMARY.md](./API_STATS_SUMMARY.md) — Документация API
- [README_DEPLOY.md](../backend/README_DEPLOY.md) — Быстрый деплой

---

**Готово! 🎉** Теперь вы знаете, как безопасно обновлять бэкенд Convertik на ponravilos.ru

