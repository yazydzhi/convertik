import SwiftUI

struct CurrencyRowView: View {
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
                    .foregroundColor(.secondary)
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

                    Spacer()

                    // Поле ввода суммы
                    TextField("0", text: $amountText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("1 \(rate.code) = \(conversionService.formatRate(rate)) ₽")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
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
}
