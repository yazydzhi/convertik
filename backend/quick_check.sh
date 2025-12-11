#!/bin/bash

# Быстрая проверка данных и метрик на продакшн сервере

echo "🔍 Быстрая проверка данных Convertik"
echo "======================================"
echo ""

# Проверка 1: Общее количество событий
echo "1. Общее количество событий в базе:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events;" 2>/dev/null || echo "❌ Не удалось подключиться к БД"

echo ""
echo "2. События за последние 24 часа:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events WHERE created_at >= NOW() - INTERVAL '24 hours';" 2>/dev/null || echo "❌ Ошибка запроса"

echo ""
echo "3. Последнее событие:"
docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT created_at AT TIME ZONE 'UTC' FROM usage_events ORDER BY created_at DESC LIMIT 1;" 2>/dev/null || echo "❌ Ошибка запроса"

echo ""
echo "4. Тест endpoint /stats/metrics:"
curl -s "https://api.convertik.ponravilos.ru/api/v1/stats/metrics?period=day" | python3 -m json.tool 2>/dev/null || echo "❌ Не удалось получить метрики"

echo ""
echo "✅ Проверка завершена"


