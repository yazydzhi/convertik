# Convertik Backend

FastAPI приложение для конвертера валют Convertik.

## Быстрый старт

### Локальная разработка

1. **Клонируйте репозиторий и перейдите в папку backend:**
```bash
cd backend
```

2. **Создайте виртуальное окружение:**
```bash
python3 -m venv venv
source venv/bin/activate  # На Windows: venv\Scripts\activate
```

3. **Установите зависимости:**
```bash
pip install -r requirements.txt
```

4. **Скопируйте файл с переменными окружения:**
```bash
cp env.example .env
```

5. **Отредактируйте .env файл** (укажите свои значения)

6. **Запустите приложение:**
```bash
uvicorn app.main:app --reload
```

Приложение будет доступно по адресу: http://localhost:8000
Документация API: http://localhost:8000/docs

### Docker

1. **Запустите с помощью Docker Compose:**
```bash
docker-compose up --build
```

2. **Или соберите и запустите только API:**
```bash
docker build -t convertik-api .
docker run -p 8000:8000 convertik-api
```

## Структура проекта

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Основное приложение FastAPI
│   ├── config.py            # Конфигурация
│   ├── models/              # SQLAlchemy модели
│   ├── routes/              # API роуты
│   ├── services/            # Бизнес-логика
│   ├── tasks/               # Фоновые задачи
│   └── utils/               # Утилиты
├── alembic/                 # Миграции БД
├── requirements.txt         # Python зависимости
├── docker-compose.yml       # Docker Compose
├── Dockerfile              # Docker образ
└── env.example             # Пример переменных окружения
```

## API Endpoints

- `GET /` - Информация о приложении
- `GET /health` - Health check
- `GET /docs` - Swagger UI документация
- `GET /redoc` - ReDoc документация

## Переменные окружения

Скопируйте `env.example` в `.env` и настройте:

- `DATABASE_URL` - URL подключения к PostgreSQL
- `REDIS_URL` - URL подключения к Redis
- `RATES_API_KEY` - Ключ для API курсов валют
- `ADMIN_TOKEN` - Токен для админ эндпоинтов

## Разработка

### Запуск тестов
```bash
pytest
```

### Линтинг
```bash
ruff check .
```

### Форматирование кода
```bash
black .
ruff format .
```

## Деплой

Приложение готово к деплою в Docker контейнерах или на платформах типа:
- Heroku
- DigitalOcean App Platform
- Google Cloud Run
- AWS ECS 