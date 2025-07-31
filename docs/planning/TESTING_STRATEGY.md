# Стратегия тестирования Convertik

## Общие принципы

### Цели тестирования
- Обеспечить качество кода и функциональности
- Предотвратить регрессии
- Ускорить разработку через автоматизацию
- Обеспечить стабильность в production

### Покрытие тестами
- **Backend:** ≥80% покрытие кода
- **iOS:** ≥60% покрытие кода
- **Критические пути:** 100% покрытие

## Уровни тестирования

### 1. Unit тесты

#### Backend (Python/Pytest)
**Цель:** Тестирование отдельных функций и классов

**Что тестировать:**
- Модели данных (валидация, CRUD операции)
- Сервисы (бизнес-логика)
- Утилиты (вспомогательные функции)
- Валидаторы (Pydantic схемы)

**Инструменты:**
- `pytest` - основной фреймворк
- `pytest-asyncio` - для async тестов
- `pytest-mock` - для моков
- `factory-boy` - для создания тестовых данных

**Примеры тестов:**
```python
# test_models.py
def test_rate_model_creation():
    rate = Rate(code="USD", value=0.0112)
    assert rate.code == "USD"
    assert rate.value == 0.0112

# test_services.py
async def test_rates_service_fetch():
    service = RatesService()
    rates = await service.fetch_rates()
    assert len(rates) > 0
    assert "USD" in rates
```

#### iOS (XCTest)
**Цель:** Тестирование отдельных компонентов приложения

**Что тестировать:**
- ViewModels (бизнес-логика)
- Сервисы (сетевые запросы, CoreData)
- Утилиты (конвертация валют, форматирование)
- Extensions (расширения)

**Инструменты:**
- `XCTest` - основной фреймворк
- `ViewInspector` - для тестирования SwiftUI
- `CombineSchedulers` - для тестирования Combine

**Примеры тестов:**
```swift
// ConversionServiceTests.swift
func testCurrencyConversion() {
    let service = ConversionService()
    let result = service.convert(100, from: "USD", to: "EUR")
    XCTAssertGreaterThan(result, 0)
}

// RatesRepositoryTests.swift
func testLocalRatesFetch() {
    let repository = RatesRepository()
    let rates = repository.localRates()
    XCTAssertNotNil(rates)
}
```

### 2. Интеграционные тесты

#### Backend
**Цель:** Тестирование взаимодействия компонентов

**Что тестировать:**
- API эндпоинты с реальной БД
- Интеграция с внешними API
- Работа с Redis кэшем
- Миграции БД

**Инструменты:**
- `pytest` + `httpx` - для API тестов
- `testcontainers` - для Docker контейнеров
- `pytest-docker` - для интеграции с Docker

**Примеры тестов:**
```python
# test_api_integration.py
async def test_rates_endpoint_integration():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/rates")
        assert response.status_code == 200
        data = response.json()
        assert "rates" in data
        assert "updated_at" in data

# test_external_api.py
async def test_external_rates_api():
    service = ExternalRatesService()
    rates = await service.fetch_rates()
    assert "USD" in rates
    assert "EUR" in rates
```

#### iOS
**Цель:** Тестирование взаимодействия слоев приложения

**Что тестировать:**
- Интеграция с backend API
- Работа с CoreData
- Интеграция с AdMob
- StoreKit2 интеграция

**Инструменты:**
- `XCTest` + моки
- `OHHTTPStubs` - для моков сетевых запросов
- `CoreData` in-memory store

**Примеры тестов:**
```swift
// RatesServiceIntegrationTests.swift
func testRatesServiceIntegration() {
    let expectation = XCTestExpectation(description: "Fetch rates")
    let service = RatesService()
    
    service.fetchRates { result in
        switch result {
        case .success(let rates):
            XCTAssertFalse(rates.isEmpty)
        case .failure(let error):
            XCTFail("Failed with error: \(error)")
        }
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
}
```

### 3. UI тесты

#### iOS (XCUITest)
**Цель:** Тестирование пользовательского интерфейса

**Что тестировать:**
- Основные пользовательские сценарии
- Навигация между экранами
- Ввод данных и валидация
- Отображение контента

**Инструменты:**
- `XCUITest` - основной фреймворк
- `XCTestCase` - для организации тестов

**Примеры тестов:**
```swift
// MainViewUITests.swift
func testCurrencyConversionFlow() {
    let app = XCUIApplication()
    app.launch()
    
    // Ввод суммы
    let amountField = app.textFields["amount_field"]
    amountField.tap()
    amountField.typeText("100")
    
    // Проверка результата
    let resultLabel = app.staticTexts["result_label"]
    XCTAssertTrue(resultLabel.exists)
    XCTAssertNotEqual(resultLabel.label, "0.00")
}

func testAddCurrencyFlow() {
    let app = XCUIApplication()
    app.launch()
    
    // Нажатие кнопки добавления
    let addButton = app.buttons["add_currency_button"]
    addButton.tap()
    
    // Поиск валюты
    let searchField = app.searchFields["currency_search"]
    searchField.tap()
    searchField.typeText("EUR")
    
    // Выбор валюты
    let eurCell = app.cells["EUR"]
    eurCell.tap()
    
    // Проверка возврата на главный экран
    XCTAssertTrue(app.navigationBars["Конвертик"].exists)
}
```

### 4. Performance тесты

#### Backend
**Цель:** Обеспечение производительности API

