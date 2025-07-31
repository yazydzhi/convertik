# Backend Tasks - Детальный план

## Epic 1: Базовая структура проекта

### Task 1.1: Инициализация проекта
**Описание:** Создание базовой структуры FastAPI приложения
**Подзадачи:**
- [ ] Создать структуру каталогов
- [ ] Настроить requirements.txt
- [ ] Создать config.py с Pydantic Settings
- [ ] Настроить main.py с базовым FastAPI приложением
- [ ] Добавить базовые middleware (CORS, logging)

**Критерии готовности:**
- [ ] Приложение запускается локально
- [ ] Swagger UI доступен по /docs
- [ ] Health check endpoint работает
- [ ] Логирование настроено

**Тесты:**
- [ ] Test health endpoint
- [ ] Test app startup
- [ ] Test config loading

### Task 1.2: Настройка базы данных
**Описание:** Настройка PostgreSQL и SQLAlchemy
**Подзадачи:**
- [ ] Создать db.py с async session
- [ ] Настроить Alembic для миграций
- [ ] Создать базовые модели (Rate, UsageEvent, IapReceipt, PushToken)
- [ ] Настроить docker-compose.yml с PostgreSQL и Redis

**Критерии готовности:**
- [ ] Подключение к БД работает
- [ ] Миграции создаются и применяются
- [ ] Модели валидируются
- [ ] Docker контейнеры запускаются

**Тесты:**
- [ ] Test database connection
- [ ] Test model creation
- [ ] Test migrations up/down

## Epic 2: API эндпоинты

### Task 2.1: Эндпоинт /rates
**Описание:** Реализация получения курсов валют
**Подзадачи:**
- [ ] Создать Rate модель и схему
- [ ] Реализовать GET /rates endpoint
- [ ] Добавить кэширование в Redis
- [ ] Создать мок внешнего API для разработки
- [ ] Добавить валидацию ответа

**Критерии готовности:**
- [ ] Endpoint возвращает курсы в нужном формате
- [ ] Кэширование работает (TTL 1 час)
- [ ] Обработка ошибок настроена
- [ ] Rate limiting настроен (100 req/min)

**Тесты:**
- [ ] Test successful response format
- [ ] Test cache hit/miss scenarios
- [ ] Test rate limiting
- [ ] Test error handling

### Task 2.2: Эндпоинт /stats
**Описание:** Прием аналитических событий
**Подзадачи:**
- [ ] Создать UsageEvent модель
- [ ] Реализовать POST /stats endpoint
- [ ] Добавить bulk insert для производительности
- [ ] Валидация схемы событий
- [ ] Обработка batch до 50 событий

**Критерии готовности:**
- [ ] Принимает массив событий
- [ ] Валидирует каждое событие
- [ ] Сохраняет в БД bulk операцией
- [ ] Возвращает количество принятых событий

**Тесты:**
- [ ] Test single event
- [ ] Test batch of 50 events
- [ ] Test invalid event rejection
- [ ] Test database performance

### Task 2.3: Эндпоинт /iap/verify
**Описание:** Валидация StoreKit2 квитанций
**Подзадачи:**
- [ ] Создать IapReceipt модель
- [ ] Реализовать POST /iap/verify endpoint
- [ ] Интеграция с App Store Server API
- [ ] Обработка sandbox/production режимов
- [ ] Сохранение результатов валидации

**Критерии готовности:**
- [ ] Валидирует квитанции через Apple API
- [ ] Возвращает статус premium
- [ ] Сохраняет результат в БД
- [ ] Обрабатывает ошибки Apple API

**Тесты:**
- [ ] Test valid receipt
- [ ] Test invalid receipt
- [ ] Test expired subscription
- [ ] Test Apple API errors

### Task 2.4: Push уведомления
**Описание:** Регистрация токенов и отправка уведомлений
**Подзадачи:**
- [ ] Создать PushToken модель
- [ ] Реализовать POST /push/register
- [ ] Реализовать POST /admin/push/send
- [ ] Интеграция с APNs
- [ ] Сегментация пользователей

