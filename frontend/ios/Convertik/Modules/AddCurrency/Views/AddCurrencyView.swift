import SwiftUI
import os

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var ratesRepository: RatesRepository
    @EnvironmentObject private var settingsService: SettingsService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared

    @State private var searchText = ""

    private var availableRates: [Rate] {
        let allRates = ratesRepository.rates
        let userCurrencies = settingsService.userCurrencies
        
        return allRates.filter { rate in
            !userCurrencies.contains(rate.code) &&
            (searchText.isEmpty || 
             rate.code.localizedCaseInsensitiveContains(searchText) ||
             rate.displayName.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if ratesRepository.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Загрузка валют...")
                            .foregroundColor(themeManager.textSecondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = ratesRepository.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(themeManager.amberAccent)
                            .padding()
                        
                        Text("Ошибка загрузки")
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Повторить") {
                            Task {
                                await ratesRepository.syncRemote()
                            }
                        }
                        .foregroundColor(themeManager.amberAccent)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if availableRates.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(themeManager.textSecondary)
                            .padding()
                        
                        Text("Нет доступных валют")
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text("Все валюты уже добавлены или произошла ошибка загрузки")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        SearchBar(text: $searchText, placeholder: "Поиск валют")
                        
                        List(availableRates, id: \.code) { rate in
                            CurrencySelectionRow(rate: rate) {
                                addCurrency(rate)
                            }
                            .listRowBackground(themeManager.cardBackground)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Добавить валюту")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.amberAccent)
                    .accessibilityIdentifier("cancelButton")
                }
            }
        }
        .onAppear {
            Task {
                await ratesRepository.syncRemote()
            }
        }
        .id(themeManager.isDarkMode) // Принудительное обновление при изменении темы
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

struct SearchBar: View {
    @Environment(\.themeManager) private var themeManager
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.lilacHighlight)

            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(themeManager.textPrimary)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.amberAccent)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(themeManager.amberAccent, lineWidth: 1)
        )
    }
}

struct CurrencySelectionRow: View {
    @Environment(\.themeManager) private var themeManager
    let rate: Rate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(rate.code)
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)

                        Spacer()

                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.amberAccent)
                    }

                    Text(rate.displayName)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
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
