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
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
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
    
    var userCurrencies: [String] {
        get {
            UserDefaults.standard.array(forKey: userCurrenciesKey) as? [String] ?? ["USD", "EUR", "GBP"]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userCurrenciesKey)
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
        userCurrencies = userCurrencies.filter { $0 != code }
    }
    
    func moveCurrency(from: IndexSet, to: Int) {
        var currencies = userCurrencies
        currencies.move(fromOffsets: from, toOffset: to)
        userCurrencies = currencies
    }
}