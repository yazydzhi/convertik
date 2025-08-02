import SwiftUI

// MARK: - Design System for Convertik
// Версия: 1.1
// Описание: Полная дизайн-система для приложения конвертации валют

// MARK: - Color Palette

/// Основная цветовая палитра приложения
struct ConvertikColors {
    
    // MARK: - Primary Colors (Основные цвета)
    
    /// Основной брендовый цвет - глубокий синий
    static let primary = Color(red: 0.133, green: 0.267, blue: 0.533)
    
    /// Акцентный цвет - яркий синий
    static let accent = Color(red: 0.000, green: 0.478, blue: 1.000)
    
    /// Дополнительный акцент - бирюзовый
    static let secondary = Color(red: 0.000, green: 0.647, blue: 0.647)
    
    // MARK: - Success Colors (Цвета успеха)
    
    /// Зеленый для положительных изменений курса
    static let success = Color(red: 0.200, green: 0.780, blue: 0.350)
    
    /// Светло-зеленый для фона успешных операций
    static let successLight = Color(red: 0.200, green: 0.780, blue: 0.350).opacity(0.1)
    
    // MARK: - Warning Colors (Цвета предупреждения)
    
    /// Оранжевый для предупреждений
    static let warning = Color(red: 1.000, green: 0.584, blue: 0.000)
    
    /// Светло-оранжевый для фона предупреждений
    static let warningLight = Color(red: 1.000, green: 0.584, blue: 0.000).opacity(0.1)
    
    // MARK: - Error Colors (Цвета ошибок)
    
    /// Красный для ошибок и отрицательных изменений
    static let error = Color(red: 0.922, green: 0.231, blue: 0.231)
    
    /// Светло-красный для фона ошибок
    static let errorLight = Color(red: 0.922, green: 0.231, blue: 0.231).opacity(0.1)
    
    // MARK: - Neutral Colors (Нейтральные цвета)
    
    /// Основной текст
    static let textPrimary = Color(red: 0.133, green: 0.133, blue: 0.133)
    
    /// Вторичный текст
    static let textSecondary = Color(red: 0.467, green: 0.467, blue: 0.467)
    
    /// Третичный текст (подсказки)
    static let textTertiary = Color(red: 0.600, green: 0.600, blue: 0.600)
    
    /// Разделители
    static let separator = Color(red: 0.867, green: 0.867, blue: 0.867)
    
    /// Фон карточек
    static let cardBackground = Color.white
    
    /// Основной фон приложения
    static let background = Color(red: 0.976, green: 0.976, blue: 0.976)
    
    /// Фон для выделенных элементов
    static let selectedBackground = Color(red: 0.949, green: 0.949, blue: 0.949)
    
    // MARK: - Dark Mode Colors
    
    /// Основной текст в темной теме
    static let textPrimaryDark = Color.white
    
    /// Вторичный текст в темной теме
    static let textSecondaryDark = Color(red: 0.733, green: 0.733, blue: 0.733)
    
    /// Третичный текст в темной теме
    static let textTertiaryDark = Color(red: 0.533, green: 0.533, blue: 0.533)
    
    /// Разделители в темной теме
    static let separatorDark = Color(red: 0.267, green: 0.267, blue: 0.267)
    
    /// Фон карточек в темной теме
    static let cardBackgroundDark = Color(red: 0.133, green: 0.133, blue: 0.133)
    
    /// Основной фон в темной теме
    static let backgroundDark = Color.black
    
    /// Фон для выделенных элементов в темной теме
    static let selectedBackgroundDark = Color(red: 0.200, green: 0.200, blue: 0.200)
}

// MARK: - Typography

/// Типографическая система приложения
struct ConvertikTypography {
    
    // MARK: - Font Sizes
    
    /// Очень большой заголовок (название приложения)
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// Большой заголовок (заголовки экранов)
    static let title1 = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    /// Средний заголовок (заголовки секций)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    
    /// Малый заголовок (заголовки карточек)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    /// Заголовок (заголовки списков)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    /// Основной текст
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    
    /// Вторичный текст
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    
    /// Подзаголовок
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    
    /// Мелкий текст
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    
    /// Очень мелкий текст
    static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
    
