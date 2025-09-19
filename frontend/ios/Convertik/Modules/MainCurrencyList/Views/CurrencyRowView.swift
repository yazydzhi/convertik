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
    @State private var showCopyConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
                        // Первая строка: код валюты (с символом если есть), поле ввода
            HStack(spacing: 12) {
                // Код валюты с символом (если есть специальный символ)
                HStack(spacing: 4) {
                    Text(rate.code)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    // Показываем символ только если он отличается от кода валюты
                    if hasSpecialSymbol(for: rate.code) {
                        Text(getCurrencySymbol(for: rate.code))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.textPrimary)
                    }
                }
                .frame(minWidth: 100, alignment: .leading) // Увеличенная минимальная ширина для кода + символ
                
                Spacer(minLength: 8) // Минимальное расстояние между кодом и полем ввода
                
                // Поле ввода с кнопкой копирования
                HStack(spacing: 8) {
                    // Кнопка копирования
                    Button(action: copyAmountToClipboard) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(amountText.isEmpty ? themeManager.textSecondary.opacity(0.5) : themeManager.textSecondary)
                    }
                    .disabled(amountText.isEmpty)
                    .scaleEffect(amountText.isEmpty ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: amountText.isEmpty)
                    
                    TextField("0", text: $amountText)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 120, maxWidth: .infinity) // Гибкая ширина поля ввода
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
                }
            }
            
            // Вторая строка: название валюты и курс
            HStack(spacing: 12) {
                Text(rate.displayName)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer(minLength: 8)
                
                // Показываем курс только для не-рублевых валют, выравниваем по правому краю с полем ввода
                if rate.code != "RUB" {
                    Text("1 \(rate.code) = \(conversionService.formatRate(rate)) ₽")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 120, maxWidth: .infinity, alignment: .trailing) // Выравниваем с полем ввода
                } else {
                    // Для рубля добавляем пустое пространство для выравнивания
                    Spacer()
                        .frame(minWidth: 120, maxWidth: .infinity)
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
        .overlay(
            // Уведомление о копировании
            Group {
                if showCopyConfirmation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Скопировано")
                            .font(.caption)
                            .foregroundColor(themeManager.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.cardBackground)
                    .cornerRadius(ConvertikCornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                            .stroke(themeManager.separator, lineWidth: 1)
                    )
                    .shadow(color: themeManager.cardGlowColor, radius: 4, x: 0, y: 2)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showCopyConfirmation)
                }
            },
            alignment: .topTrailing
        )
    }
    
    // MARK: - Helper Functions
    
    /// Копирование суммы в буфер обмена
    private func copyAmountToClipboard() {
        guard !amountText.isEmpty else { return }
        
        // Копируем значение в буфер обмена
        UIPasteboard.general.string = amountText
        
        // Тактильная обратная связь
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Показываем уведомление о копировании
        showCopyConfirmation = true
        
        // Скрываем уведомление через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCopyConfirmation = false
            }
        }
    }
    
    /// Получение символа валюты
    private func getCurrencySymbol(for code: String) -> String {
        switch code {
        // Основные валюты
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        case "CNY": return "¥"
        case "KRW": return "₩"
        case "INR": return "₹"
        case "BRL": return "R$"
        case "CAD": return "C$"
        case "AUD": return "A$"
        case "CHF": return "CHF"
        case "SEK": return "kr"
        case "NOK": return "kr"
        case "DKK": return "kr"
        case "PLN": return "zł"
        case "CZK": return "Kč"
        case "HUF": return "Ft"
        case "RON": return "lei"
        case "BGN": return "лв"
        case "HRK": return "kn"
        case "ALL": return "L"
        case "AMD": return "֏"
        case "AZN": return "₼"
        case "BYN": return "Br"
        case "GEL": return "₾"
        case "KZT": return "₸"
        case "KGS": return "с"
        case "MDL": return "L"
        case "TJS": return "ЅМ"
        case "TMT": return "T"
        case "UZS": return "so'm"
        case "UAH": return "₴"
        
        // Дополнительные валюты
        case "TRY": return "₺"
        case "AED": return "د.إ"
        case "AFN": return "؋"
        case "ANG": return "ƒ"
        case "AOA": return "Kz"
        case "ARS": return "$"
        case "AWG": return "ƒ"
        case "BAM": return "KM"
        case "BBD": return "$"
        case "BDT": return "৳"
        case "BHD": return ".د.ب"
        case "BIF": return "FBu"
        case "BMD": return "$"
        case "BND": return "$"
        case "BOB": return "Bs"
        case "BSD": return "$"
        case "BTC": return "₿"
        case "BTN": return "Nu."
        case "BWP": return "P"
        case "BZD": return "$"
        case "CDF": return "FC"
        case "CLF": return "UF"
        case "CLP": return "$"
        case "CNH": return "¥"
        case "COP": return "$"
        case "CRC": return "₡"
        case "CUC": return "$"
        case "CUP": return "$"
        case "CVE": return "$"
        case "DJF": return "Fdj"
        case "DOP": return "$"
        case "DZD": return "د.ج"
        case "EGP": return "£"
        case "ERN": return "Nfk"
        case "ETB": return "Br"
        case "FJD": return "$"
        case "FKP": return "£"
        case "GGP": return "£"
        case "GHS": return "₵"
        case "GIP": return "£"
        case "GMD": return "D"
        case "GNF": return "FG"
        case "GTQ": return "Q"
        case "GYD": return "$"
        case "HKD": return "$"
        case "HNL": return "L"
        case "HTG": return "G"
        case "IDR": return "Rp"
        case "ILS": return "₪"
        case "IMP": return "£"
        case "IQD": return "ع.د"
        case "IRR": return "﷼"
        case "ISK": return "kr"
        case "JEP": return "£"
        case "JMD": return "$"
        case "JOD": return "د.ا"
        case "KES": return "KSh"
        case "KHR": return "៛"
        case "KMF": return "CF"
        case "KPW": return "₩"
        case "KWD": return "د.ك"
        case "KYD": return "$"
        case "LAK": return "₭"
        case "LBP": return "ل.ل"
        case "LKR": return "₨"
        case "LRD": return "$"
        case "LSL": return "L"
        case "LYD": return "ل.د"
        case "MAD": return "د.م."
        case "MGA": return "Ar"
        case "MKD": return "ден"
        case "MMK": return "K"
        case "MNT": return "₮"
        case "MOP": return "MOP$"
        case "MRU": return "UM"
        case "MUR": return "₨"
        case "MVR": return "Rf"
        case "MWK": return "MK"
        case "MXN": return "$"
        case "MYR": return "RM"
        case "MZN": return "MT"
        case "NAD": return "$"
        case "NGN": return "₦"
        case "NIO": return "C$"
        case "NPR": return "₨"
        case "NZD": return "$"
        case "OMR": return "ر.ع."
        case "PAB": return "B/."
        case "PEN": return "S/"
        case "PGK": return "K"
        case "PHP": return "₱"
        case "PKR": return "₨"
        case "PYG": return "₲"
        case "QAR": return "ر.ق"
        case "RSD": return "дин"
        case "RWF": return "FRw"
        case "SAR": return "ر.س"
        case "SBD": return "$"
        case "SCR": return "₨"
        case "SDG": return "ج.س."
        case "SGD": return "$"
        case "SHP": return "£"
        case "SLE": return "Le"
        case "SLL": return "Le"
        case "SOS": return "S"
        case "SRD": return "$"
        case "SSP": return "£"
        case "STD": return "Db"
        case "STN": return "Db"
        case "SVC": return "$"
        case "SYP": return "£"
        case "SZL": return "L"
        case "THB": return "฿"
        case "TND": return "د.ت"
        case "TOP": return "T$"
        case "TTD": return "$"
        case "TWD": return "NT$"
        case "TZS": return "TSh"
        case "UGX": return "USh"
        case "UYU": return "$"
        case "VES": return "Bs"
        case "VND": return "₫"
        case "VUV": return "Vt"
        case "WST": return "T"
        case "XAF": return "FCFA"
        case "XAG": return "XAG"
        case "XAU": return "XAU"
        case "XCD": return "$"
        case "XCG": return "$"
        case "XDR": return "XDR"
        case "XOF": return "CFA"
        case "XPD": return "XPD"
        case "XPF": return "₣"
        case "XPT": return "XPT"
        case "YER": return "﷼"
        case "ZAR": return "R"
        case "ZMW": return "ZK"
        case "ZWG": return "$"
        case "ZWL": return "$"
        default:
            return code
        }
    }
    
    /// Проверка, есть ли у валюты специальный символ (отличающийся от кода)
    private func hasSpecialSymbol(for code: String) -> Bool {
        let symbol = getCurrencySymbol(for: code)
        return symbol != code
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
