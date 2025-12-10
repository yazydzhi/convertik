#!/bin/bash

# Скрипт деплоя фронтенда и бэкенда Convertik на сервер
# Использование: ./deploy.sh [backend|frontend|all]
# По умолчанию деплоит все (backend + frontend)

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверяем что находимся в корне проекта
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo -e "${RED}❌ Ошибка: Запустите скрипт из корня проекта${NC}"
    exit 1
fi

# Проверяем наличие .env файла
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Ошибка: Файл .env не найден${NC}"
    echo "Создайте его на основе .env.example:"
    echo "cp .env.example .env"
    echo "И заполните все переменные окружения!"
    exit 1
fi

# Загружаем переменные окружения
echo -e "${BLUE}📋 Загружаем переменные окружения из .env...${NC}"
export $(grep -v '^#' .env | xargs)

# Проверяем обязательные переменные
if [ -z "$DEPLOY_HOST" ]; then
    echo -e "${RED}❌ Ошибка: DEPLOY_HOST не задан в .env${NC}"
    exit 1
fi

if [ -z "$DEPLOY_USER" ]; then
    echo -e "${RED}❌ Ошибка: DEPLOY_USER не задан в .env${NC}"
    exit 1
fi

if [ -z "$DEPLOY_BACKEND_PATH" ]; then
    echo -e "${YELLOW}⚠️  DEPLOY_BACKEND_PATH не задан, используем значение по умолчанию: /opt/convertik${NC}"
    DEPLOY_BACKEND_PATH="/opt/convertik"
fi

if [ -z "$DEPLOY_FRONTEND_PATH" ]; then
    echo -e "${YELLOW}⚠️  DEPLOY_FRONTEND_PATH не задан, используем значение по умолчанию: /opt/www${NC}"
    DEPLOY_FRONTEND_PATH="/opt/www"
fi

# Настройка SSH опций
SSH_OPTS=""
if [ -n "$DEPLOY_SSH_KEY" ]; then
    SSH_OPTS="-i $DEPLOY_SSH_KEY"
fi

if [ -n "$DEPLOY_SSH_PORT" ]; then
    if [ -n "$SSH_OPTS" ]; then
        SSH_OPTS="$SSH_OPTS -p $DEPLOY_SSH_PORT"
    else
        SSH_OPTS="-p $DEPLOY_SSH_PORT"
    fi
fi

# RSYNC опции для SSH
RSYNC_SSH_OPTS=""
if [ -n "$DEPLOY_SSH_KEY" ]; then
    RSYNC_SSH_OPTS="ssh -i $DEPLOY_SSH_KEY"
    if [ -n "$DEPLOY_SSH_PORT" ]; then
        RSYNC_SSH_OPTS="$RSYNC_SSH_OPTS -p $DEPLOY_SSH_PORT"
    fi
elif [ -n "$DEPLOY_SSH_PORT" ]; then
    RSYNC_SSH_OPTS="ssh -p $DEPLOY_SSH_PORT"
fi

# Функция для выполнения SSH команд
ssh_cmd() {
    if [ -n "$SSH_OPTS" ]; then
        ssh $SSH_OPTS ${DEPLOY_USER}@${DEPLOY_HOST} "$@"
    else
        ssh ${DEPLOY_USER}@${DEPLOY_HOST} "$@"
    fi
}

# Функция для выполнения SCP команд
scp_cmd() {
    if [ -n "$SSH_OPTS" ]; then
        scp $SSH_OPTS "$@"
    else
        scp "$@"
    fi
}

# Определяем что деплоить
DEPLOY_TARGET="${1:-all}"

echo -e "${GREEN}🚀 Начинаем деплой Convertik на ${DEPLOY_HOST}...${NC}"
echo -e "${BLUE}📦 Цель деплоя: ${DEPLOY_TARGET}${NC}"
echo ""

# Функция для деплоя бэкенда
deploy_backend() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🐳 Деплой бэкенда...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Создаем временную директорию для rsync
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    echo -e "${YELLOW}📦 Копируем файлы бэкенда на сервер...${NC}"

    # Копируем файлы бэкенда
    if [ -n "$RSYNC_SSH_OPTS" ]; then
        rsync -avz --delete --rsh="$RSYNC_SSH_OPTS" \
            --exclude='.git' \
            --exclude='__pycache__' \
            --exclude='*.pyc' \
            --exclude='.env' \
            --exclude='.env.production' \
            --exclude='venv' \
            --exclude='.pytest_cache' \
            --exclude='*.log' \
            backend/ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_BACKEND_PATH}/
    else
        rsync -avz --delete \
            --exclude='.git' \
            --exclude='__pycache__' \
            --exclude='*.pyc' \
            --exclude='.env' \
            --exclude='.env.production' \
            --exclude='venv' \
            --exclude='.pytest_cache' \
            --exclude='*.log' \
            backend/ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_BACKEND_PATH}/
    fi

    echo -e "${GREEN}✅ Файлы бэкенда скопированы${NC}"

    # Копируем .env.production если он существует локально
    if [ -f "backend/.env.production" ]; then
        echo -e "${YELLOW}📋 Копируем .env.production на сервер...${NC}"
        scp_cmd backend/.env.production ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_BACKEND_PATH}/.env.production
    else
        echo -e "${YELLOW}⚠️  backend/.env.production не найден локально${NC}"
        echo -e "${YELLOW}⚠️  Убедитесь что .env.production существует на сервере${NC}"
    fi

    echo -e "${YELLOW}🔧 Запускаем деплой скрипт на сервере...${NC}"

    # Запускаем деплой скрипт на сервере
    if [ -n "$SSH_OPTS" ]; then
        ssh $SSH_OPTS ${DEPLOY_USER}@${DEPLOY_HOST} << EOF
        set -e
        cd ${DEPLOY_BACKEND_PATH}

        # Проверяем наличие .env.production
        if [ ! -f ".env.production" ]; then
            echo -e "${RED}❌ Ошибка: .env.production не найден на сервере${NC}"
            echo "Создайте его: cp env.production.example .env.production"
            exit 1
        fi

        # Делаем скрипт исполняемым (используем server-deploy.sh если есть, иначе deploy.sh)
        if [ -f "server-deploy.sh" ]; then
            chmod +x server-deploy.sh
            ./server-deploy.sh
        elif [ -f "deploy.sh" ]; then
            chmod +x deploy.sh
            ./deploy.sh
        else
            echo -e "${RED}❌ Ошибка: Не найден скрипт деплоя на сервере${NC}"
            echo "Ожидался server-deploy.sh или deploy.sh в ${DEPLOY_BACKEND_PATH}"
            exit 1
        fi
