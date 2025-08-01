import SwiftUI

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var ratesRepository: RatesRepository
    @EnvironmentObject private var settingsService: SettingsService
    @StateObject private var analyticsService = AnalyticsService.shared
    
    @State private var searchText = ""
    
    private var availableRates: [Rate] {
        ratesRepository.rates.filter { rate in
            !settingsService.userCurrencies.contains(rate.code) &&
            (searchText.isEmpty || 
             rate.code.localizedCaseInsensitiveContains(searchText) ||
             rate.displayName.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    private var popularRates: [Rate] {
        availableRates.filter { Rate.popularCurrencies.contains($0.code) }
    }
    
    private var otherRates: [Rate] {
        availableRates.filter { !Rate.popularCurrencies.contains($0.code) }
            .sorted { $0.code < $1.code }
    }
    
    var body: some View {
        NavigationView {
            List {
                if !popularRates.isEmpty {
                    Section("Популярные") {
                        ForEach(popularRates) { rate in
                            CurrencySelectionRow(rate: rate) {
                                addCurrency(rate)
                            }
                        }
                    }
                }
                
                if !otherRates.isEmpty {
                    Section("Все валюты") {
                        ForEach(otherRates) { rate in
                            CurrencySelectionRow(rate: rate) {
                                addCurrency(rate)
                            }
                        }
                    }
                }
                
                if availableRates.isEmpty && !searchText.isEmpty {
                    Section {
                        Text("Валюты не найдены")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Добавить валюту")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Поиск валют")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addCurrency(_ rate: Rate) {
        settingsService.addCurrency(rate.code)
        analyticsService.trackCurrencyAdded(rate.code)
        
        // Уведомляем об изменении и закрываем модальное окно
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

struct CurrencySelectionRow: View {
    let rate: Rate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(rate.code)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    
                    Text(rate.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddCurrencyView()
        .environmentObject(RatesRepository.shared)
        .environmentObject(SettingsService.shared)
}