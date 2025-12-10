#!/bin/bash

# Скрипт для проверки данных в базе данных Convertik на продакшн сервере

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Проверка данных в базе данных Convertik${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Проверяем, что мы на сервере или можем подключиться
if [ -z "$SSH_CONNECTION" ] && [ ! -f "/opt/convertik/.env.production" ]; then
    echo -e "${YELLOW}⚠️  Запустите этот скрипт на сервере или через SSH:${NC}"
    echo "ssh root@ponravilos.ru 'bash -s' < check_database.sh"
    exit 1
fi

# Загружаем переменные окружения
if [ -f "/opt/convertik/.env.production" ]; then
    export $(grep -v '^#' /opt/convertik/.env.production | xargs)
fi

# Параметры подключения к БД
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5433}"
DB_NAME="${DB_NAME:-convertik}"
DB_USER="${DB_USER:-convertik}"
DB_PASSWORD="${POSTGRES_PASSWORD}"

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ Ошибка: POSTGRES_PASSWORD не задан${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Проверка таблицы usage_events...${NC}"

# Подключаемся к базе данных через Docker контейнер
docker exec -e PGPASSWORD="$DB_PASSWORD" convertik-db psql -U "$DB_USER" -d "$DB_NAME" << EOF

-- Общее количество событий
SELECT
    'Всего событий' as metric,
    COUNT(*)::text as value
FROM usage_events;

-- События за последние 24 часа
SELECT
    'События за 24ч' as metric,
    COUNT(*)::text as value
FROM usage_events
WHERE created_at >= NOW() - INTERVAL '24 hours';

-- События за сегодня (UTC)
SELECT
    'События сегодня (UTC)' as metric,
    COUNT(*)::text as value
FROM usage_events
WHERE created_at >= (NOW() AT TIME ZONE 'UTC')::date;

-- Уникальные устройства за последние 24 часа
SELECT
    'Уникальные устройства (24ч)' as metric,
    COUNT(DISTINCT device_id)::text as value
FROM usage_events
WHERE created_at >= NOW() - INTERVAL '24 hours';

-- Уникальные устройства за сегодня
SELECT
    'Уникальные устройства (сегодня)' as metric,
    COUNT(DISTINCT device_id)::text as value
FROM usage_events
WHERE created_at >= (NOW() AT TIME ZONE 'UTC')::date;

-- Последние 10 событий
SELECT
    'Последние события' as info,
    id,
    device_id,
    event_name,
    created_at AT TIME ZONE 'UTC' as created_at_utc
FROM usage_events
ORDER BY created_at DESC
LIMIT 10;

-- Статистика по типам событий за последние 24 часа
SELECT
    'Топ событий (24ч)' as info,
    event_name,
    COUNT(*) as count
FROM usage_events
WHERE created_at >= NOW() - INTERVAL '24 hours'
GROUP BY event_name
ORDER BY count DESC
LIMIT 10;

-- Временной диапазон данных
SELECT
    'Временной диапазон' as info,
    MIN(created_at AT TIME ZONE 'UTC')::text as earliest_event,
    MAX(created_at AT TIME ZONE 'UTC')::text as latest_event
FROM usage_events;

EOF

echo ""
echo -e "${GREEN}✅ Проверка завершена${NC}"

