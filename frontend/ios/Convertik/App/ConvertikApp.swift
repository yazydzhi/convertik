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
        #if DEBUG
        print("🔧 ConvertikApp: Running in DEBUG mode")
        // Настройка тестовых устройств для AdMob
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "2077ef9a63d2b398840261c8221a0c9b", // Симулятор iOS
            "00000000-0000-0000-0000-000000000000" // Дополнительный тестовый ID
        ]
        #else
        print("🚀 ConvertikApp: Running in RELEASE mode")
        #endif
        
        MobileAds.shared.start { status in
            #if DEBUG
            print("🔧 Google Mobile Ads SDK initialization status: \(status)")
            print("🔧 AdMob App ID: \(AdConfig.appID)")
            print("🔧 Banner Ad Unit ID: \(AdConfig.Banner.mainBottom)")
            print("🔧 Interstitial Ad Unit ID: \(AdConfig.Interstitial.main)")
            #else
            print("🚀 Google Mobile Ads SDK initialization status: \(status)")
            print("🚀 AdMob App ID: \(AdConfig.appID)")
            print("🚀 Banner Ad Unit ID: \(AdConfig.Banner.mainBottom)")
            print("🚀 Interstitial Ad Unit ID: \(AdConfig.Interstitial.main)")
            #endif
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
                    // Проверяем статус подписки тихо без принудительной авторизации с задержкой
                    Task.detached {
                        // Добавляем задержку чтобы UI успел загрузиться
                        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
                        await storeService.checkSubscriptionSilently()
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
