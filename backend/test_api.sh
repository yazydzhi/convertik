#!/bin/bash

# Скрипт для тестирования API эндпоинтов Convertik Backend
# Использование: ./test_api.sh

echo "🧪 Testing Convertik Backend API"
echo "=================================="

BASE_URL="http://localhost:8000"
ADMIN_TOKEN="your-secret-admin-token"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local headers=$3
    local data=$4
    local description=$5
    
    echo -e "\n${YELLOW}Testing:${NC} $description"
    echo "Endpoint: $method $endpoint"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X $method \
            -H "Content-Type: application/json" \
            $headers \
            -d "$data" \
            "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "%{http_code}" -X $method \
            -H "Content-Type: application/json" \
            $headers \
            "$BASE_URL$endpoint")
    fi
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ PASS${NC} (HTTP $http_code)"
        echo "Response: $(echo "$body" | jq -r . 2>/dev/null || echo "$body")"
    else
        echo -e "${RED}❌ FAIL${NC} (HTTP $http_code)"
        echo "Response: $body"
    fi
}

echo -e "\n📡 1. Testing Basic Endpoints"
echo "------------------------------"

# Test root endpoint
test_endpoint "GET" "/" "" "" "Root endpoint"

# Test health check
test_endpoint "GET" "/health" "" "" "Health check"

echo -e "\n💱 2. Testing Exchange Rates API"
echo "--------------------------------"

# Test get all rates
test_endpoint "GET" "/api/v1/rates" "" "" "Get all exchange rates"

# Test get specific rate
test_endpoint "GET" "/api/v1/rates/USD" "" "" "Get USD exchange rate"

# Test non-existent rate
test_endpoint "GET" "/api/v1/rates/INVALID" "" "" "Get non-existent currency (should fail)"

echo -e "\n📊 3. Testing Analytics API"
echo "---------------------------"

# Test analytics submission
analytics_payload='[
  {
    "name": "app_open",
    "device_id": "550e8400-e29b-41d4-a716-446655440000",
    "ts": 1690800000,
    "params": {"app_version": "1.0.0"}
  },
  {
    "name": "conversion",
    "device_id": "550e8400-e29b-41d4-a716-446655440000", 
    "ts": 1690800060,
    "params": {"from": "USD", "to": "EUR", "amount": 100}
  }
]'

test_endpoint "POST" "/api/v1/stats" "" "$analytics_payload" "Submit analytics events"

# Test analytics summary
test_endpoint "GET" "/api/v1/stats/summary" "" "" "Get analytics summary"

echo -e "\n🔧 4. Testing Admin API"
echo "----------------------"

# Test scheduler status
test_endpoint "GET" "/api/v1/admin/scheduler/status" "-H \"X-Admin-Token: $ADMIN_TOKEN\"" "" "Get scheduler status (admin)"

# Test rates stats
test_endpoint "GET" "/api/v1/admin/rates/stats" "-H \"X-Admin-Token: $ADMIN_TOKEN\"" "" "Get rates statistics (admin)"

# Test manual rates update
test_endpoint "POST" "/api/v1/admin/rates/update" "-H \"X-Admin-Token: $ADMIN_TOKEN\"" "" "Trigger manual rates update (admin)"

# Test admin without token (should fail)
test_endpoint "GET" "/api/v1/admin/scheduler/status" "" "" "Admin endpoint without token (should fail)"

echo -e "\n🚨 5. Testing Error Handling"  
echo "----------------------------"

# Test invalid JSON
test_endpoint "POST" "/api/v1/stats" "" "invalid json" "Invalid JSON payload (should fail)"

# Test large payload
large_payload=$(printf '{"events":['; for i in {1..51}; do printf '{"name":"test","device_id":"550e8400-e29b-41d4-a716-446655440000","ts":1690800000}'; [ $i -lt 51 ] && printf ','; done; printf ']}')
test_endpoint "POST" "/api/v1/stats" "" "$large_payload" "Too many events in batch (should fail)"

echo -e "\n🎯 6. Testing OpenAPI Documentation"
echo "-----------------------------------"

# Test Swagger docs
test_endpoint "GET" "/docs" "" "" "Swagger UI documentation"

# Test OpenAPI schema
test_endpoint "GET" "/openapi.json" "" "" "OpenAPI schema"

echo -e "\n${GREEN}🎉 API Testing Complete!${NC}"
echo "==============================="
echo "Check the results above to ensure all endpoints are working correctly."