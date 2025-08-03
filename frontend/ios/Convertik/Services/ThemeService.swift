import SwiftUI
import Foundation

// MARK: - Theme Service

/// Сервис для управления темами приложения
class ThemeService: ObservableObject {
    static let shared = ThemeService()
    
    @Published var isDarkMode: Bool = false {
        didSet {
            saveThemePreference()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "app_theme_preference"
    
    private init() {
        loadThemePreference()
    }
    
    // MARK: - Theme Management
    
    /// Загрузка сохраненной темы
    private func loadThemePreference() {
        if userDefaults.object(forKey: themeKey) != nil {
            isDarkMode = userDefaults.bool(forKey: themeKey)
        } else {
            // По умолчанию используем системную тему
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    /// Сохранение выбранной темы
    private func saveThemePreference() {
        userDefaults.set(isDarkMode, forKey: themeKey)
    }
    
    /// Переключение темы
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    /// Установка светлой темы
    func setLightTheme() {
        isDarkMode = false
    }
    
    /// Установка темной темы
    func setDarkTheme() {
        isDarkMode = true
    }
    
    /// Установка системной темы
    func setSystemTheme() {
        isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    // MARK: - Theme Information
    
    /// Получение названия текущей темы
    var currentThemeName: String {
        return isDarkMode ? "Темная" : "Светлая"
    }
    
    /// Получение иконки текущей темы
    var currentThemeIcon: String {
        return isDarkMode ? "moon.fill" : "sun.max.fill"
    }
    
    /// Получение цвета иконки текущей темы
    var currentThemeIconColor: Color {
        return isDarkMode ? .yellow : .orange
    }
}

// MARK: - Theme Environment

/// Расширение для Environment для доступа к сервису тем
struct ThemeServiceKey: EnvironmentKey {
    static let defaultValue = ThemeService.shared
}

extension EnvironmentValues {
    var themeService: ThemeService {
        get { self[ThemeServiceKey.self] }
        set { self[ThemeServiceKey.self] = newValue }
    }
}

// MARK: - Theme Modifier

/// Модификатор для применения темы к представлению
struct ThemeModifier: ViewModifier {
    @ObservedObject var themeService: ThemeService
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeService.isDarkMode ? .dark : .light)
            .environmentObject(themeService)
            .environment(\.themeManager, ThemeManager(themeService: themeService))
    }
}

extension View {
    /// Применение темы к представлению
    func withTheme(_ themeService: ThemeService = .shared) -> some View {
        self.modifier(ThemeModifier(themeService: themeService))
    }
} 