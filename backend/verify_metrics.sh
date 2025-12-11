#!/bin/bash

# Проверка метрик после добавления тестовых событий

echo "📊 Проверка метрик после тестовых событий"
echo "=========================================="
echo ""

echo "1. Количество событий в БД:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events;" 2>/dev/null

echo ""
echo "2. События за последние 24 часа:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events WHERE created_at >= NOW() - INTERVAL '24 hours';" 2>/dev/null

echo ""
echo "3. События за сегодня (UTC):"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events WHERE created_at >= (NOW() AT TIME ZONE 'UTC')::date;" 2>/dev/null

echo ""
echo "4. Уникальные устройства за последние 24 часа:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(DISTINCT device_id) FROM usage_events WHERE created_at >= NOW() - INTERVAL '24 hours';" 2>/dev/null

echo ""
echo "5. Запрос метрик через API:"
curl -s "https://api.convertik.ponravilos.ru/api/v1/stats/metrics?period=day" | python3 -m json.tool 2>/dev/null || echo "❌ Ошибка получения метрик"

echo ""
echo "6. Все события за сегодня:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -c "SELECT id, device_id, event_name, created_at AT TIME ZONE 'UTC' as created_at_utc FROM usage_events WHERE created_at >= (NOW() AT TIME ZONE 'UTC')::date ORDER BY created_at DESC;" 2>/dev/null

echo ""
echo "✅ Проверка завершена"


