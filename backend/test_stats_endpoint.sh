#!/bin/bash

# Скрипт для тестирования endpoint /stats

echo "🧪 Тестирование endpoint /stats"
echo "=================================="
echo ""

API_URL="https://api.convertik.ponravilos.ru/api/v1/stats"
TIMESTAMP=$(date +%s)

echo "1. Отправка тестового события..."
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"events\": [
      {
        \"device_id\": \"550e8400-e29b-41d4-a716-446655440000\",
        \"name\": \"test_event\",
        \"ts\": $TIMESTAMP,
        \"params\": {\"test\": true, \"source\": \"diagnostics\"}
      }
    ]
  }")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

echo "HTTP Status: $HTTP_CODE"
echo "Response:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Событие успешно отправлено"
    echo ""
    echo "2. Проверка, что событие сохранилось в БД..."
    sleep 2

    EVENT_COUNT=$(docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -t -c "SELECT COUNT(*) FROM usage_events WHERE event_name = 'test_event';" 2>/dev/null | tr -d ' ')

    if [ "$EVENT_COUNT" -gt 0 ]; then
        echo "✅ Событие найдено в БД (количество: $EVENT_COUNT)"
        echo ""
        echo "3. Детали события:"
        docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-convertik}" convertik-db psql -U convertik -d convertik -c "SELECT id, device_id, event_name, created_at AT TIME ZONE 'UTC' as created_at_utc FROM usage_events WHERE event_name = 'test_event' ORDER BY created_at DESC LIMIT 1;" 2>/dev/null
    else
        echo "❌ Событие НЕ найдено в БД"
        echo "   Возможные причины:"
        echo "   - Ошибка при сохранении в БД"
        echo "   - Проблема с транзакцией"
        echo "   - Проблема с подключением к БД"
    fi
else
    echo "❌ Ошибка при отправке события"
    echo "   Проверьте логи API:"
    echo "   docker logs convertik-api --tail=50"
fi

echo ""
echo "✅ Тест завершен"

