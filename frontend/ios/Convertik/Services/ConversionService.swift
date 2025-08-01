import Foundation

final class ConversionService {
    static let shared = ConversionService()

    private init() {}

    /// Конвертирует сумму из одной валюты в другую через рубли как базовую валюту
    /// - Parameters:
    ///   - amount: Сумма для конвертации
    ///   - from: Исходная валюта (курс к рублю)
    ///   - targetRate: Целевая валюта (курс к рублю)
    /// - Returns: Конвертированная сумма
    func convert(_ amount: Double, from: Rate, to targetRate: Rate) -> Double {
        guard from.value > 0, targetRate.value > 0 else { return 0 }

        // Формула: (amount * targetRate.value) / from.value
        // Это соответствует логике из React Native версии
        return (amount * targetRate.value) / from.value
    }

    /// Форматирует сумму для отображения с символом валюты
    /// - Parameters:
    ///   - amount: Сумма для форматирования
    ///   - currencyCode: Код валюты
    /// - Returns: Отформатированная строка
    func formatAmount(_ amount: Double, currencyCode: String) -> String {
        return formatAmount(amount, currencyCode: currencyCode, showSymbol: true)
    }

    /// Форматирует сумму для отображения
    /// - Parameters:
    ///   - amount: Сумма для форматирования
    ///   - currencyCode: Код валюты
    ///   - showSymbol: Показывать ли символ валюты
    /// - Returns: Отформатированная строка
    func formatAmount(_ amount: Double, currencyCode: String, showSymbol: Bool) -> String {
        let formatter = NumberFormatter()

        if showSymbol {
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
        } else {
            formatter.numberStyle = .decimal
        }

        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        // Для больших сумм убираем дробную часть
        if amount >= 100 {
            formatter.maximumFractionDigits = 0
        }

        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    /// Форматирует курс валюты для отображения
    /// - Parameter rate: Курс валюты к рублю
    /// - Returns: Отформатированная строка курса
    func formatRate(_ rate: Rate) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2

        // Показываем курс как "1 USD = X рублей"
        // rate.value уже содержит количество рублей за 1 единицу валюты
        // Например, если rate.value = 90.91, то "1 USD = 90.91 ₽"
        return formatter.string(from: NSNumber(value: rate.value)) ?? "\(rate.value)"
    }
}
