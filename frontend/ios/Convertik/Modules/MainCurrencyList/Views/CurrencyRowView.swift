import SwiftUI

struct CurrencyRowView: View {
    @Environment(\.themeManager) private var themeManager
    
    let rate: Rate
    let inputAmount: Double
    let isActiveInput: Bool
    let onAmountChange: (String) -> Void
    let onFocusChange: (Bool) -> Void

    private let conversionService = ConversionService.shared

    @State private var amountText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Первая строка: код валюты, поле ввода и символ
            HStack {
                // Код валюты с фиксированной шириной для 3 символов
                Text(rate.code)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                    .frame(width: 60, alignment: .leading) // Фиксированная ширина для 3 символов
                
                Spacer()
                
                // Поле ввода с фиксированным отступом от правого края
                                   TextField("0", text: $amountText)
                       .textFieldStyle(CustomTextFieldStyle())
                       .keyboardType(.decimalPad)
                       .multilineTextAlignment(.trailing)
                       .frame(width: 140)
                    .focused($isFocused)
                    .allowsHitTesting(true)
                    .disabled(false)
                    .onChange(of: amountText) { newValue in
                        onAmountChange(newValue)
                    }
                    .onChange(of: isFocused) { focused in
                        onFocusChange(focused)
                        if focused {
                            // При фокусе очищаем поле
                            amountText = ""
                        }
                    }
                    .onTapGesture {
                        isFocused = true
                    }
                
                // Символ валюты после поля ввода
                Text(getCurrencySymbol(for: rate.code))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                    .frame(width: 40, alignment: .leading) // Увеличенная ширина для символа
            }
            
            // Вторая строка: название валюты и курс
            HStack {
                Text(rate.displayName)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                // Показываем курс только для не-рублевых валют
                if rate.code != "RUB" {
                    Text("1 \(rate.code) = \(conversionService.formatRate(rate)) ₽")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(themeManager.cardBackground(isSelected: isActiveInput))
        .cornerRadius(ConvertikCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.md)
                .stroke(
                    isActiveInput ? themeManager.lilacHighlight : themeManager.separator, 
                    lineWidth: isActiveInput ? 1.5 : 1
                )
        )
        .shadow(
            color: isActiveInput 
                ? themeManager.lilacHighlight.opacity(0.3) // Лёгкое поднятие для выбранной карточки
                : (themeManager.isDarkMode ? themeManager.cardGlowColor : ConvertikShadows.light.color), // Легкое свечение только в темной теме
            radius: isActiveInput 
                ? 8 // Увеличенная тень для "возвышения"
                : (themeManager.isDarkMode ? 4 : ConvertikShadows.light.radius), // Меньший радиус для свечения только в темной теме
            x: themeManager.isDarkMode ? ConvertikShadows.lightDark.x : ConvertikShadows.light.x,
            y: isActiveInput 
                ? 2 // Лёгкое поднятие
                : (themeManager.isDarkMode ? ConvertikShadows.lightDark.y : ConvertikShadows.light.y)
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.3), value: isActiveInput) // Плавная анимация при изменении состояния
        .onAppear {
            // Устанавливаем начальное значение
            if inputAmount > 0 {
                amountText = conversionService.formatAmount(inputAmount, currencyCode: rate.code, showSymbol: false)
            }
        }
        .onChange(of: inputAmount) { newAmount in
            // Обновляем текст при изменении значения извне
            if !isFocused && newAmount > 0 {
                amountText = conversionService.formatAmount(newAmount, currencyCode: rate.code, showSymbol: false)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Получение символа валюты
    private func getCurrencySymbol(for code: String) -> String {
        switch code {
        case "RUB":
            return "₽"
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "CNY":
            return "¥"
        case "KRW":
            return "₩"
        case "INR":
            return "₹"
        case "BRL":
            return "R$"
        case "CAD":
            return "C$"
        case "AUD":
            return "A$"
        case "CHF":
            return "CHF"
        case "SEK":
            return "kr"
        case "NOK":
            return "kr"
        case "DKK":
            return "kr"
        case "PLN":
            return "zł"
        case "CZK":
            return "Kč"
        case "HUF":
            return "Ft"
        case "RON":
            return "lei"
        case "BGN":
            return "лв"
        case "HRK":
            return "kn"
        case "ALL":
            return "L"
        case "AMD":
            return "֏"
        case "AZN":
            return "₼"
        case "BYN":
            return "Br"
        case "GEL":
            return "₾"
        case "KZT":
            return "₸"
        case "KGS":
            return "с"
        case "MDL":
            return "L"
        case "TJS":
            return "ЅМ"
        case "TMT":
            return "T"
        case "UZS":
            return "so'm"
        case "UAH":
            return "₴"
        default:
            return code
        }
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    @Environment(\.themeManager) private var themeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(themeManager.cardBackground)
            .cornerRadius(ConvertikCornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                    .stroke(themeManager.lilacHighlight, lineWidth: 1) // Заменяем Amber на Lilac для полей ввода
            )
            .foregroundColor(themeManager.textPrimary)
    }
}

#Preview {
    let sampleRate = Rate(
        code: "USD",
        name: "Доллар США",
        value: 92.5
    )

    List {
        CurrencyRowView(
            rate: sampleRate,
            inputAmount: 100.0,
            isActiveInput: false,
            onAmountChange: { _ in },
            onFocusChange: { _ in }
        )
    }
    .background(Color(uiColor: .systemBackground))
    .environmentObject(ThemeManager(themeService: ThemeService.shared))
    .environmentObject(ThemeService.shared)
}
