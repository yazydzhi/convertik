import SwiftUI
import Foundation

@MainActor
final class SettingsService: ObservableObject {
    static let shared = SettingsService()

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }

    @Published var deviceId: String

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }

    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // НЕ загружаем isPremium из UserDefaults при инициализации
        // Вместо этого ждем обновления от StoreService
        self.isPremium = false

        // Инициализируем пользовательские валюты
        let savedCurrencies = UserDefaults.standard.array(forKey: userCurrenciesKey) as? [String] ?? ["RUB", "USD", "EUR", "GBP"]
        // Обеспечиваем что RUB всегда первая
        self.userCurrencies = Self.ensureRubFirst(savedCurrencies)

        // Генерируем уникальный ID устройства или используем существующий
        if let existingId = UserDefaults.standard.string(forKey: "deviceId") {
            self.deviceId = existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "deviceId")
            self.deviceId = newId
        }
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }

    func setPremiumStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
    }

    // MARK: - User Currencies Management

    private let userCurrenciesKey = "userCurrencies"

    @Published var userCurrencies: [String] {
        didSet {
            // Всегда обеспечиваем что RUB первая при любых изменениях
            let correctedCurrencies = Self.ensureRubFirst(userCurrencies)
            if correctedCurrencies != userCurrencies {
                userCurrencies = correctedCurrencies
                return
            }
            UserDefaults.standard.set(userCurrencies, forKey: userCurrenciesKey)
        }
    }

    func addCurrency(_ code: String) {
        var currencies = userCurrencies
        if !currencies.contains(code) {
            currencies.append(code)
            userCurrencies = currencies
        }
    }

    func removeCurrency(_ code: String) {
        // Не позволяем удалять RUB
        if code == "RUB" {
            return
        }
        userCurrencies = userCurrencies.filter { $0 != code }
    }

    func moveCurrency(from: IndexSet, to: Int) {
        var currencies = userCurrencies
        
        // Проверяем что мы не пытаемся переместить RUB или переместить что-то на позицию 0
        let fromIndex = from.first ?? -1
        
        // Не позволяем перемещать RUB (индекс 0)
        if fromIndex == 0 {
            return
        }
        
        // Не позволяем перемещать валюты на позицию 0 (место для RUB)
        if to == 0 {
            return
        }
        
        currencies.move(fromOffsets: from, toOffset: to)
        userCurrencies = currencies
    }
    
    // MARK: - Private Helper Methods
    
    /// Обеспечивает что RUB всегда первая валюта в списке
    private static func ensureRubFirst(_ currencies: [String]) -> [String] {
        var result = currencies
        
        // Убираем RUB из любой позиции
        result.removeAll { $0 == "RUB" }
        
        // Добавляем RUB в начало
        result.insert("RUB", at: 0)
        
        return result
    }
}
