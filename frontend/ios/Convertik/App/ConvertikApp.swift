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
        MobileAds.shared.start { status in
            print("Google Mobile Ads SDK initialization status: \(status)")
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
