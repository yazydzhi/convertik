import SwiftUI
import GoogleMobileAds

@main
struct ConvertikApp: App {
    @StateObject private var themeService = ThemeService.shared
    @StateObject private var settingsService = SettingsService.shared
    @StateObject private var ratesRepository = RatesRepository.shared
    @StateObject private var adService = AdService.shared
    @StateObject private var storeService = StoreService.shared
    @StateObject private var analyticsService = AnalyticsService.shared

    init() {
        // Настройка тестовых устройств для AdMob
        #if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "2077ef9a63d2b398840261c8221a0c9b", // Симулятор iOS
            "00000000-0000-0000-0000-000000000000" // Дополнительный тестовый ID
        ]
        #endif
        
        MobileAds.shared.start { status in
            print("🚀 Google Mobile Ads SDK initialization status: \(status)")
            print("🚀 AdMob App ID: \(AdConfig.appID)")
            print("🚀 Banner Ad Unit ID: \(AdConfig.Banner.mainBottom)")
            print("🚀 Interstitial Ad Unit ID: \(AdConfig.Interstitial.main)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeService)
                .environmentObject(settingsService)
                .environmentObject(ratesRepository)
                .environmentObject(adService)
                .environmentObject(storeService)
                .environmentObject(analyticsService)
                .environment(\.themeManager, ThemeManager(themeService: themeService))
                .preferredColorScheme(themeService.isDarkMode ? .dark : .light)
                .onAppear {
                    // Принудительно проверяем статус подписки при запуске
                    Task {
                        do {
                            try await storeService.restorePurchases()
                        } catch {
                            print("Failed to restore purchases: \(error)")
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Отправляем накопленные события при переходе в фоновый режим
                    Task {
                        await analyticsService.sendQueuedEvents()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // Отправляем накопленные события при закрытии приложения
                    Task {
                        await analyticsService.sendQueuedEvents()
                    }
                }
        }
    }
}
