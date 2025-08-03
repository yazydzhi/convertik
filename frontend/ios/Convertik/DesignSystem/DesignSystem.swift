import SwiftUI

// MARK: - Design System for Convertik
// Версия: 3.0
// Описание: Полная дизайн-система с поддержкой светлой и темной тем
// Палитра: Velvet Sunset

// MARK: - Color Palette

/// Основная цветовая палитра приложения с поддержкой тем
/// Палитра Velvet Sunset - футуристичная палитра, вдохновлённая закатными оттенками
struct ConvertikColors {
    
    // MARK: - Accent Colors (Акцентные цвета - одинаковые для обеих тем)
    
    /// Основной акцентный градиент - от кораллового к розовому
    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 1.000, green: 0.494, blue: 0.373), // #FF7E5F
            Color(red: 0.992, green: 0.227, blue: 0.518)  // #FD3A84
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Дополнительный акцент - янтарный
    static let amberAccent = Color(red: 0.973, green: 0.706, blue: 0.000) // #F8B400
    
    /// Акцент для выделения - сиреневый
    static let lilacHighlight = Color(red: 0.753, green: 0.518, blue: 0.988) // #C084FC
    
    // MARK: - Success Colors (Цвета успеха - одинаковые для обеих тем)
    
    /// Зеленый для положительных изменений курса
    static let success = Color(red: 0.200, green: 0.780, blue: 0.350)
    
    /// Светло-зеленый для фона успешных операций (светлая тема)
    static let successLight = Color(red: 0.200, green: 0.780, blue: 0.350).opacity(0.1)
    
    /// Темно-зеленый для фона успешных операций (темная тема)
    static let successDark = Color(red: 0.200, green: 0.780, blue: 0.350).opacity(0.2)
    
    // MARK: - Warning Colors (Цвета предупреждения - одинаковые для обеих тем)
    
    /// Оранжевый для предупреждений
    static let warning = Color(red: 1.000, green: 0.584, blue: 0.000)
    
    /// Светло-оранжевый для фона предупреждений (светлая тема)
    static let warningLight = Color(red: 1.000, green: 0.584, blue: 0.000).opacity(0.1)
    
    /// Темно-оранжевый для фона предупреждений (темная тема)
    static let warningDark = Color(red: 1.000, green: 0.584, blue: 0.000).opacity(0.2)
    
    // MARK: - Error Colors (Цвета ошибок - одинаковые для обеих тем)
    
    /// Красный для ошибок и отрицательных изменений
    static let error = Color(red: 0.922, green: 0.231, blue: 0.231)
    
    /// Светло-красный для фона ошибок (светлая тема)
    static let errorLight = Color(red: 0.922, green: 0.231, blue: 0.231).opacity(0.1)
    
    /// Темно-красный для фона ошибок (темная тема)
    static let errorDark = Color(red: 0.922, green: 0.231, blue: 0.231).opacity(0.2)
    
    // MARK: - Light Theme Colors (Цвета светлой темы - Velvet Sunset)
    
    /// Основной фон (светлая тема) - мягкий тон, напоминающий рассвет
    static let backgroundLight = Color(red: 0.992, green: 0.976, blue: 0.976) // #FDF9F9
    
    /// Фон карточек (светлая тема) - нейтральная поверхность
    static let cardBackgroundLight = Color.white // #FFFFFF
    
    /// Основной текст (светлая тема)
    static let textPrimaryLight = Color(red: 0.267, green: 0.235, blue: 0.298) // #443C4C
    
    /// Вторичный текст (светлая тема)
    static let textSecondaryLight = Color(red: 0.424, green: 0.337, blue: 0.431) // #6C566E
    
    /// Третичный текст (подсказки) (светлая тема)
    static let textTertiaryLight = Color(red: 0.600, green: 0.600, blue: 0.600)
    
    /// Разделители (светлая тема) - гармонично контрастирует с фоном
    static let separatorLight = Color(red: 0.918, green: 0.886, blue: 0.937) // #EAE2EF
    
    /// Фон для выделенных элементов (светлая тема)
    static let selectedBackgroundLight = Color(red: 0.949, green: 0.949, blue: 0.949)
    
    /// Фон для интерактивных элементов (светлая тема)
    static let interactiveBackgroundLight = Color(red: 0.960, green: 0.960, blue: 0.960)
    
    // MARK: - Dark Theme Colors (Цвета темной темы - Velvet Sunset)
    
    /// Основной фон (темная тема) - более темный и холодный фон для лучшего контраста
    static let backgroundDark = Color(red: 0.102, green: 0.071, blue: 0.141) // #1A1324
    
    /// Фон карточек (темная тема) - более темные карточки для лучшего контраста
    static let cardBackgroundDark = Color(red: 0.110, green: 0.086, blue: 0.149) // #1C1626
    
    /// Фон карточек при наведении или выборе (темная тема)
    static let cardHoverDark = Color(red: 0.125, green: 0.098, blue: 0.165) // #201A2A
    
    /// Основной текст (темная тема) - светлый текст на тёмном фоне
    static let textPrimaryDark = Color(red: 0.894, green: 0.863, blue: 0.910) // #E4DCE8
    
    /// Вторичный текст (темная тема) - приглушённый вторичный текст
    static let textSecondaryDark = Color(red: 0.710, green: 0.686, blue: 0.753) // #B5AFC0
    
    /// Третичный текст (подсказки) (темная тема)
    static let textTertiaryDark = Color(red: 0.533, green: 0.533, blue: 0.533)
    
    /// Разделители (темная тема) - тонкие разделители между элементами
    static let separatorDark = Color(red: 0.227, green: 0.196, blue: 0.267) // #3A3244
    
    /// Фон для выделенных элементов (темная тема)
    static let selectedBackgroundDark = Color(red: 0.200, green: 0.200, blue: 0.200)
    
    /// Фон для интерактивных элементов (темная тема)
    static let interactiveBackgroundDark = Color(red: 0.150, green: 0.150, blue: 0.150)
    
    // MARK: - Legacy Colors (для обратной совместимости)
    
    /// @deprecated Используйте ThemeManager для получения цветов
    static let textPrimary = textPrimaryLight
    static let textSecondary = textSecondaryLight
    static let textTertiary = textTertiaryLight
    static let separator = separatorLight
    static let cardBackground = cardBackgroundLight
    static let background = backgroundLight
    static let selectedBackground = selectedBackgroundLight
    
    // MARK: - Legacy Primary Colors (для обратной совместимости)
    
    /// @deprecated Используйте accentGradient
    static let primary = Color(red: 0.133, green: 0.267, blue: 0.533)
    static let accent = Color(red: 0.000, green: 0.478, blue: 1.000)
    static let secondary = Color(red: 0.000, green: 0.647, blue: 0.647)
}

