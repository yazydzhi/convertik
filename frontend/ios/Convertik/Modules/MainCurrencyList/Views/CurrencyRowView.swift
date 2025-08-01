import SwiftUI

struct CurrencyRowView: View {
    let rate: Rate
    let convertedAmount: Double
    let inputAmount: Double
    
    private let conversionService = ConversionService.shared
    
    var body: some View {
        HStack {
            // Иконка и название валюты
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rate.code)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(conversionService.formatAmount(convertedAmount, currencyCode: rate.code))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
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
    }
}

#Preview {
    let sampleRate = Rate(
        code: "USD", 
        name: "Доллар США", 
        value: 92.5
    )
    
    return List {
        CurrencyRowView(
            rate: sampleRate,
            convertedAmount: 1.08,
            inputAmount: 100
        )
    }
}