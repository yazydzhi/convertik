# 🚀 Быстрый деплой Convertik на ponravilos.ru

## 📋 Краткая инструкция

### 1. Подготовка файлов

```bash
# Копируем проект на сервер
scp -r backend/* root@ponravilos.ru:/opt/convertik/
```

### 2. Настройка на сервере

```bash
# Подключаемся к серверу
ssh root@ponravilos.ru

# Переходим в директорию
cd /opt/convertik

# Создаем .env файл
cp env.production.example .env.production
nano .env.production  # Редактируем переменные!

# ВАЖНО: Замените эти значения:
# - POSTGRES_PASSWORD=ваш_надежный_пароль
# - ADMIN_TOKEN=ваш_секретный_токен  
# - RATES_API_KEY=ваш_ключ_api

# Запускаем деплой
./deploy.sh
```

### 3. Настройка Caddy

```bash
# Добавляем конфигурацию в Caddyfile
nano /opt/n8n-docker-caddy/caddy_config/Caddyfile
```

Добавьте в конец:
```
convertik.ponravilos.ru {
    reverse_proxy convertik-api:8000
}
```

```bash
# Создаем сеть и подключаем сервисы
docker network create caddy || true
docker network connect caddy convertik-api

# Перезагружаем Caddy
docker exec -it n8n-docker-caddy-caddy-1 caddy reload --config /etc/caddy/Caddyfile
```

### 4. DNS настройка

В панели Hostkey.ru добавьте A-запись:
```
convertik    A    185.70.105.198
```

### 5. Проверка

```bash
# Проверяем что работает
curl https://convertik.ponravilos.ru/
curl https://convertik.ponravilos.ru/docs
```

## 🎯 Результат

- ✅ API: https://convertik.ponravilos.ru/
- ✅ Docs: https://convertik.ponravilos.ru/docs  
- ✅ SSL сертификат автоматически
- ✅ Автозапуск при перезагрузке сервера

## 🔧 Управление

```bash
cd /opt/convertik

# Перезапуск
docker-compose -f docker-compose.production.yml restart

# Логи
docker-compose -f docker-compose.production.yml logs -f

# Миграции
./migrate.sh upgrade
```

**Подробные инструкции:** см. `DEPLOY_INSTRUCTIONS.md`