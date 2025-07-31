# GitHub Issues - Структура задач

## Labels (Метки)

### Типы задач
- `epic` - Большая задача, состоящая из нескольких issues
- `feature` - Новая функциональность
- `bug` - Исправление ошибки
- `enhancement` - Улучшение существующей функциональности
- `documentation` - Документация
- `testing` - Тестирование
- `refactoring` - Рефакторинг кода

### Приоритеты
- `priority: critical` - Критически важно
- `priority: high` - Высокий приоритет
- `priority: medium` - Средний приоритет
- `priority: low` - Низкий приоритет

### Компоненты
- `backend` - Серверная часть
- `ios` - iOS приложение
- `api` - API эндпоинты
- `database` - База данных
- `ui/ux` - Пользовательский интерфейс
- `monetization` - Монетизация
- `analytics` - Аналитика
- `security` - Безопасность

### Статусы
- `status: ready` - Готово к разработке
- `status: in-progress` - В разработке
- `status: review` - На проверке
- `status: testing` - На тестировании
- `status: done` - Завершено

## Epic Issues

### Epic 1: Backend Foundation
**Issue #1** - Backend Foundation Setup
- **Labels:** `epic`, `backend`, `priority: high`
- **Description:** Создание базовой структуры FastAPI приложения
- **Subtasks:**
  - [ ] #2 - Project structure setup
  - [ ] #3 - Database configuration
  - [ ] #4 - Basic API endpoints
  - [ ] #5 - Testing framework

### Epic 2: iOS Foundation
**Issue #6** - iOS Foundation Setup
- **Labels:** `epic`, `ios`, `priority: high`
- **Description:** Создание базовой структуры iOS приложения
- **Subtasks:**
  - [ ] #7 - Xcode project setup
  - [ ] #8 - CoreData configuration
  - [ ] #9 - Basic UI screens
  - [ ] #10 - Network layer

### Epic 3: API Integration
**Issue #11** - API Integration
- **Labels:** `epic`, `api`, `priority: high`
- **Description:** Интеграция iOS с backend API
- **Subtasks:**
  - [ ] #12 - Rates API integration
  - [ ] #13 - Analytics API integration
  - [ ] #14 - Error handling
  - [ ] #15 - Offline mode

### Epic 4: Monetization
**Issue #16** - Monetization Implementation
- **Labels:** `epic`, `monetization`, `priority: medium`
- **Description:** Реализация монетизации (AdMob + StoreKit2)
- **Subtasks:**
  - [ ] #17 - AdMob integration
  - [ ] #18 - StoreKit2 setup
  - [ ] #19 - IAP validation
  - [ ] #20 - Premium features

### Epic 5: Analytics
**Issue #21** - Analytics Implementation
- **Labels:** `epic`, `analytics`, `priority: medium`
- **Description:** Реализация аналитики и метрик
- **Subtasks:**
  - [ ] #22 - Event tracking
  - [ ] #23 - Analytics dashboard
  - [ ] #24 - Performance monitoring
  - [ ] #25 - User behavior analysis

### Epic 6: Push Notifications
**Issue #26** - Push Notifications
- **Labels:** `epic`, `ios`, `backend`, `priority: low`
- **Description:** Реализация push уведомлений
- **Subtasks:**
  - [ ] #27 - APNs setup
  - [ ] #28 - Token registration
  - [ ] #29 - Admin panel
  - [ ] #30 - Campaign management

## Feature Issues

### Backend Features

**Issue #2** - Project Structure Setup
- **Labels:** `feature`, `backend`, `priority: high`, `status: ready`
- **Description:** Создание базовой структуры FastAPI проекта
- **Acceptance Criteria:**
  - [ ] FastAPI приложение создано
  - [ ] Структура каталогов настроена
  - [ ] Requirements.txt создан
  - [ ] Docker контейнер настроен
  - [ ] Health check endpoint работает
- **Definition of Done:**
  - [ ] Код написан и протестирован
  - [ ] Документация обновлена
  - [ ] CI/CD pipeline настроен
  - [ ] Code review пройден

**Issue #3** - Database Configuration
- **Labels:** `feature`, `backend`, `database`, `priority: high`, `status: ready`
- **Description:** Настройка PostgreSQL и SQLAlchemy
- **Acceptance Criteria:**
  - [ ] PostgreSQL подключение настроено
  - [ ] SQLAlchemy модели созданы
  - [ ] Alembic миграции настроены
  - [ ] Docker Compose с БД работает
- **Definition of Done:**
  - [ ] Модели протестированы
  - [ ] Миграции работают
  - [ ] Производительность оптимизирована

**Issue #4** - Basic API Endpoints
- **Labels:** `feature`, `backend`, `api`, `priority: high`, `status: ready`
- **Description:** Реализация базовых API эндпоинтов
- **Acceptance Criteria:**
  - [ ] GET /rates endpoint работает
  - [ ] POST /stats endpoint работает
  - [ ] GET /health endpoint работает
  - [ ] Rate limiting настроен
- **Definition of Done:**
  - [ ] Эндпоинты протестированы
  - [ ] Документация API создана
  - [ ] Error handling настроен

### iOS Features

**Issue #7** - Xcode Project Setup
- **Labels:** `feature`, `ios`, `priority: high`, `status: ready`
- **Description:** Создание Xcode проекта с SwiftUI
- **Acceptance Criteria:**
  - [ ] Xcode проект создан
  - [ ] SwiftUI настроен
  - [ ] Bundle ID настроен
  - [ ] SwiftLint настроен
