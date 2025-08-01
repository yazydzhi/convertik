import XCTest
@testable import Convertik

final class ConvertikTests: XCTestCase {

    var ratesRepository: RatesRepository!
    var settingsService: SettingsService!
    var conversionService: ConversionService!
    var mainListViewModel: MainListViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Создаем новые экземпляры для каждого теста
        ratesRepository = RatesRepository.shared
        settingsService = SettingsService.shared
        conversionService = ConversionService.shared
        mainListViewModel = MainListViewModel()

        // Очищаем данные перед каждым тестом
        clearTestData()
    }

    override func tearDownWithError() throws {
        clearTestData()
        try super.tearDownWithError()
    }

    private func clearTestData() {
        // Очищаем Core Data
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RateEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to clear test data: \(error)")
        }

        // Сбрасываем настройки
        UserDefaults.standard.removeObject(forKey: "userCurrencies")
        UserDefaults.standard.removeObject(forKey: "isPremium")
    }

    // MARK: - Тесты курсов валют

    func testCurrencyRatesDisplayCorrectly() throws {
        // Тест 1: Проверяем, что курсы отображаются правильно
        let testRates = [
            Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date()),
            Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date()),
            Rate(code: "RUB", name: "Российский рубль", value: 1.0, updatedAt: Date())
        ]

        // Сохраняем тестовые курсы
        saveTestRates(testRates)

        // Проверяем отображение курсов
        let usdRate = conversionService.formatRate(testRates[0])
        let eurRate = conversionService.formatRate(testRates[1])

        XCTAssertEqual(usdRate, "90.91", "USD курс должен отображаться как 90.91")
        XCTAssertEqual(eurRate, "100.00", "EUR курс должен отображаться как 100.00")
    }

    func testCurrencyConversionCalculations() throws {
        // Тест 2: Проверяем правильность расчетов конвертации
        let usdRate = Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date())
        let eurRate = Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date())
        let rubRate = Rate(code: "RUB", name: "Российский рубль", value: 1.0, updatedAt: Date())

        // Тестируем конвертацию 100 USD в EUR
        let usdToEur = conversionService.convert(100, from: usdRate, to: eurRate)
        let expectedUsdToEur = (100 * 100.00) / 90.91 // ≈ 110.00
        XCTAssertEqual(usdToEur, expectedUsdToEur, accuracy: 0.01, "100 USD должно конвертироваться в ~110 EUR")

        // Тестируем конвертацию 100 EUR в USD
        let eurToUsd = conversionService.convert(100, from: eurRate, to: usdRate)
        let expectedEurToUsd = (100 * 90.91) / 100.00 // ≈ 90.91
        XCTAssertEqual(eurToUsd, expectedEurToUsd, accuracy: 0.01, "100 EUR должно конвертироваться в ~90.91 USD")
    }

    // MARK: - Тесты добавления валют

    func testCurrencyAdditionAndDisplay() throws {
        // Тест 3: Проверяем, что валюты корректно добавляются и отображаются
        let testRates = [
            Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date()),
            Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date()),
            Rate(code: "GBP", name: "Фунт стерлингов", value: 114.94, updatedAt: Date()),
            Rate(code: "CNY", name: "Китайский юань", value: 12.50, updatedAt: Date())
        ]

        saveTestRates(testRates)

        // Добавляем валюты в настройки
        settingsService.userCurrencies = ["USD", "EUR", "GBP"]

        // Обновляем ViewModel
        mainListViewModel.updateDisplayedCurrencies()

        // Проверяем, что отображаются только выбранные валюты
        let displayedCurrencies = mainListViewModel.displayedCurrencies
        XCTAssertEqual(displayedCurrencies.count, 3, "Должно отображаться 3 валюты")

        let currencyCodes = displayedCurrencies.map { $0.rate.code }
        XCTAssertTrue(currencyCodes.contains("USD"), "USD должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("EUR"), "EUR должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("GBP"), "GBP должна быть в списке")
        XCTAssertFalse(currencyCodes.contains("CNY"), "CNY не должна быть в списке")
    }

    func testAllCurrenciesFromAPI() throws {
        // Тест 4: Проверяем, что отображаются все валюты из API
        let apiRates = [
            Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date()),
            Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date()),
            Rate(code: "GBP", name: "Фунт стерлингов", value: 114.94, updatedAt: Date()),
            Rate(code: "CNY", name: "Китайский юань", value: 12.50, updatedAt: Date()),
            Rate(code: "JPY", name: "Японская иена", value: 0.58, updatedAt: Date()),
            Rate(code: "CHF", name: "Швейцарский франк", value: 102.04, updatedAt: Date())
        ]

        saveTestRates(apiRates)

        // Добавляем все валюты в настройки
        settingsService.userCurrencies = ["USD", "EUR", "GBP", "CNY", "JPY", "CHF"]

        // Обновляем ViewModel
        mainListViewModel.updateDisplayedCurrencies()

        // Проверяем, что отображаются все валюты
        let displayedCurrencies = mainListViewModel.displayedCurrencies
        XCTAssertEqual(displayedCurrencies.count, 6, "Должно отображаться 6 валют")

        let currencyCodes = displayedCurrencies.map { $0.rate.code }
        XCTAssertTrue(currencyCodes.contains("USD"), "USD должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("EUR"), "EUR должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("GBP"), "GBP должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("CNY"), "CNY должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("JPY"), "JPY должна быть в списке")
        XCTAssertTrue(currencyCodes.contains("CHF"), "CHF должна быть в списке")
    }

    // MARK: - Тесты пересчета валют

    func testCurrencyRecalculation() throws {
        // Тест 5: Проверяем автоматический пересчет валют
        let testRates = [
            Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date()),
            Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date()),
            Rate(code: "RUB", name: "Российский рубль", value: 1.0, updatedAt: Date())
        ]

        saveTestRates(testRates)
        settingsService.userCurrencies = ["USD", "EUR", "RUB"]
        mainListViewModel.updateDisplayedCurrencies()

        // Вводим 100 USD
        mainListViewModel.updateAmount("100", for: "USD")

        // Проверяем, что EUR пересчитался правильно
        let eurItem = mainListViewModel.displayedCurrencies.first { $0.rate.code == "EUR" }
        XCTAssertNotNil(eurItem, "EUR должна быть в списке")

        let expectedEurAmount = (100 * 100.00) / 90.91 // ≈ 110.00
        XCTAssertEqual(eurItem?.inputAmount ?? 0, expectedEurAmount, accuracy: 0.01, "EUR должно пересчитаться в ~110.00")

        // Проверяем, что RUB пересчитался правильно
        let rubItem = mainListViewModel.displayedCurrencies.first { $0.rate.code == "RUB" }
        XCTAssertNotNil(rubItem, "RUB должна быть в списке")

        let expectedRubAmount = (100 * 1.0) / 90.91 // ≈ 1.10
        XCTAssertEqual(rubItem?.inputAmount ?? 0, expectedRubAmount, accuracy: 0.01, "RUB должно пересчитаться в ~1.10")
    }

    func testInputFieldClearing() throws {
        // Тест 6: Проверяем очистку полей ввода при фокусе
        let testRates = [
            Rate(code: "USD", name: "Доллар США", value: 90.91, updatedAt: Date()),
            Rate(code: "EUR", name: "Евро", value: 100.00, updatedAt: Date())
        ]

        saveTestRates(testRates)
        settingsService.userCurrencies = ["USD", "EUR"]
        mainListViewModel.updateDisplayedCurrencies()

        // Вводим значения
        mainListViewModel.updateAmount("100", for: "USD")
        mainListViewModel.updateAmount("200", for: "EUR")

        // Проверяем, что значения установлены
        let usdItem = mainListViewModel.displayedCurrencies.first { $0.rate.code == "USD" }
        let eurItem = mainListViewModel.displayedCurrencies.first { $0.rate.code == "EUR" }

        XCTAssertEqual(usdItem?.inputAmount ?? 0, 100, "USD должно иметь значение 100")
        XCTAssertEqual(eurItem?.inputAmount ?? 0, 200, "EUR должно иметь значение 200")

        // Симулируем фокус на USD поле
        mainListViewModel.activeInputCurrency = "USD"

        // Проверяем, что USD поле очистилось
        let updatedUsdItem = mainListViewModel.displayedCurrencies.first { $0.rate.code == "USD" }
        XCTAssertEqual(updatedUsdItem?.inputAmount ?? 0, 0, "USD поле должно очиститься при фокусе")
    }

    // MARK: - Тесты отсутствия данных

    func testNoDataDisplay() throws {
        // Тест 7: Проверяем отображение при отсутствии данных
        clearTestData()

        // Проверяем, что список пустой
        mainListViewModel.updateDisplayedCurrencies()
        XCTAssertEqual(mainListViewModel.displayedCurrencies.count, 0, "Список должен быть пустым при отсутствии данных")
    }

    func testNoRatesFromAPI() throws {
        // Тест 8: Проверяем поведение при отсутствии курсов из API
        clearTestData()

        // Не добавляем никаких курсов
        settingsService.userCurrencies = ["USD", "EUR"]
        mainListViewModel.updateDisplayedCurrencies()

        // Проверяем, что список остается пустым
        XCTAssertEqual(mainListViewModel.displayedCurrencies.count, 0, "Список должен оставаться пустым при отсутствии курсов")
    }

    // MARK: - Вспомогательные методы

    private func saveTestRates(_ rates: [Rate]) {
        let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()

        context.perform {
            for rate in rates {
                let entity = RateEntity(context: context)
                entity.code = rate.code
                entity.name = rate.name
                entity.value = rate.value
                entity.updatedAt = rate.updatedAt
            }

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.ratesRepository.loadLocalRates()
                }
            } catch {
                print("Failed to save test rates: \(error)")
            }
        }
    }
}
