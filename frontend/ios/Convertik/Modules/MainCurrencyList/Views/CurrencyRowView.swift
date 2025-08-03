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
        HStack(spacing: 12) {
            // Левая часть: иконка дома для RUB
            if rate.code == "RUB" {
                Image(systemName: "house.fill")
                    .foregroundColor(themeManager.lilacHighlight)
                    .font(.title2)
                    .frame(width: 24)
            } else {
                // Пустое место для выравнивания
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 24)
            }
            
            // Иконка и название валюты
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rate.code)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)

                    Spacer()

                    // Поле ввода суммы
                    TextField("0", text: $amountText)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
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

                HStack {
                    Text(rate.displayName)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)

                    Spacer()

                    Text("1 \(rate.code) = \(conversionService.formatRate(rate)) ₽")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
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
                : (themeManager.isDarkMode ? themeManager.cardGlowColor : ConvertikShadows.light.color), // Легкое свечение в темной теме
            radius: isActiveInput 
                ? 8 // Увеличенная тень для "возвышения"
                : (themeManager.isDarkMode ? 4 : ConvertikShadows.light.radius), // Меньший радиус для свечения
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
