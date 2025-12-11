import Foundation
import Combine
import SwiftUI // Added for withAnimation

@MainActor
final class MainListViewModel: ObservableObject {
    @Published var displayedCurrencies: [CurrencyDisplayItem] = []
    @Published var activeInputCurrency: String? // Код валюты, в которую вводится значение

    private let ratesRepository = RatesRepository.shared
    private let settingsService = SettingsService.shared
    private let storeService = StoreService.shared
    private let conversionService = ConversionService.shared
    private let analyticsService = AnalyticsService.shared
    private let interstitialService = InterstitialAdService.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        updateDisplayedCurrencies()
    }

    private func setupBindings() {
        // Подписываемся на изменения курсов
        ratesRepository.$rates
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main) // Дебаунс для предотвращения частых обновлений
            .sink { [weak self] _ in
                self?.safeUpdateDisplayedCurrencies()
            }
            .store(in: &cancellables)

        // Подписываемся на изменения пользовательских валют
        settingsService.$userCurrencies
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main) // Дебаунс для предотвращения частых обновлений
            .sink { [weak self] _ in
                self?.safeUpdateDisplayedCurrencies()
            }
            .store(in: &cancellables)

        // Подписываемся на изменения премиум статуса из StoreService (источник истины)
        storeService.$isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.safeUpdateDisplayedCurrencies()
            }
            .store(in: &cancellables)

        // Подписываемся на изменения статуса показа рекламы
        interstitialService.$isShowingAd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isShowing in
                // Когда реклама закрывается (isShowingAd становится false), обновляем список
                if !isShowing {
                    Task { @MainActor in
                        // Даем время UI стабилизироваться после закрытия рекламы
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды задержка
                        self?.updateDisplayedCurrencies()
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Безопасное обновление списка валют с проверкой на показ рекламы
    private func safeUpdateDisplayedCurrencies() {
        // Проверяем, показывается ли реклама (через флаг isShowingAd)
        // Если реклама показывается, пропускаем обновление - оно произойдет после закрытия рекламы
        if interstitialService.isShowingAd {
            print("⚠️ Skipping currency list update - ad is showing")
            return
        }

        // Если реклама не показывается, обновляем сразу
        updateDisplayedCurrencies()
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
        updateDisplayedCurrencies(with: userCurrencies)
    }

    private func updateDisplayedCurrencies(with userCurrencies: [String]) {
        // Создаем словарь для сохранения текущих значений inputAmount
        let currentAmounts = Dictionary(uniqueKeysWithValues: displayedCurrencies.map { ($0.rate.code, $0.inputAmount) })

        let newCurrencies = userCurrencies.compactMap { currencyCode -> CurrencyDisplayItem? in
            guard let rate = ratesRepository.rate(for: currencyCode) else {
                return nil
            }

            // Сохраняем текущее значение inputAmount, если валюта уже была в списке
            let inputAmount = currentAmounts[currencyCode] ?? 0.0

            return CurrencyDisplayItem(
                rate: rate,
                inputAmount: inputAmount
            )
        }

        // Проверяем, изменился ли порядок или состав валют
        let oldCodes = displayedCurrencies.map { $0.rate.code }
        let newCodes = newCurrencies.map { $0.rate.code }

        if oldCodes != newCodes {
            // Если порядок или состав изменился, используем анимацию
            withAnimation(.easeInOut(duration: 0.2)) {
                displayedCurrencies = newCurrencies
            }
        } else {
            // Если порядок не изменился, обновляем без анимации
            // Но только если действительно есть изменения в данных
            var hasChanges = false
            for (index, newItem) in newCurrencies.enumerated() {
                if index < displayedCurrencies.count {
                    let oldItem = displayedCurrencies[index]
                    if oldItem.rate.value != newItem.rate.value {
                        hasChanges = true
                        break
                    }
                }
            }

            if hasChanges {
                // Обновляем только значения курсов, сохраняя inputAmount
                // Создаем новый массив с обновленными курсами
                displayedCurrencies = newCurrencies
            }
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