    /// Микро текст
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // MARK: - Currency Specific Typography
    
    /// Специальный шрифт для отображения валют
    static let currencyAmount = Font.system(size: 24, weight: .medium, design: .rounded)
    
    /// Специальный шрифт для кодов валют
    static let currencyCode = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    /// Специальный шрифт для названий валют
    static let currencyName = Font.system(size: 14, weight: .regular, design: .rounded)
}

// MARK: - Spacing

/// Система отступов
struct ConvertikSpacing {
    
    /// Очень маленький отступ (4pt)
    static let xs: CGFloat = 4
    
    /// Маленький отступ (8pt)
    static let sm: CGFloat = 8
    
    /// Средний отступ (12pt)
    static let md: CGFloat = 12
    
    /// Большой отступ (16pt)
    static let lg: CGFloat = 16
    
    /// Очень большой отступ (20pt)
    static let xl: CGFloat = 20
    
    /// Огромный отступ (24pt)
    static let xxl: CGFloat = 24
    
    /// Максимальный отступ (32pt)
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius

/// Система скругления углов
struct ConvertikCornerRadius {
    
    /// Маленькое скругление (6pt)
    static let sm: CGFloat = 6
    
    /// Среднее скругление (12pt)
    static let md: CGFloat = 12
    
    /// Большое скругление (16pt)
    static let lg: CGFloat = 16
    
    /// Очень большое скругление (20pt)
    static let xl: CGFloat = 20
    
    /// Максимальное скругление (28pt)
    static let xxl: CGFloat = 28
    
    /// Круглое скругление (50%)
    static let round: CGFloat = 50
}

// MARK: - Shadows

/// Система теней
struct ConvertikShadows {
    
    /// Легкая тень для карточек
    static let light = Shadow(
        color: Color.black.opacity(0.05),
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Средняя тень для модальных окон
    static let medium = Shadow(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Сильная тень для важных элементов
    static let heavy = Shadow(
        color: Color.black.opacity(0.15),
        radius: 12,
        x: 0,
        y: 6
    )
}

/// Структура для определения тени
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation

/// Система анимаций
struct ConvertikAnimation {
    
    /// Быстрая анимация (0.2s)
    static let fast = Animation.easeInOut(duration: 0.2)
    
    /// Средняя анимация (0.3s)
    static let medium = Animation.easeInOut(duration: 0.3)
    
    /// Медленная анимация (0.5s)
    static let slow = Animation.easeInOut(duration: 0.5)
    
    /// Пружинная анимация для интерактивных элементов
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - Environment Values

/// Расширение для Environment для доступа к дизайн-системе
struct DesignSystemKey: EnvironmentKey {
    static let defaultValue = DesignSystem()
}

extension EnvironmentValues {
    var designSystem: DesignSystem {
        get { self[DesignSystemKey.self] }
        set { self[DesignSystemKey.self] = newValue }
    }
}

/// Основной класс дизайн-системы
class DesignSystem: ObservableObject {
    
    @Published var isDarkMode: Bool = false
    
    /// Получение цвета с учетом темы
    func color(_ lightColor: Color, darkColor: Color? = nil) -> Color {
        if isDarkMode {
            return darkColor ?? lightColor
        }
        return lightColor
    }
    
    /// Получение цвета текста
    var textPrimary: Color {
        color(ConvertikColors.textPrimary, darkColor: ConvertikColors.textPrimaryDark)
    }
    
    var textSecondary: Color {
        color(ConvertikColors.textSecondary, darkColor: ConvertikColors.textSecondaryDark)
    }
    
    var textTertiary: Color {
        color(ConvertikColors.textTertiary, darkColor: ConvertikColors.textTertiaryDark)
    }
    
    /// Получение цвета фона
    var background: Color {
        color(ConvertikColors.background, darkColor: ConvertikColors.backgroundDark)
    }
    
    var cardBackground: Color {
        color(ConvertikColors.cardBackground, darkColor: ConvertikColors.cardBackgroundDark)
    }
    
    var separator: Color {
        color(ConvertikColors.separator, darkColor: ConvertikColors.separatorDark)
    }
} 