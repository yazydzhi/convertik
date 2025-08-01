#!/bin/bash

# Скрипт для управления миграциями Convertik Database
# Использование: ./migrate.sh [upgrade|create|downgrade]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Проверяем что находимся в правильной директории
if [ ! -f "docker-compose.production.yml" ]; then
    echo -e "${RED}❌ Ошибка: Запустите скрипт из директории backend/${NC}"
    exit 1
fi

# Функция помощи
show_help() {
    echo "Управление миграциями Convertik Database"
    echo ""
    echo "Использование: ./migrate.sh [КОМАНДА]"
    echo ""
    echo "Команды:"
    echo "  upgrade          Применить все новые миграции"
    echo "  create [name]    Создать новую миграцию"
    echo "  downgrade        Откатить последнюю миграцию"
    echo "  history          Показать историю миграций"
    echo "  current          Показать текущую ревизию"
    echo "  help             Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  ./migrate.sh upgrade"
    echo "  ./migrate.sh create \"add user table\""
    echo "  ./migrate.sh downgrade"
}

# Проверяем что API контейнер запущен
check_container() {
    if ! docker-compose -f docker-compose.production.yml ps convertik-api | grep -q "Up"; then
        echo -e "${YELLOW}⚠️  Контейнер convertik-api не запущен. Запускаем...${NC}"
        docker-compose -f docker-compose.production.yml up -d convertik-api
        echo "⏳ Ждем запуска контейнера..."
        sleep 10
    fi
}

# Функция для выполнения alembic команд
run_alembic() {
    docker-compose -f docker-compose.production.yml exec convertik-api alembic "$@"
}

case "$1" in
    "upgrade")
        echo "🔄 Применяем миграции..."
        check_container
        run_alembic upgrade head
        echo -e "${GREEN}✅ Миграции успешно применены${NC}"
        ;;
    
    "create")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Укажите название миграции${NC}"
            echo "Пример: ./migrate.sh create \"add user table\""
            exit 1
        fi
        echo "📝 Создаем новую миграцию: $2"
        check_container
        run_alembic revision --autogenerate -m "$2"
        echo -e "${GREEN}✅ Миграция создана${NC}"
        ;;
    
    "downgrade")
        echo "⬇️  Откатываем последнюю миграцию..."
        check_container
        run_alembic downgrade -1
        echo -e "${GREEN}✅ Миграция откачена${NC}"
        ;;
    
    "history")
        echo "📋 История миграций:"
        check_container
        run_alembic history
        ;;
    
    "current")
        echo "📍 Текущая ревизия:"
        check_container
        run_alembic current
        ;;
    
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    
    *)
        echo -e "${RED}❌ Неизвестная команда: $1${NC}"
        show_help
        exit 1
        ;;
esac