// MARK: - Theme Manager

/// Менеджер тем для приложения
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    /// Ссылка на ThemeService для синхронизации
    private var themeService: ThemeService?
    
    /// Инициализация с ThemeService
    init(themeService: ThemeService? = nil) {
        self.themeService = themeService
        self.isDarkMode = themeService?.isDarkMode ?? false
    }
    
    /// Обновление состояния из ThemeService
    func updateFromThemeService(_ themeService: ThemeService) {
        self.themeService = themeService
        self.isDarkMode = themeService.isDarkMode
    }
    
    /// Получение цвета с учетом текущей темы
    func color(_ lightColor: Color, darkColor: Color) -> Color {
        return isDarkMode ? darkColor : lightColor
    }
    
    /// Получение цвета текста
    var textPrimary: Color {
        color(ConvertikColors.textPrimaryLight, darkColor: ConvertikColors.textPrimaryDark)
    }
    
    var textSecondary: Color {
        color(ConvertikColors.textSecondaryLight, darkColor: ConvertikColors.textSecondaryDark)
    }
    
    var textTertiary: Color {
        color(ConvertikColors.textTertiaryLight, darkColor: ConvertikColors.textTertiaryDark)
    }
    
    /// Получение цвета фона
    var background: Color {
        color(ConvertikColors.backgroundLight, darkColor: ConvertikColors.backgroundDark)
    }
    
    var cardBackground: Color {
        color(ConvertikColors.cardBackgroundLight, darkColor: ConvertikColors.cardBackgroundDark)
    }
    
    var cardHover: Color {
        color(ConvertikColors.cardBackgroundLight, darkColor: ConvertikColors.cardHoverDark)
    }
    
    var selectedBackground: Color {
        color(ConvertikColors.selectedBackgroundLight, darkColor: ConvertikColors.selectedBackgroundDark)
    }
    
    var interactiveBackground: Color {
        color(ConvertikColors.interactiveBackgroundLight, darkColor: ConvertikColors.interactiveBackgroundDark)
    }
    
    var separator: Color {
        color(ConvertikColors.separatorLight, darkColor: ConvertikColors.separatorDark)
    }
    
    /// Получение цвета для состояний
    var successBackground: Color {
        color(ConvertikColors.successLight, darkColor: ConvertikColors.successDark)
    }
    
    var warningBackground: Color {
        color(ConvertikColors.warningLight, darkColor: ConvertikColors.warningDark)
    }
    
    var errorBackground: Color {
        color(ConvertikColors.errorLight, darkColor: ConvertikColors.errorDark)
    }
    
    /// Получение акцентных цветов
    var accentGradient: LinearGradient {
        ConvertikColors.accentGradient
    }
    
    var amberAccent: Color {
        ConvertikColors.amberAccent
    }
    
    var lilacHighlight: Color {
        ConvertikColors.lilacHighlight
    }
    
    /// Градиент для карточек (как на фоне значка)
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.110, green: 0.086, blue: 0.149), // #1C1626
                Color(red: 0.125, green: 0.098, blue: 0.165)  // #201A2A
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Фон карточки с учетом состояния
    func cardBackground(isSelected: Bool = false) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(lilacHighlight.opacity(0.15))
        } else {
            // В темной теме используем градиент, в светлой - обычный цвет
            if isDarkMode {
                return AnyShapeStyle(cardGradient)
            } else {
                return AnyShapeStyle(cardBackground)
            }
        }
    }
    
    /// Цвет для легкого свечения карточек (как точки на значке)
    var cardGlowColor: Color {
        Color(red: 0.973, green: 0.706, blue: 0.000, opacity: 0.1) // #F8B400 с низкой прозрачностью
    }
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
    
    /// Легкая тень для карточек (светлая тема)
    static let light = Shadow(
        color: Color.black.opacity(0.05),
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Средняя тень для модальных окон (светлая тема)
    static let medium = Shadow(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Сильная тень для важных элементов (светлая тема)
    static let heavy = Shadow(
        color: Color.black.opacity(0.15),
        radius: 12,
        x: 0,
        y: 6
    )
    
    /// Легкая тень для карточек (темная тема)
    static let lightDark = Shadow(
        color: Color.white.opacity(0.05),
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Средняя тень для модальных окон (темная тема)
    static let mediumDark = Shadow(
        color: Color.white.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Сильная тень для важных элементов (темная тема)
    static let heavyDark = Shadow(
        color: Color.white.opacity(0.15),
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
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

/// Основной класс дизайн-системы (для обратной совместимости)
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
        color(ConvertikColors.textPrimaryLight, darkColor: ConvertikColors.textPrimaryDark)
    }
    
    var textSecondary: Color {
        color(ConvertikColors.textSecondaryLight, darkColor: ConvertikColors.textSecondaryDark)
    }
    
    var textTertiary: Color {
        color(ConvertikColors.textTertiaryLight, darkColor: ConvertikColors.textTertiaryDark)
    }
    
    /// Получение цвета фона
    var background: Color {
        color(ConvertikColors.backgroundLight, darkColor: ConvertikColors.backgroundDark)
    }
    
    var cardBackground: Color {
        color(ConvertikColors.cardBackgroundLight, darkColor: ConvertikColors.cardBackgroundDark)
    }
    
    var separator: Color {
        color(ConvertikColors.separatorLight, darkColor: ConvertikColors.separatorDark)
    }
} 