- **Definition of Done:**
  - [ ] Проект собирается без ошибок
  - [ ] Базовые зависимости добавлены
  - [ ] Структура каталогов создана

**Issue #8** - CoreData Configuration
- **Labels:** `feature`, `ios`, `database`, `priority: high`, `status: ready`
- **Description:** Настройка CoreData для кэширования курсов
- **Acceptance Criteria:**
  - [ ] CoreData модель создана
  - [ ] RateEntity определен
  - [ ] CRUD операции работают
  - [ ] Миграции настроены
- **Definition of Done:**
  - [ ] CoreData протестирован
  - [ ] Производительность оптимизирована
  - [ ] Ошибки обрабатываются

**Issue #9** - Basic UI Screens
- **Labels:** `feature`, `ios`, `ui/ux`, `priority: high`, `status: ready`
- **Description:** Создание основных экранов приложения
- **Acceptance Criteria:**
  - [ ] MainListView создан
  - [ ] AddCurrencyView создан
  - [ ] SettingsView создан
  - [ ] Навигация работает
- **Definition of Done:**
  - [ ] UI протестирован
  - [ ] Адаптивность проверена
  - [ ] Accessibility настроен

## Bug Issues

**Issue #31** - Fix API Response Format
- **Labels:** `bug`, `api`, `priority: critical`, `status: ready`
- **Description:** Исправить несоответствие формата ответа API
- **Steps to Reproduce:**
  1. Отправить GET запрос на /rates
  2. Проверить формат ответа
- **Expected Behavior:** Ответ содержит поле "base"
- **Actual Behavior:** Поле "base" отсутствует
- **Acceptance Criteria:**
  - [ ] Формат ответа исправлен
  - [ ] Тесты обновлены
  - [ ] Документация обновлена

## Enhancement Issues

**Issue #32** - Improve Error Handling
- **Labels:** `enhancement`, `backend`, `ios`, `priority: medium`, `status: ready`
- **Description:** Улучшить обработку ошибок в приложении
- **Acceptance Criteria:**
  - [ ] Структурированные ошибки
  - [ ] Пользовательские сообщения
  - [ ] Логирование ошибок
  - [ ] Retry логика
- **Definition of Done:**
  - [ ] Ошибки протестированы
  - [ ] UX улучшен
  - [ ] Мониторинг настроен

## Testing Issues

**Issue #33** - Unit Test Coverage
- **Labels:** `testing`, `backend`, `ios`, `priority: high`, `status: ready`
- **Description:** Достичь покрытия кода тестами ≥80% для backend и ≥60% для iOS
- **Acceptance Criteria:**
  - [ ] Backend покрытие ≥80%
  - [ ] iOS покрытие ≥60%
  - [ ] Все тесты проходят
  - [ ] CI интеграция настроена
- **Definition of Done:**
  - [ ] Coverage report создан
  - [ ] Тесты стабильны
  - [ ] Регрессии не найдены

## Documentation Issues

**Issue #34** - API Documentation
- **Labels:** `documentation`, `api`, `priority: medium`, `status: ready`
- **Description:** Создать полную документацию API
- **Acceptance Criteria:**
  - [ ] OpenAPI схема создана
  - [ ] Примеры запросов/ответов
  - [ ] Error codes описаны
  - [ ] Swagger UI настроен
- **Definition of Done:**
  - [ ] Документация проверена
  - [ ] Примеры работают
  - [ ] Обновлена в репозитории

## Milestones

### Milestone 1: MVP (2-3 недели)
- Epic 1: Backend Foundation
- Epic 2: iOS Foundation
- Epic 3: API Integration
- **Due Date:** [Дата]

### Milestone 2: Monetization (1-2 недели)
- Epic 4: Monetization Implementation
- **Due Date:** [Дата]

### Milestone 3: Analytics & Polish (1-2 недели)
- Epic 5: Analytics Implementation
- Epic 6: Push Notifications
- **Due Date:** [Дата]

### Milestone 4: Production Ready (1 неделя)
- Testing & Bug fixes
- Performance optimization
- App Store preparation
- **Due Date:** [Дата]

## Issue Templates

### Bug Report Template
```markdown
## Bug Description
[Краткое описание бага]

## Steps to Reproduce
1. [Шаг 1]
2. [Шаг 2]
3. [Шаг 3]

## Expected Behavior
[Что должно происходить]

## Actual Behavior
[Что происходит на самом деле]

## Environment
- iOS Version: [версия]
- Device: [устройство]
- App Version: [версия приложения]

## Additional Information
[Дополнительная информация, скриншоты, логи]
```

### Feature Request Template
```markdown
## Feature Description
[Описание новой функциональности]

## Problem Statement
[Проблема, которую решает эта функция]

## Proposed Solution
[Предлагаемое решение]

## Acceptance Criteria
- [ ] Критерий 1
- [ ] Критерий 2
- [ ] Критерий 3

## Additional Information
[Дополнительная информация, примеры, ссылки]
```

### Task Template
```markdown
## Task Description
[Описание задачи]

## Subtasks
- [ ] Подзадача 1
- [ ] Подзадача 2
- [ ] Подзадача 3

## Acceptance Criteria
- [ ] Критерий 1
- [ ] Критерий 2
- [ ] Критерий 3

## Definition of Done
- [ ] Код написан и протестирован
- [ ] Документация обновлена
- [ ] Code review пройден
- [ ] Тесты проходят
``` 