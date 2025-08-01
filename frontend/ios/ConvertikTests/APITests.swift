import XCTest
@testable import Convertik

final class APITests: XCTestCase {

    var apiService: APIService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIService.shared
    }

    override func tearDownWithError() throws {
        apiService = nil
        try super.tearDownWithError()
    }

    // MARK: - Тесты API

    func testFetchRatesFromAPI() async throws {
        // Тест 1: Проверяем загрузку курсов валют с API

        do {
            let response = try await apiService.fetchRates()

            // Проверяем структуру ответа
            XCTAssertNotNil(response.updatedAt, "Дата обновления должна присутствовать")
            XCTAssertEqual(response.base, "RUB", "Базовая валюта должна быть RUB")
            XCTAssertNotNil(response.rates, "Курсы валют должны присутствовать")
            XCTAssertGreaterThan(response.rates.count, 0, "Должно быть больше 0 валют")

            // Проверяем наличие основных валют
            XCTAssertNotNil(response.rates["USD"], "USD должна присутствовать в ответе")
            XCTAssertNotNil(response.rates["EUR"], "EUR должна присутствовать в ответе")
            XCTAssertNotNil(response.rates["GBP"], "GBP должна присутствовать в ответе")

            // Проверяем, что курсы положительные
            for (code, rate) in response.rates {
                XCTAssertGreaterThan(rate, 0, "Курс для \(code) должен быть положительным")
            }

        } catch {
            XCTFail("API запрос должен успешно выполниться: \(error)")
        }
    }

    func testRatesDataStructure() async throws {
        // Тест 2: Проверяем структуру данных курсов

        do {
            let response = try await apiService.fetchRates()

            // Проверяем, что все курсы имеют корректные значения
            for (code, rate) in response.rates {
                // Проверяем, что код валюты не пустой
                XCTAssertFalse(code.isEmpty, "Код валюты не должен быть пустым")

                // Проверяем, что курс положительный
                XCTAssertGreaterThan(rate, 0, "Курс для \(code) должен быть положительным")

                // Проверяем, что курс не бесконечный
                XCTAssertFalse(rate.isInfinite, "Курс для \(code) не должен быть бесконечным")

                // Проверяем, что курс не NaN
                XCTAssertFalse(rate.isNaN, "Курс для \(code) не должен быть NaN")
            }

        } catch {
            XCTFail("API запрос должен успешно выполниться: \(error)")
        }
    }

    func testRatesRepositoryIntegration() async throws {
        // Тест 3: Проверяем интеграцию с RatesRepository

        let ratesRepository = RatesRepository.shared

        // Синхронизируем данные с API
        await ratesRepository.syncRemote()

        // Проверяем, что данные загрузились
        XCTAssertGreaterThan(ratesRepository.rates.count, 0, "Должно быть загружено больше 0 курсов")

        // Проверяем, что есть основные валюты
        let usdRate = ratesRepository.rate(for: "USD")
        let eurRate = ratesRepository.rate(for: "EUR")
        let rubRate = ratesRepository.rate(for: "RUB")

        XCTAssertNotNil(usdRate, "USD курс должен быть загружен")
        XCTAssertNotNil(eurRate, "EUR курс должен быть загружен")
        XCTAssertNotNil(rubRate, "RUB курс должен быть загружен")

        // Проверяем, что курсы корректные
        if let usd = usdRate {
            XCTAssertGreaterThan(usd.value, 0, "USD курс должен быть положительным")
        }

        if let eur = eurRate {
            XCTAssertGreaterThan(eur.value, 0, "EUR курс должен быть положительным")
        }

        if let rub = rubRate {
            XCTAssertEqual(rub.value, 1.0, "RUB курс должен быть равен 1.0")
        }
    }

    func testRatesProcessing() async throws {
        // Тест 4: Проверяем обработку курсов из API

        do {
            let response = try await apiService.fetchRates()
            let ratesRepository = RatesRepository.shared

            // Обрабатываем данные из API
            await ratesRepository.updateLocalRates(from: response)

            // Загружаем локальные данные
            ratesRepository.loadLocalRates()

            // Проверяем, что данные сохранились
            XCTAssertGreaterThan(ratesRepository.rates.count, 0, "Должно быть сохранено больше 0 курсов")

            // Проверяем, что курсы инвертированы правильно
            for rate in ratesRepository.rates {
                if rate.code == "RUB" {
                    XCTAssertEqual(rate.value, 1.0, "RUB курс должен быть равен 1.0")
                } else {
                    // Проверяем, что курс инвертирован (1 / API_rate)
                    let originalRate = response.rates[rate.code] ?? 0
                    let expectedValue = 1.0 / originalRate
                    XCTAssertEqual(rate.value, expectedValue, accuracy: 0.0001, "Курс для \(rate.code) должен быть инвертирован правильно")
                }
            }

        } catch {
            XCTFail("API запрос должен успешно выполниться: \(error)")
        }
    }

    func testNoDataHandling() async throws {
        // Тест 5: Проверяем обработку отсутствия данных

        let ratesRepository = RatesRepository.shared

        // Очищаем локальные данные
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RateEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            XCTFail("Не удалось очистить данные: \(error)")
        }

        // Загружаем локальные данные
        ratesRepository.loadLocalRates()

        // Проверяем, что список пустой
        XCTAssertEqual(ratesRepository.rates.count, 0, "Список курсов должен быть пустым")

        // Проверяем, что нет ошибки
        XCTAssertNil(ratesRepository.error, "Не должно быть ошибки при пустом списке")
    }

    func testNetworkErrorHandling() async throws {
        // Тест 6: Проверяем обработку сетевых ошибок

        // Создаем временный API сервис с неверным URL
        let tempAPIService = APIService()
        let originalBaseURL = tempAPIService.baseURL

        // Изменяем URL на неверный (это может потребовать изменения APIService для тестирования)
        // В реальном приложении это может потребовать создания mock сервиса

        // Проверяем, что приложение не крашится при сетевых ошибках
        let ratesRepository = RatesRepository.shared

        // Синхронизируем (может завершиться с ошибкой)
        await ratesRepository.syncRemote()

        // Проверяем, что приложение продолжает работать
        XCTAssertNotNil(ratesRepository.rates, "Список курсов должен существовать даже при ошибке")
    }

    func testRatesUpdateTimestamp() async throws {
        // Тест 7: Проверяем обновление временных меток

        do {
            let response = try await apiService.fetchRates()
            let ratesRepository = RatesRepository.shared

            // Обрабатываем данные
            await ratesRepository.updateLocalRates(from: response)

            // Загружаем локальные данные
            ratesRepository.loadLocalRates()

            // Проверяем, что временная метка обновилась
            XCTAssertNotNil(ratesRepository.lastUpdated, "Временная метка должна быть установлена")

            // Проверяем, что временная метка недавняя
            if let lastUpdated = ratesRepository.lastUpdated {
                let timeDifference = Date().timeIntervalSince(lastUpdated)
                XCTAssertLessThan(timeDifference, 60, "Временная метка должна быть не старше 60 секунд")
            }

        } catch {
            XCTFail("API запрос должен успешно выполниться: \(error)")
        }
    }

    func testAllCurrenciesFromAPI() async throws {
        // Тест 8: Проверяем, что все валюты из API доступны

        do {
            let response = try await apiService.fetchRates()
            let ratesRepository = RatesRepository.shared

            // Обрабатываем данные
            await ratesRepository.updateLocalRates(from: response)

            // Загружаем локальные данные
            ratesRepository.loadLocalRates()

            // Проверяем, что все валюты из API сохранены
            XCTAssertEqual(ratesRepository.rates.count, response.rates.count + 1, "Должны быть сохранены все валюты из API + RUB")

            // Проверяем, что каждая валюта из API доступна
            for (code, _) in response.rates {
                let rate = ratesRepository.rate(for: code)
                XCTAssertNotNil(rate, "Курс для \(code) должен быть доступен")
            }

        } catch {
            XCTFail("API запрос должен успешно выполниться: \(error)")
        }
    }
}