**Что тестировать:**
- Время ответа эндпоинтов
- Пропускная способность
- Использование памяти
- Производительность БД

**Инструменты:**
- `locust` - для нагрузочного тестирования
- `pytest-benchmark` - для бенчмарков
- `memory-profiler` - для профилирования памяти

**Примеры тестов:**
```python
# test_performance.py
def test_rates_endpoint_performance(benchmark):
    async def fetch_rates():
        async with AsyncClient(app=app, base_url="http://test") as ac:
            response = await ac.get("/rates")
            return response.status_code
    
    result = benchmark(fetch_rates)
    assert result == 200

# locustfile.py
class RatesUser(HttpUser):
    @task
    def get_rates(self):
        self.client.get("/rates")
```

#### iOS
**Цель:** Обеспечение производительности приложения

**Что тестировать:**
- Время запуска приложения
- Потребление памяти
- Плавность анимаций
- Энергопотребление

**Инструменты:**
- `XCTest` + `measure` блоки
- Instruments (Xcode)
- `XCTestCase` performance tests

**Примеры тестов:**
```swift
// PerformanceTests.swift
func testAppLaunchPerformance() {
    measure {
        let app = XCUIApplication()
        app.launch()
    }
}

func testCurrencyConversionPerformance() {
    let service = ConversionService()
    measure {
        for _ in 0..<1000 {
            _ = service.convert(100, from: "USD", to: "EUR")
        }
    }
}
```

### 5. End-to-End тесты

**Цель:** Тестирование полного пользовательского сценария

**Что тестировать:**
- Полный цикл конвертации валют
- Процесс покупки подписки
- Работа в офлайн режиме
- Синхронизация данных

**Инструменты:**
- `XCUITest` для iOS
- `pytest` + `selenium` для web интерфейсов
- Реальные устройства и симуляторы

## Стратегия моков

### Backend моки
```python
# conftest.py
@pytest.fixture
def mock_external_api(monkeypatch):
    def mock_fetch_rates():
        return {
            "USD": 0.0112,
            "EUR": 0.0101,
            "GBP": 0.0087
        }
    
    monkeypatch.setattr(ExternalRatesService, "fetch_rates", mock_fetch_rates)

@pytest.fixture
def mock_redis(monkeypatch):
    class MockRedis:
        def __init__(self):
            self.data = {}
        
        async def get(self, key):
            return self.data.get(key)
        
        async def set(self, key, value, ex=None):
            self.data[key] = value
    
    return MockRedis()
```

### iOS моки
```swift
// MockRatesService.swift
class MockRatesService: RatesServiceProtocol {
    var shouldFail = false
    var mockRates: [String: Double] = ["USD": 0.0112, "EUR": 0.0101]
    
    func fetchRates() async throws -> [String: Double] {
        if shouldFail {
            throw NetworkError.serverError
        }
        return mockRates
    }
}

// TestRatesViewModel.swift
class TestRatesViewModel: ObservableObject {
    @Published var rates: [String: Double] = [:]
    private let service: RatesServiceProtocol
    
    init(service: RatesServiceProtocol = MockRatesService()) {
        self.service = service
    }
}
```

## CI/CD интеграция

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      - name: Run tests
        run: |
          pytest --cov=app --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  ios-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'
      - name: Run tests
        run: |
          xcodebuild test -scheme Convertik -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Coverage отчеты
- **Backend:** HTML отчеты в artifacts
- **iOS:** Xcode coverage reports
- **Интеграция:** Codecov для отслеживания трендов

## Тестовые данные

### Backend
```python
# factories.py
import factory
from app.models import Rate, UsageEvent

class RateFactory(factory.Factory):
    class Meta:
        model = Rate
    
    code = factory.Sequence(lambda n: f"USD{n}")
    value = factory.Faker('pydecimal', left_digits=1, right_digits=6)
    updated_at = factory.Faker('date_time')

class UsageEventFactory(factory.Factory):
    class Meta:
        model = UsageEvent
    
    device_id = factory.Faker('uuid4')
    event_name = factory.Iterator(['app_open', 'conversion', 'ad_impression'])
    payload = factory.Dict({})
    created_at = factory.Faker('date_time')
```

### iOS
```swift
// TestData.swift
struct TestData {
    static let sampleRates: [String: Double] = [
        "USD": 0.0112,
        "EUR": 0.0101,
        "GBP": 0.0087,
        "JPY": 1.2345
    ]
    
    static let sampleCurrency = Currency(
        code: "USD",
        name: "US Dollar",
        symbol: "$"
    )
}
```

## Мониторинг качества

### Метрики качества
- **Coverage:** Процент покрытия кода тестами
- **Test Duration:** Время выполнения тестов
- **Flakiness:** Процент нестабильных тестов
- **Bug Detection:** Количество багов, найденных тестами

### Алерты
- Coverage ниже целевого
- Тесты не проходят
- Performance деградация
- Новые баги в production

## Рекомендации

### Для разработчиков
1. Писать тесты параллельно с кодом
2. Использовать TDD для критических компонентов
3. Поддерживать актуальность тестов
4. Регулярно рефакторить тесты

### Для команды
1. Установить минимальные требования к coverage
2. Автоматизировать запуск тестов в CI/CD
3. Регулярно анализировать метрики качества
4. Проводить code review тестов

### Для проекта
1. Начать с unit тестов для критических компонентов
2. Постепенно добавлять интеграционные тесты
3. Автоматизировать UI тесты для основных сценариев
4. Настроить performance мониторинг 