**Критерии готовности:**
- [ ] Регистрирует push токены
- [ ] Отправляет уведомления через APNs
- [ ] Поддерживает сегментацию
- [ ] Обрабатывает ошибки доставки

**Тесты:**
- [ ] Test token registration
- [ ] Test push sending
- [ ] Test segmentation
- [ ] Test APNs errors

## Epic 3: Фоновые задачи

### Task 3.1: Обновление курсов валют
**Описание:** Cron задача для обновления курсов
**Подзадачи:**
- [ ] Настроить APScheduler
- [ ] Реализовать update_rates() функцию
- [ ] Интеграция с внешним API
- [ ] Обработка ошибок и retry логика
- [ ] Логирование результатов

**Критерии готовности:**
- [ ] Запускается каждые 6 часов
- [ ] Обновляет курсы в БД
- [ ] Обрабатывает ошибки API
- [ ] Логирует результаты

**Тесты:**
- [ ] Test scheduler execution
- [ ] Test API integration
- [ ] Test error handling
- [ ] Test database updates

## Epic 4: Безопасность и производительность

### Task 4.1: Rate limiting и безопасность
**Описание:** Настройка защиты от злоупотреблений
**Подзадачи:**
- [ ] Реализовать rate limiting по IP
- [ ] Добавить rate limiting по device_id
- [ ] Валидация User-Agent
- [ ] Защита админ эндпоинтов
- [ ] Настройка CORS

**Критерии готовности:**
- [ ] Rate limiting работает
- [ ] Админ эндпоинты защищены
- [ ] Валидация входных данных
- [ ] Логирование подозрительной активности

**Тесты:**
- [ ] Test rate limiting
- [ ] Test admin authentication
- [ ] Test input validation
- [ ] Test security headers

### Task 4.2: Мониторинг и логирование
**Описание:** Настройка observability
**Подзадачи:**
- [ ] Настроить structlog
- [ ] Добавить Prometheus метрики
- [ ] Создать health check endpoint
- [ ] Настроить алерты
- [ ] Логирование в JSON формате

**Критерии готовности:**
- [ ] Структурированное логирование
- [ ] Метрики собираются
- [ ] Health check работает
- [ ] Алерты настроены

**Тесты:**
- [ ] Test logging format
- [ ] Test metrics collection
- [ ] Test health check
- [ ] Test alert triggers

## Epic 5: Тестирование

### Task 5.1: Unit тесты
**Описание:** Покрытие кода unit тестами
**Подзадачи:**
- [ ] Настроить pytest
- [ ] Тесты для моделей
- [ ] Тесты для сервисов
- [ ] Тесты для эндпоинтов
- [ ] Моки для внешних API

**Критерии готовности:**
- [ ] Покрытие кода ≥80%
- [ ] Все тесты проходят
- [ ] Моки настроены
- [ ] CI интеграция

**Тесты:**
- [ ] Test coverage report
- [ ] Test execution time
- [ ] Test reliability
- [ ] Test maintainability

### Task 5.2: Интеграционные тесты
**Описание:** Тестирование интеграции компонентов
**Подзадачи:**
- [ ] Тесты с реальной БД
- [ ] Тесты API эндпоинтов
- [ ] Тесты внешних интеграций
- [ ] Performance тесты

**Критерии готовности:**
- [ ] Все интеграционные тесты проходят
- [ ] Performance требования выполнены
- [ ] Внешние интеграции протестированы

## Epic 6: Деплой

### Task 6.1: Docker и CI/CD
**Описание:** Настройка деплоя
**Подзадачи:**
- [ ] Создать Dockerfile
- [ ] Настроить docker-compose
- [ ] GitHub Actions pipeline
- [ ] Автоматические тесты
- [ ] Автоматический деплой

**Критерии готовности:**
- [ ] Docker образ собирается
- [ ] CI/CD pipeline работает
- [ ] Автоматические тесты
- [ ] Деплой в staging

**Тесты:**
- [ ] Test Docker build
- [ ] Test CI/CD pipeline
- [ ] Test deployment
- [ ] Test rollback 