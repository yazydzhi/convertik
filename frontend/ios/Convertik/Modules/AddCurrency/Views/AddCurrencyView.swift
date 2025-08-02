import SwiftUI
import os

struct AddCurrencyView: View {
    @EnvironmentObject var ratesRepository: RatesRepository
    @EnvironmentObject var settingsService: SettingsService
    @EnvironmentObject var analyticsService: AnalyticsService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var isLoading = false
    
    private let logger = Logger(subsystem: "com.azg.Convertik", category: "AddCurrencyView")

    private var availableRates: [Rate] {
        ratesRepository.rates.filter { rate in
            !settingsService.userCurrencies.contains(rate.code) &&
                (searchText.isEmpty ||
                    rate.code.localizedCaseInsensitiveContains(searchText) ||
                    rate.displayName.localizedCaseInsensitiveContains(searchText))
        }.sorted { $0.code < $1.code }
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Загрузка валют...")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        SearchBar(text: $searchText, placeholder: "Поиск валют")
                        
                        List(availableRates, id: \.code) { rate in
                            Button(action: { addCurrency(rate) }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(rate.code).font(.headline)
                                        Text(rate.displayName).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("\(rate.value, specifier: "%.2f")").font(.caption).foregroundColor(.secondary)
                                }
                            }.buttonStyle(PlainButtonStyle())
                        }
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
                }
            }
        }
        .onAppear {
            Task {
                await ratesRepository.syncRemote()
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

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
