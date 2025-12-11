import SwiftUI

struct MainListView: View {
    @EnvironmentObject private var ratesRepository: RatesRepository
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var storeService: StoreService
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared
    @StateObject private var viewModel = MainListViewModel()
    @StateObject private var interstitialService = InterstitialAdService.shared

    @State private var showingAddCurrency = false
    @State private var showingSettings = false
    @State private var adTriggerCount = 0

    var body: some View {
        VStack(spacing: 0) {
                // Список валют с полями ввода
                currencyListSection

                // Баннер рекламы (если не Ads Free)
                if !storeService.isPremium {
                    AdBannerContainerView()
                        .onAppear {
                            analyticsService.trackAdImpression(adUnitId: "ca-app-pub-3940256099942544/2934735716")
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
                        triggerAdIfNeeded {
                            showingAddCurrency = true
                        }
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
                // НЕ запускаем синхронизацию здесь - она уже запускается из RatesRepository.init()
                // Это предотвращает множественные синхронизации и зависания UI
            }
            .allowsHitTesting(true)
            .onAppear {
                analyticsService.trackSettingsOpened()
            }
            .onChange(of: themeService.isDarkMode) { _ in
                // Принудительно обновляем ThemeManager
                themeManager.refreshTheme()
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
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 20))
                .moveDisabled(item.rate.code == "RUB")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if item.rate.code != "RUB" {
                        Button(role: .destructive) {
                            triggerAdIfNeeded {
                                deleteCurrency(item.rate.code)
                            }
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

    // MARK: - Ad Logic

    private func triggerAdIfNeeded(action: @escaping () -> Void) {
        adTriggerCount += 1

        // Показываем рекламу каждые 3 действия (если не Ads Free)
        if !storeService.isPremium && adTriggerCount % 3 == 0 && interstitialService.isReady {
            // Получаем root view controller для показа рекламы
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                interstitialService.showAd(from: rootViewController) {
                    // Выполняем действие на главном потоке с небольшой задержкой
                    // чтобы UI успел обновиться после закрытия рекламы
                    Task { @MainActor in
                        // Дополнительная задержка для стабилизации UI
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
                        action()
                    }
                }
            } else {
                action()
            }
        } else {
            action()
        }
    }

}

#Preview {
    MainListView()
        .environmentObject(RatesRepository.shared)
        .environmentObject(SettingsService.shared)
        // .environmentObject(ThemeService.shared)
        // .environmentObject(ThemeManager())
}
