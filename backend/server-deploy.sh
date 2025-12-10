#!/bin/bash

# Скрипт деплоя Convertik Backend на сервере
# Этот скрипт выполняется НА СЕРВЕРЕ в /opt/convertik
# Использование: ./server-deploy.sh

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Деплой Convertik Backend на сервере${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Проверяем что находимся в правильной директории
if [ ! -f "docker-compose.production.yml" ]; then
    echo -e "${RED}❌ Ошибка: Запустите скрипт из директории /opt/convertik${NC}"
    echo "Текущая директория: $(pwd)"
    exit 1
fi

# Проверяем наличие .env.production
if [ ! -f ".env.production" ]; then
    echo -e "${RED}❌ Ошибка: .env.production не найден${NC}"
    echo "Создайте его: cp env.production.example .env.production"
    exit 1
fi

# Загружаем переменные окружения
echo -e "${YELLOW}📋 Загружаем переменные окружения...${NC}"
export $(grep -v '^#' .env.production | xargs)

# Проверяем текущий статус
echo -e "${YELLOW}📊 Проверяем текущий статус контейнеров...${NC}"
docker-compose -f docker-compose.production.yml ps

echo ""
echo -e "${YELLOW}🛑 Останавливаем существующие контейнеры...${NC}"
# Останавливаем контейнеры (без удаления volumes - сохраняем данные БД)
docker-compose -f docker-compose.production.yml down

echo ""
echo -e "${YELLOW}🔨 Собираем новый Docker образ...${NC}"
# Собираем новый образ с очисткой кэша
docker-compose -f docker-compose.production.yml build --no-cache

echo ""
echo -e "${YELLOW}🚀 Запускаем контейнеры...${NC}"
# Запускаем контейнеры
docker-compose -f docker-compose.production.yml up -d

echo ""
echo -e "${YELLOW}⏳ Ждем запуска сервисов (10 секунд)...${NC}"
sleep 10

# Проверяем статус
echo ""
echo -e "${YELLOW}📊 Проверяем статус контейнеров...${NC}"
docker-compose -f docker-compose.production.yml ps

# Проверяем что API контейнер запущен
if ! docker-compose -f docker-compose.production.yml ps convertik-api | grep -q "Up"; then
    echo -e "${RED}❌ Ошибка: Контейнер convertik-api не запущен${NC}"
    echo "Проверьте логи:"
    echo "docker-compose -f docker-compose.production.yml logs convertik-api"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 Применяем миграции базы данных...${NC}"
# Применяем миграции
if [ -f "migrate.sh" ]; then
    chmod +x migrate.sh
    ./migrate.sh upgrade
else
    # Если migrate.sh нет, применяем напрямую
    docker-compose -f docker-compose.production.yml exec -T convertik-api alembic upgrade head
fi

echo ""
echo -e "${YELLOW}🔍 Проверяем работоспособность...${NC}"
# Ждем еще немного для полного запуска
sleep 5

# Проверяем health check
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/health || echo "000")
if [ "$HEALTH_CHECK" = "200" ]; then
    echo -e "${GREEN}✅ Health check успешен (HTTP $HEALTH_CHECK)${NC}"
else
    echo -e "${YELLOW}⚠️  Health check вернул код: $HEALTH_CHECK${NC}"
    echo "Проверьте логи: docker-compose -f docker-compose.production.yml logs convertik-api"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Деплой завершен успешно!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Полезные команды:${NC}"
echo ""
echo -e "${YELLOW}Просмотр логов:${NC}"
echo "  docker-compose -f docker-compose.production.yml logs -f convertik-api"
echo ""
echo -e "${YELLOW}Проверка статуса:${NC}"
echo "  docker-compose -f docker-compose.production.yml ps"
echo ""
echo -e "${YELLOW}Перезапуск API:${NC}"
echo "  docker-compose -f docker-compose.production.yml restart convertik-api"
echo ""
echo -e "${YELLOW}Проверка health:${NC}"
echo "  curl http://localhost:8001/health"
echo "  curl https://convertik.ponravilos.ru/health"
echo ""


