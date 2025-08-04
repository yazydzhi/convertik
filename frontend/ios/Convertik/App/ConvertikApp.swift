import SwiftUI
import GoogleMobileAds

@main
struct ConvertikApp: App {
    @StateObject private var themeService = ThemeService.shared
    @StateObject private var settingsService = SettingsService.shared
    @StateObject private var ratesRepository = RatesRepository.shared
    @StateObject private var adService = AdService.shared
    @StateObject private var storeService = StoreService.shared

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
                .environment(\.themeManager, ThemeManager(themeService: themeService))
                .preferredColorScheme(themeService.isDarkMode ? .dark : .light)
        }
    }
}
