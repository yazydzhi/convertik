import SwiftUI

struct MainListView: View {
    @EnvironmentObject private var ratesRepository: RatesRepository
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared
    @StateObject private var viewModel = MainListViewModel()

    @State private var showingAddCurrency = false
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
                // Список валют с полями ввода
                currencyListSection

                // Баннер рекламы (если не Premium)
                if !settingsService.isPremium {
                    AdBannerView()
                        .frame(height: 50)
                        .onAppear {
                            analyticsService.trackAdImpression(adUnitId: "ca-app-pub-test/banner_main_bottom")
                        }
                }
            }
            .background(themeManager.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Настройки слева
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(themeManager.amberAccent)
                    }
                    .accessibilityIdentifier("settingsButton")
                    .buttonStyle(BorderlessButtonStyle())
                    .allowsHitTesting(true)
                }

                // Название и дата обновления по центру
                ToolbarItem(placement: .principal) {
                    centerTitleView
                }

                // Добавить справа
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCurrency = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(themeManager.amberAccent)
                    }
                    .accessibilityIdentifier("addCurrencyButton")
                    .buttonStyle(BorderlessButtonStyle())
                    .allowsHitTesting(true)
                }
            }
            .refreshable {
                await ratesRepository.syncRemote()
            }
            .sheet(isPresented: $showingAddCurrency) {
                AddCurrencyView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }

            .onAppear {
                analyticsService.trackAppOpen()

                // Загружаем курсы в фоне
                Task {
                    await ratesRepository.syncRemote()
                }
            }
            .allowsHitTesting(true)
            .onAppear {
                analyticsService.trackSettingsOpened()
            }
            .id(themeService.isDarkMode) // Принудительное обновление при изменении темы
    }

    // MARK: - Views

    private var currencyListSection: some View {
        List {
            ForEach(viewModel.displayedCurrencies, id: \.rate.code) { item in
                CurrencyRowView(
                    rate: item.rate,
                    inputAmount: item.inputAmount,
                    isActiveInput: viewModel.activeInputCurrency == item.rate.code,
                    onAmountChange: { amountString in
                        viewModel.updateAmount(amountString, for: item.rate.code)
                    },
                    onFocusChange: { isFocused in
                        if isFocused {
                            viewModel.activeInputCurrency = item.rate.code
                        } else {
                            viewModel.activeInputCurrency = nil
                        }
                    }
                )
                .listRowBackground(themeManager.cardBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                .moveDisabled(item.rate.code == "RUB")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if item.rate.code != "RUB" {
                        Button(role: .destructive) {
                            deleteCurrency(item.rate.code)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .tint(Color(red: 1.0, green: 0.494, blue: 0.373)) // #FF7E5F - первый оттенок градиента
                    }
                }
            }
            .onMove(perform: moveCurrencies)
        }
        .listStyle(PlainListStyle())
    }
    


    private var centerTitleView: some View {
        VStack(spacing: 1) {
            Text("Конвертик")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            if let lastUpdated = ratesRepository.lastUpdated {
                Text(lastUpdated.formattedForDisplay())
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            } else {
                Text("Не обновлено")
                    .font(.caption2)
                    .foregroundColor(ConvertikColors.warning)
            }
            
            // Показываем ошибку соединения если есть
            if let connectionError = ratesRepository.connectionError {
                Text(connectionError)
                    .font(.caption2)
                    .foregroundColor(ConvertikColors.error)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var lastUpdatedView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let lastUpdated = ratesRepository.lastUpdated {
                Text("Обновлено")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)

                Text(lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            } else {
                Text("Не обновлено")
                    .font(.caption)
                    .foregroundColor(ConvertikColors.warning)
            }
                }
    }
    
    // MARK: - Actions
    
    private func moveCurrencies(from source: IndexSet, to destination: Int) {
        // Используем moveCurrency из SettingsService который уже содержит логику защиты RUB
        settingsService.moveCurrency(from: source, to: destination)
        viewModel.updateDisplayedCurrencies()
        
        // Отслеживаем перемещение
        if let sourceIndex = source.first {
            let currency = viewModel.displayedCurrencies[sourceIndex]
            analyticsService.trackCurrencyMoved(currency.rate.code)
        }
    }
    
    private func deleteCurrency(_ code: String) {
        settingsService.removeCurrency(code)
        analyticsService.trackCurrencyRemoved(code)
        viewModel.updateDisplayedCurrencies()
    }

}

#Preview {
    MainListView()
        .environmentObject(RatesRepository.shared)
        .environmentObject(SettingsService.shared)
        // .environmentObject(ThemeService.shared)
        // .environmentObject(ThemeManager())
}
