# 🚀 Скрипт деплоя Convertik

Универсальный скрипт для деплоя фронтенда и бэкенда на сервер.

## 📋 Предварительные требования

1. **SSH доступ к серверу** - настроенный SSH ключ или пароль
2. **rsync** - установлен на локальной машине
3. **Docker и docker-compose** - установлены на сервере (для бэкенда)
4. **Файл `.env`** - с конфигурацией деплоя в корне проекта

## 🔧 Настройка

### 1. Создайте файл `.env`

Скопируйте пример конфигурации:
```bash
cp .env.example .env
```

### 2. Заполните переменные в `.env`

```bash
# SSH подключение к серверу
DEPLOY_HOST=ponravilos.ru
DEPLOY_USER=root

# Пути на сервере
DEPLOY_BACKEND_PATH=/opt/convertik
DEPLOY_FRONTEND_PATH=/opt/www

# Домен фронтенда (опционально)
DEPLOY_FRONTEND_DOMAIN=convertik.ponravilos.ru

# SSH ключ (опционально, если не используете стандартный ~/.ssh/id_rsa)
# DEPLOY_SSH_KEY=~/.ssh/id_rsa

# Порт SSH (опционально, по умолчанию 22)
# DEPLOY_SSH_PORT=22
```

### 3. Подготовьте `.env.production` для бэкенда

Создайте файл `backend/.env.production` на основе `backend/env.production.example`:
```bash
cd backend
cp env.production.example .env.production
nano .env.production  # Заполните все переменные
```

**Важно:** Файл `backend/.env.production` будет скопирован на сервер автоматически при деплое.

## 🚀 Использование

### Деплой всего (фронтенд + бэкенд)

```bash
./deploy.sh
```

или

```bash
./deploy.sh all
```

### Деплой только бэкенда

```bash
./deploy.sh backend
```

### Деплой только фронтенда

```bash
./deploy.sh frontend
```

## 📦 Что делает скрипт

### Деплой бэкенда:

1. ✅ Копирует файлы бэкенда на сервер через `rsync`
2. ✅ Копирует `.env.production` на сервер (если существует локально)
3. ✅ Запускает `deploy.sh` на сервере, который:
   - Останавливает существующие контейнеры
   - Собирает Docker образ
   - Запускает сервисы
   - Выполняет миграции базы данных

### Деплой фронтенда:

1. ✅ Создает директорию на сервере (если не существует)
2. ✅ Копирует файлы фронтенда на сервер через `rsync`
3. ✅ Проверяет доступность сайта (если указан домен)

## 🔍 Что исключается при деплое

### Бэкенд:
- `.git/`
- `__pycache__/`, `*.pyc`
- `.env`, `.env.production` (копируется отдельно)
- `venv/`
- `.pytest_cache/`
- `*.log`

### Фронтенд:
- `.git/`
- `README.md`

## 🛠 Полезные команды после деплоя

### Просмотр логов бэкенда:
```bash
ssh $DEPLOY_USER@$DEPLOY_HOST 'cd /opt/convertik && docker-compose -f docker-compose.production.yml logs -f'
```

### Проверка статуса контейнеров:
```bash
ssh $DEPLOY_USER@$DEPLOY_HOST 'cd /opt/convertik && docker-compose -f docker-compose.production.yml ps'
```

### Перезапуск бэкенда:
```bash
ssh $DEPLOY_USER@$DEPLOY_HOST 'cd /opt/convertik && docker-compose -f docker-compose.production.yml restart'
```

## 🔐 Безопасность

- ✅ `.env` файл не копируется на сервер
- ✅ `.env.production` копируется отдельно и только если существует локально
- ✅ Используется SSH для безопасного подключения
- ✅ Поддержка SSH ключей для аутентификации

## ⚠️ Troubleshooting

### Ошибка: "DEPLOY_HOST не задан в .env"
- Убедитесь что файл `.env` существует в корне проекта
- Проверьте что переменная `DEPLOY_HOST` заполнена

### Ошибка: "Permission denied (publickey)"
- Убедитесь что SSH ключ настроен правильно
- Укажите путь к ключу в `DEPLOY_SSH_KEY` в `.env`

### Ошибка: ".env.production не найден на сервере"
- Скрипт попытается скопировать локальный `backend/.env.production`
- Если его нет локально, создайте его на сервере вручную:
  ```bash
  ssh $DEPLOY_USER@$DEPLOY_HOST
  cd /opt/convertik
  cp env.production.example .env.production
  nano .env.production
  ```

### Бэкенд не запускается
- Проверьте логи: `docker-compose -f docker-compose.production.yml logs`
- Убедитесь что все переменные в `.env.production` заполнены
- Проверьте что порты не заняты другими сервисами

## 📝 Примеры использования

### Первый деплой на новый сервер:
```bash
# 1. Создайте .env файл
cp .env.example .env
nano .env

# 2. Создайте .env.production для бэкенда
cd backend
cp env.production.example .env.production
nano .env.production

# 3. Задеплойте все
cd ..
./deploy.sh
```

### Обновление только фронтенда после изменений:
```bash
./deploy.sh frontend
```

### Обновление только бэкенда:
```bash
./deploy.sh backend
```

## 🎯 Структура файлов на сервере

После деплоя на сервере будет следующая структура:

```
/opt/convertik/          # Бэкенд
├── app/
├── alembic/
├── docker-compose.production.yml
├── deploy.sh
├── .env.production
└── ...

/opt/www/                # Фронтенд
├── index.html
├── privacy.html
├── terms.html
├── data.html
├── assets/
└── ...
```

---

**Готово! 🎉** Теперь вы можете легко деплоить Convertik одной командой!
