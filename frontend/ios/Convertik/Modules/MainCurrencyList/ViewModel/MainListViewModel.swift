import Foundation
import Combine
import SwiftUI // Added for withAnimation

@MainActor
final class MainListViewModel: ObservableObject {
    @Published var displayedCurrencies: [CurrencyDisplayItem] = []
    @Published var activeInputCurrency: String? // Код валюты, в которую вводится значение

    private let ratesRepository = RatesRepository.shared
    private let settingsService = SettingsService.shared
    private let conversionService = ConversionService.shared
    private let analyticsService = AnalyticsService.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        updateDisplayedCurrencies()
    }

    private func setupBindings() {
        // Подписываемся на изменения курсов
        ratesRepository.$rates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayedCurrencies()
            }
            .store(in: &cancellables)

        // Подписываемся на изменения пользовательских валют
        settingsService.$userCurrencies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayedCurrencies()
            }
            .store(in: &cancellables)

        // Подписываемся на изменения премиум статуса
        settingsService.$isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayedCurrencies()
            }
            .store(in: &cancellables)
    }

    func setActiveInputCurrency(_ currencyCode: String?) {
        activeInputCurrency = currencyCode
    }

    func updateAmount(_ amountString: String, for currencyCode: String) {
        // Парсим введенную сумму
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","

        let cleanString = amountString.replacingOccurrences(of: " ", with: "")

        guard let value = formatter.number(from: cleanString)?.doubleValue ?? Double(cleanString) else {
            return
        }

        // Отслеживаем конвертацию только если сумма больше 0
        if value > 0 {
            analyticsService.trackConversion(
                from: "RUB",
                to: currencyCode,
                amount: value
            )
        }

        // Обновляем значение для активной валюты
        if let index = displayedCurrencies.firstIndex(where: { $0.rate.code == currencyCode }) {
            displayedCurrencies[index].inputAmount = value
        }

        // Пересчитываем все остальные валюты
        recalculateAllCurrencies(baseCurrencyCode: currencyCode, baseAmount: value)
    }

    private func recalculateAllCurrencies(baseCurrencyCode: String, baseAmount: Double) {
        guard let baseRate = ratesRepository.rate(for: baseCurrencyCode) else { return }

        for i in 0..<displayedCurrencies.count {
            let targetCurrency = displayedCurrencies[i]

            // Пропускаем базовую валюту
            if targetCurrency.rate.code == baseCurrencyCode {
                continue
            }

            // Конвертируем из базовой валюты в целевую
            let convertedAmount = conversionService.convert(baseAmount, from: baseRate, to: targetCurrency.rate)
            displayedCurrencies[i].inputAmount = convertedAmount
        }
    }

    func updateDisplayedCurrencies() {
        let userCurrencies = settingsService.userCurrencies

        displayedCurrencies = userCurrencies.compactMap { currencyCode in
            guard let rate = ratesRepository.rate(for: currencyCode) else {
                return nil
            }

            return CurrencyDisplayItem(
                rate: rate,
                inputAmount: 0.0
            )
        }
    }

    func trackConversion(to currencyCode: String) {
        analyticsService.trackConversion(
            from: "RUB",
            to: currencyCode,
            amount: 0.0 // Будем обновлять когда добавим отслеживание конкретных сумм
        )
    }
    
    func moveCurrency(from sourceIndex: Int, to destinationIndex: Int) {
        // Не позволяем перемещать RUB (он всегда первый)
        guard sourceIndex > 0 && destinationIndex > 0 else { 
            print("Попытка переместить RUB или недопустимую позицию")
            return 
        }
        
        // Проверяем, что индексы в допустимых пределах
        guard sourceIndex < displayedCurrencies.count && destinationIndex < displayedCurrencies.count else {
            print("Индекс вне допустимых пределов")
            return
        }
        
        // Проверяем, что перемещаемая валюта не RUB
        let sourceCurrency = displayedCurrencies[sourceIndex]
        guard sourceCurrency.rate.code != "RUB" else {
            print("Попытка переместить RUB")
            return
        }
        
        // Создаем IndexSet из одного элемента
        let indexSet = IndexSet(integer: sourceIndex)
        
        // Обновляем порядок в SettingsService с анимацией
        withAnimation(.easeInOut(duration: 0.3)) {
            settingsService.moveCurrency(from: indexSet, to: destinationIndex)
        }
        
        // Отслеживаем событие перемещения
        analyticsService.trackCurrencyMoved(sourceCurrency.rate.code)
    }
}

struct CurrencyDisplayItem: Identifiable {
    let rate: Rate
    var inputAmount: Double

    var id: String { rate.code }
}
