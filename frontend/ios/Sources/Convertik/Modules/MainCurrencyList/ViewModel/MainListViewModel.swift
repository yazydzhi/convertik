import Foundation
import Combine

@MainActor
final class MainListViewModel: ObservableObject {
    @Published var displayedCurrencies: [CurrencyDisplayItem] = []
    @Published var amountValue: Double = 100.0
    
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
        settingsService.$isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayedCurrencies()
            }
            .store(in: &cancellables)
    }
    
    func updateAmount(_ amountString: String) {
        // Парсим введенную сумму
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        
        let cleanString = amountString.replacingOccurrences(of: " ", with: "")
        
        if let value = formatter.number(from: cleanString)?.doubleValue {
            amountValue = value
        } else if let value = Double(cleanString) {
            amountValue = value
        }
        
        updateDisplayedCurrencies()
    }
    
    func updateDisplayedCurrencies() {
        let userCurrencies = settingsService.userCurrencies
        let baseRate = Rate(code: "RUB", name: "Российский рубль", value: 1.0)
        
        displayedCurrencies = userCurrencies.compactMap { currencyCode in
            guard let rate = ratesRepository.rate(for: currencyCode) else {
                return nil
            }
            
            let convertedAmount = conversionService.convert(amountValue, from: baseRate, to: rate)
            
            return CurrencyDisplayItem(
                rate: rate,
                convertedAmount: convertedAmount
            )
        }
    }
    
    func trackConversion(to currencyCode: String) {
        analyticsService.trackConversion(
            from: "RUB",
            to: currencyCode,
            amount: amountValue
        )
    }
}

struct CurrencyDisplayItem {
    let rate: Rate
    let convertedAmount: Double
}