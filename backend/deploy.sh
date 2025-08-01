#!/bin/bash

# Деплой скрипт для Convertik Backend на ponravilos.ru
# Использование: ./deploy.sh

set -e

echo "🚀 Начинаем деплой Convertik Backend на ponravilos.ru..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверяем что находимся в правильной директории
if [ ! -f "docker-compose.production.yml" ]; then
    echo -e "${RED}❌ Ошибка: Запустите скрипт из директории backend/${NC}"
    exit 1
fi

# Проверяем что .env.production существует
if [ ! -f ".env.production" ]; then
    echo -e "${YELLOW}⚠️  Файл .env.production не найден${NC}"
    echo "Создайте его на основе env.production.example:"
    echo "cp env.production.example .env.production"
    echo "И отредактируйте все переменные окружения!"
    exit 1
fi

echo "📋 Проверяем переменные окружения..."
source .env.production

# Проверяем основные переменные
if [ "$POSTGRES_PASSWORD" = "your_secure_postgres_password_here" ]; then
    echo -e "${RED}❌ Пожалуйста, замените POSTGRES_PASSWORD в .env.production${NC}"
    exit 1
fi

if [ "$ADMIN_TOKEN" = "your_super_secure_admin_token_here" ]; then
    echo -e "${RED}❌ Пожалуйста, замените ADMIN_TOKEN в .env.production${NC}"
    exit 1
fi

echo "🐳 Останавливаем существующие контейнеры (если есть)..."
docker-compose -f docker-compose.production.yml down || true

echo "🏗️  Собираем Docker образ..."
docker-compose -f docker-compose.production.yml build --no-cache

echo "🚀 Запускаем сервисы..."
docker-compose -f docker-compose.production.yml up -d

echo "⏳ Ждем запуска сервисов..."
sleep 10

echo "🔍 Проверяем статус контейнеров..."
docker-compose -f docker-compose.production.yml ps

echo "📊 Запускаем миграции базы данных..."
docker-compose -f docker-compose.production.yml exec convertik-api alembic upgrade head

echo "✅ Деплой завершен!"
echo ""
echo "🌐 API доступен по адресу: http://localhost:8001"
echo "📚 Документация API: http://localhost:8001/docs"
echo ""
echo "📝 Для интеграции с Caddy:"
echo "1. Добавьте содержимое caddy-convertik.conf в /opt/n8n-docker-caddy/caddy_config/Caddyfile"
echo "2. Перезагрузите Caddy: docker exec -it n8n-docker-caddy-caddy-1 caddy reload --config /etc/caddy/Caddyfile"
echo "3. Добавьте DNS запись: convertik A 185.70.105.198"
echo ""
echo "📋 Полезные команды:"
echo "docker-compose -f docker-compose.production.yml logs -f convertik-api  # логи API"
echo "docker-compose -f docker-compose.production.yml logs -f convertik-db   # логи БД"
echo "docker-compose -f docker-compose.production.yml restart convertik-api  # перезапуск API"