EOF
    else
        ssh ${DEPLOY_USER}@${DEPLOY_HOST} << EOF
        set -e
        cd ${DEPLOY_BACKEND_PATH}

        # Проверяем наличие .env.production
        if [ ! -f ".env.production" ]; then
            echo -e "${RED}❌ Ошибка: .env.production не найден на сервере${NC}"
            echo "Создайте его: cp env.production.example .env.production"
            exit 1
        fi

        # Делаем скрипт исполняемым (используем server-deploy.sh если есть, иначе deploy.sh)
        if [ -f "server-deploy.sh" ]; then
            chmod +x server-deploy.sh
            ./server-deploy.sh
        elif [ -f "deploy.sh" ]; then
            chmod +x deploy.sh
            ./deploy.sh
        else
            echo -e "${RED}❌ Ошибка: Не найден скрипт деплоя на сервере${NC}"
            echo "Ожидался server-deploy.sh или deploy.sh в ${DEPLOY_BACKEND_PATH}"
            exit 1
        fi
EOF
    fi

    echo -e "${GREEN}✅ Бэкенд успешно задеплоен!${NC}"
    echo ""
}

# Функция для деплоя фронтенда
deploy_frontend() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🌐 Деплой фронтенда...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${YELLOW}📦 Копируем файлы фронтенда на сервер...${NC}"

    # Создаем директорию если её нет
    ssh_cmd "mkdir -p ${DEPLOY_FRONTEND_PATH}"

    # Копируем файлы фронтенда
    if [ -n "$RSYNC_SSH_OPTS" ]; then
        rsync -avz --delete --rsh="$RSYNC_SSH_OPTS" \
            --exclude='.git' \
            --exclude='README.md' \
            frontend/convertik/ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_FRONTEND_PATH}/
    else
        rsync -avz --delete \
            --exclude='.git' \
            --exclude='README.md' \
            frontend/convertik/ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_FRONTEND_PATH}/
    fi

    echo -e "${GREEN}✅ Файлы фронтенда скопированы${NC}"

    # Проверяем доступность сайта
    echo -e "${YELLOW}🔍 Проверяем доступность сайта...${NC}"
    sleep 2

    if [ -n "$DEPLOY_FRONTEND_DOMAIN" ]; then
        if curl -s -o /dev/null -w "%{http_code}" "https://${DEPLOY_FRONTEND_DOMAIN}" | grep -q "200\|301\|302"; then
            echo -e "${GREEN}✅ Сайт доступен: https://${DEPLOY_FRONTEND_DOMAIN}${NC}"
        else
            echo -e "${YELLOW}⚠️  Сайт может быть недоступен или еще не настроен${NC}"
        fi
    fi

    echo -e "${GREEN}✅ Фронтенд успешно задеплоен!${NC}"
    echo ""
}

# Выполняем деплой в зависимости от параметра
case "$DEPLOY_TARGET" in
    backend)
        deploy_backend
        ;;
    frontend)
        deploy_frontend
        ;;
    all)
        deploy_backend
        deploy_frontend
        ;;
    *)
        echo -e "${RED}❌ Неизвестный параметр: $DEPLOY_TARGET${NC}"
        echo "Использование: ./deploy.sh [backend|frontend|all]"
        exit 1
        ;;
esac

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Деплой завершен успешно!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Полезные команды:${NC}"
echo ""
if [ "$DEPLOY_TARGET" = "backend" ] || [ "$DEPLOY_TARGET" = "all" ]; then
    echo -e "${YELLOW}Бэкенд:${NC}"
    echo "  ssh $SSH_OPTS ${DEPLOY_USER}@${DEPLOY_HOST} 'cd ${DEPLOY_BACKEND_PATH} && docker-compose -f docker-compose.production.yml logs -f'"
    echo "  ssh $SSH_OPTS ${DEPLOY_USER}@${DEPLOY_HOST} 'cd ${DEPLOY_BACKEND_PATH} && docker-compose -f docker-compose.production.yml ps'"
    echo ""
fi
if [ "$DEPLOY_TARGET" = "frontend" ] || [ "$DEPLOY_TARGET" = "all" ]; then
    echo -e "${YELLOW}Фронтенд:${NC}"
    if [ -n "$DEPLOY_FRONTEND_DOMAIN" ]; then
        echo "  https://${DEPLOY_FRONTEND_DOMAIN}"
    fi
    echo ""
fi
