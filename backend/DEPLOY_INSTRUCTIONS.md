# 🚀 Инструкция по деплою Convertik Backend на ponravilos.ru

## 📋 Предварительные требования

1. Доступ к серверу `ponravilos.ru` через SSH
2. Docker и docker-compose уже установлены на сервере
3. Existing Caddy setup работает

## 🔧 Подготовка к деплою

### 1. Копирование файлов на сервер

```bash
# Создаем директорию для Convertik
ssh root@ponravilos.ru "mkdir -p /opt/convertik"

# Копируем файлы проекта
scp -r backend/* root@ponravilos.ru:/opt/convertik/
```

### 2. Настройка переменных окружения

```bash
# Подключаемся к серверу
ssh root@ponravilos.ru

# Переходим в директорию проекта
cd /opt/convertik

# Создаем production .env файл
cp env.production.example .env.production

# Редактируем переменные окружения
nano .env.production
```

**Обязательно замените следующие значения:**

- `POSTGRES_PASSWORD` - надежный пароль для PostgreSQL
- `ADMIN_TOKEN` - секретный токен для админ API
- `RATES_API_KEY` - ключ API для получения курсов валют (https://openexchangerates.org/)
- `APNS_*` - настройки для iOS push уведомлений (если нужны)

### 3. Запуск деплоя

```bash
# Запускаем деплой скрипт
./deploy.sh
```

## 🌐 Настройка Caddy для проксирования

### 1. Обновление Caddyfile

```bash
# Редактируем основной Caddyfile
nano /opt/n8n-docker-caddy/caddy_config/Caddyfile
```

Добавьте в конец файла содержимое из `caddy-convertik.conf`:

```
convertik.ponravilos.ru {
    log {
        output file /var/log/caddy/convertik.log
        format json
    }
    
    reverse_proxy convertik-api:8000 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
        
        transport http {
            read_timeout 30s
            write_timeout 30s
        }
    }
    
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

### 2. Подключение Convertik к сети Caddy

```bash
# Создаем внешнюю сеть Caddy (если еще не создана)
docker network create caddy || true

# Подключаем существующий Caddy к сети
cd /opt/n8n-docker-caddy
docker-compose down
docker-compose up -d

# Подключаем Convertik к сети Caddy
cd /opt/convertik
docker network connect caddy convertik-api
```

### 3. Перезагрузка Caddy

```bash
# Перезагружаем конфигурацию Caddy
docker exec -it n8n-docker-caddy-caddy-1 caddy reload --config /etc/caddy/Caddyfile
```

## 🌍 Настройка DNS

Добавьте A-запись в DNS настройках домена:

```
convertik    A    185.70.105.198
```

**Где добавить:**
- Панель управления Hostkey.ru
- Раздел DNS управления
- Добавить новую A-запись

## ✅ Проверка деплоя

### 1. Проверка контейнеров

```bash
cd /opt/convertik
docker-compose -f docker-compose.production.yml ps
```

Все контейнеры должны быть в статусе `Up`.

### 2. Проверка API

```bash
# Проверка локального доступа
curl http://localhost:8001/

# Проверка через домен (после настройки DNS)
curl https://convertik.ponravilos.ru/
```

### 3. Проверка логов

```bash
# Логи API
docker-compose -f docker-compose.production.yml logs -f convertik-api

# Логи базы данных
docker-compose -f docker-compose.production.yml logs -f convertik-db

# Логи Caddy
docker logs n8n-docker-caddy-caddy-1
```

## 🔧 Управление сервисом

### Полезные команды

```bash
cd /opt/convertik

# Перезапуск всех сервисов
docker-compose -f docker-compose.production.yml restart

# Перезапуск только API
docker-compose -f docker-compose.production.yml restart convertik-api

# Остановка сервисов
docker-compose -f docker-compose.production.yml down

# Запуск сервисов
docker-compose -f docker-compose.production.yml up -d

# Просмотр логов
docker-compose -f docker-compose.production.yml logs -f

# Обновление кода (после изменений)
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml build --no-cache
docker-compose -f docker-compose.production.yml up -d
```

### Миграции базы данных

```bash
# Запуск миграций
docker-compose -f docker-compose.production.yml exec convertik-api alembic upgrade head

# Создание новой миграции (при разработке)
docker-compose -f docker-compose.production.yml exec convertik-api alembic revision --autogenerate -m "описание изменений"
```

### Резервное копирование

```bash
# Создание бэкапа базы данных
docker-compose -f docker-compose.production.yml exec convertik-db pg_dump -U convertik convertik > convertik_backup_$(date +%Y%m%d_%H%M%S).sql

# Восстановление из бэкапа
docker-compose -f docker-compose.production.yml exec -i convertik-db psql -U convertik convertik < convertik_backup_file.sql
```

## 🚨 Troubleshooting

### Проблема: Контейнеры не запускаются

1. Проверьте логи: `docker-compose -f docker-compose.production.yml logs`
2. Убедитесь что порты 8001, 5433, 6380 свободны
3. Проверьте переменные окружения в `.env.production`

### Проблема: API недоступен через домен

1. Проверьте DNS запись: `dig convertik.ponravilos.ru +short`
2. Проверьте конфигурацию Caddy: `docker logs n8n-docker-caddy-caddy-1`
3. Убедитесь что Convertik подключен к сети Caddy

### Проблема: SSL сертификат не получается

1. Убедитесь что DNS запись корректна и распространилась
2. Проверьте логи Caddy: `docker logs n8n-docker-caddy-caddy-1`
3. Попробуйте перезапустить Caddy: `docker-compose -f /opt/n8n-docker-caddy/docker-compose.yml restart caddy`

## 🎯 Финальная проверка

После успешного деплоя у вас должно быть:

- ✅ API доступен по `https://convertik.ponravilos.ru/`
- ✅ Документация API: `https://convertik.ponravilos.ru/docs`
- ✅ SSL сертификат автоматически получен
- ✅ Все контейнеры работают стабильно
- ✅ Логи не содержат критических ошибок

**Готово! 🎉 Convertik Backend успешно развернут на ponravilos.ru**