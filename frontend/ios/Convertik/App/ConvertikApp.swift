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
        
        // Проверяем наличие GADApplicationIdentifier в Info.plist
        if let appID = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String {
            print("✅ GADApplicationIdentifier found in Info.plist: \(appID)")
        } else {
            print("❌ WARNING: GADApplicationIdentifier NOT found in Info.plist!")
            print("❌ This will cause Google Mobile Ads SDK initialization to fail!")
        }
        
        // НЕ инициализируем AdMob здесь - отложим до onAppear для быстрого запуска UI
        // Инициализация будет выполнена асинхронно после показа интерфейса
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
                    // Оптимизированный порядок инициализации для быстрого запуска:
                    // 1. UI показывается сразу (уже произошло)
                    // 2. Локальные данные уже загружены (RatesRepository.loadLocalRates)
                    // 3. Инициализируем AdMob через 3 секунды (не блокирует UI)
                    // 4. Проверяем подписку через 2 секунды
                    // 5. Синхронизация данных запускается из RatesRepository через 1 секунду
                    
                    // Инициализация AdMob SDK (отложена для быстрого запуска UI)
                    // Уменьшено до 1.5 секунд для более быстрой загрузки рекламы
                    Task.detached {
                        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 секунды (было 3)
                        await MainActor.run {
                            print("📱 Initializing AdMob SDK (delayed for fast UI launch)...")
                            MobileAds.shared.start { status in
                                #if DEBUG
                                print("🔧 Google Mobile Ads SDK initialization status: \(status)")
                                print("🔧 AdMob App ID from AdConfig: \(AdConfig.appID)")
                                print("🔧 Banner Ad Unit ID: \(AdConfig.Banner.mainBottom)")
                                print("🔧 Interstitial Ad Unit ID: \(AdConfig.Interstitial.main)")
                                #else
                                print("🚀 Google Mobile Ads SDK initialization status: \(status)")
                                print("🚀 AdMob App ID from AdConfig: \(AdConfig.appID)")
                                print("🚀 Banner Ad Unit ID: \(AdConfig.Banner.mainBottom)")
                                print("🚀 Interstitial Ad Unit ID: \(AdConfig.Interstitial.main)")
                                #endif
                                
                                // После инициализации AdMob запускаем загрузку рекламы
                                adService.initializeAds()
                                
                                // Также инициализируем InterstitialAdService
                                InterstitialAdService.shared.initializeAd()
                            }
                        }
                    }
                    
                    // Проверяем статус подписки тихо без принудительной авторизации с задержкой
                    Task.detached {
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
