import SwiftUI

@main
struct ConvertikApp: App {
    @StateObject private var themeService = ThemeService.shared
    @StateObject private var settingsService = SettingsService.shared
    @StateObject private var ratesRepository = RatesRepository.shared

    init() {
        // Только для тестов: если есть аргумент — применить, иначе не трогать стиль
        let arguments = ProcessInfo.processInfo.arguments
        if let idx = arguments.firstIndex(of: "-uiuserInterfaceStyle"), arguments.count > idx + 1 {
            let style = arguments[idx + 1]
            if style == "dark" {
                UIView.appearance().overrideUserInterfaceStyle = .dark
            } else if style == "light" {
                UIView.appearance().overrideUserInterfaceStyle = .light
            }
        } else if let idx = arguments.firstIndex(of: "-AppleInterfaceStyle"), arguments.count > idx + 1 {
            let style = arguments[idx + 1]
            if style.lowercased() == "dark" {
                UIView.appearance().overrideUserInterfaceStyle = .dark
            } else if style.lowercased() == "light" {
                UIView.appearance().overrideUserInterfaceStyle = .light
            }
        } // иначе не трогаем стиль — пусть работает toggle/ThemeService
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsService)
                .environmentObject(ratesRepository)
                .environmentObject(themeService)
                .withTheme(themeService)
        }
    }
}
