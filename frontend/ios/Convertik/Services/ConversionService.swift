import Foundation

final class ConversionService {
    static let shared = ConversionService()
    
    private init() {}
    
    /// Конвертирует сумму из одной валюты в другую
    /// - Parameters:
    ///   - amount: Сумма для конвертации
    ///   - from: Исходная валюта
    ///   - to: Целевая валюта
    /// - Returns: Конвертированная сумма
    func convert(_ amount: Double, from: Rate, to: Rate) -> Double {
        guard from.value > 0, to.value > 0 else { return 0 }
        
        // Сначала конвертируем в рубли (базовая валюта)
        let rubles = amount * from.value
        
        // Затем конвертируем рубли в целевую валюту
        return rubles / to.value
    }
    
    /// Форматирует сумму для отображения
    /// - Parameters:
    ///   - amount: Сумма для форматирования
    ///   - currencyCode: Код валюты
    /// - Returns: Отформатированная строка
    func formatAmount(_ amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        // Для больших сумм убираем дробную часть
        if amount >= 100 {
            formatter.maximumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Форматирует курс валюты
    /// - Parameter rate: Курс валюты
    /// - Returns: Отформатированная строка курса
    func formatRate(_ rate: Rate) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: rate.value)) ?? "\(rate.value)"
    }
}