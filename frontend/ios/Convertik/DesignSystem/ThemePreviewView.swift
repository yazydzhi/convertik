import SwiftUI

// MARK: - Theme Preview View

/// Демонстрационный экран для показа светлой и темной тем
/// Палитра Velvet Sunset - футуристичная палитра, вдохновлённая закатными оттенками
struct ThemePreviewView: View {
    @StateObject private var lightThemeManager = ThemeManager()
    @StateObject private var darkThemeManager = ThemeManager()
    
    init() {
        lightThemeManager.isDarkMode = false
        darkThemeManager.isDarkMode = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ConvertikSpacing.xxl) {
                    
                    // Заголовок
                    Text("Демонстрация тем")
                        .font(ConvertikTypography.title1)
                        .foregroundColor(.primary)
                        .padding(.top, ConvertikSpacing.xl)
                    
                    // Описание
                    Text("Сравнение светлой и темной тем для приложения Convertik\nПалитра Velvet Sunset")
                        .font(ConvertikTypography.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ConvertikSpacing.xl)
                    
                    // Светлая тема
                    ThemeSection(
                        title: "Светлая тема",
                        themeManager: lightThemeManager,
                        backgroundColor: ConvertikColors.backgroundLight
                    )
                    
                    // Темная тема
                    ThemeSection(
                        title: "Темная тема",
                        themeManager: darkThemeManager,
                        backgroundColor: ConvertikColors.backgroundDark
                    )
                }
                .padding(.bottom, ConvertikSpacing.xxxl)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Velvet Sunset")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Theme Section

struct ThemeSection: View {
    let title: String
    let themeManager: ThemeManager
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.lg) {
            Text(title)
                .font(ConvertikTypography.title2)
                .foregroundColor(.primary)
                .padding(.horizontal, ConvertikSpacing.xl)
            
            VStack(spacing: ConvertikSpacing.md) {
                // Карточки валют
                CurrencyCard(
                    currencyCode: "USD",
                    currencyName: "US Dollar",
                    amount: "1,234.56",
                    changePercent: 2.5,
                    isSelected: false
                ) { }
                .environmentObject(themeManager)
                
                CurrencyCard(
                    currencyCode: "EUR",
                    currencyName: "Euro",
                    amount: "987.65",
                    changePercent: -1.2,
                    isSelected: true
                ) { }
                .environmentObject(themeManager)
                
                // Поле ввода
                AmountInputField(
                    amount: .constant("100"),
                    placeholder: "Введите сумму",
                    currencyCode: "RUB"
                )
                .environmentObject(themeManager)
                
                // Поисковая строка
                ConvertikSearchBar(
                    text: .constant(""),
                    placeholder: "Поиск валют"
                )
                .environmentObject(themeManager)
                
                // Кнопки
                VStack(spacing: ConvertikSpacing.sm) {
                    ConvertikButton("Основная кнопка") { }
                        .environmentObject(themeManager)
                    
                    ConvertikButton("Вторичная кнопка", style: .secondary) { }
                        .environmentObject(themeManager)
                    
                    ConvertikButton("Кнопка удаления", style: .destructive) { }
                        .environmentObject(themeManager)
                }
                
                // Бейджи
                HStack(spacing: ConvertikSpacing.md) {
                    ConvertikBadge("Новое")
                        .environmentObject(themeManager)
                    
                    ConvertikBadge("Обновлено", color: ConvertikColors.success)
                        .environmentObject(themeManager)
                    
                    ConvertikBadge("Ошибка", color: ConvertikColors.error)
                        .environmentObject(themeManager)
                }
                
                // Переключатель темы
                ThemeToggleView()
                    .environmentObject(themeManager)
            }
            .padding(ConvertikSpacing.lg)
            .background(backgroundColor)
            .cornerRadius(ConvertikCornerRadius.lg)
            .padding(.horizontal, ConvertikSpacing.xl)
        }
    }
}

// MARK: - Color Palette Preview

/// Демонстрация цветовой палитры для обеих тем
/// Палитра Velvet Sunset
struct ColorPalettePreviewView: View {
    @StateObject private var lightThemeManager = ThemeManager()
    @StateObject private var darkThemeManager = ThemeManager()
    
    init() {
        lightThemeManager.isDarkMode = false
        darkThemeManager.isDarkMode = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ConvertikSpacing.xxl) {
                    
                    // Светлая тема
                    ColorPaletteSection(
                        title: "Цвета светлой темы",
                        themeManager: lightThemeManager,
                        backgroundColor: ConvertikColors.backgroundLight
                    )
                    
                    // Темная тема
                    ColorPaletteSection(
                        title: "Цвета темной темы",
                        themeManager: darkThemeManager,
                        backgroundColor: ConvertikColors.backgroundDark
                    )
                }
                .padding(.vertical, ConvertikSpacing.xl)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Velvet Sunset Palette")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ColorPaletteSection: View {
    let title: String
    let themeManager: ThemeManager
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.lg) {
            Text(title)
                .font(ConvertikTypography.title2)
                .foregroundColor(.primary)
                .padding(.horizontal, ConvertikSpacing.xl)
            
            VStack(spacing: ConvertikSpacing.md) {
                // Акцентные цвета
                ColorPaletteRow(
                    title: "Акцентные цвета",
                    colors: [
                        ColorPaletteItem("Amber Accent", ConvertikColors.amberAccent),
                        ColorPaletteItem("Lilac Highlight", ConvertikColors.lilacHighlight)
                    ],
                    gradients: [
                        ColorPaletteGradientItem("Accent Gradient", ConvertikColors.accentGradient)
                    ]
                )
                
                // Семантические цвета
                ColorPaletteRow(
                    title: "Семантические цвета",
                    colors: [
                        ColorPaletteItem("Success", ConvertikColors.success),
                        ColorPaletteItem("Warning", ConvertikColors.warning),
                        ColorPaletteItem("Error", ConvertikColors.error)
                    ]
                )
                
                // Цвета текста
                ColorPaletteRow(
                    title: "Цвета текста",
                    colors: [
                        ColorPaletteItem("Primary", themeManager.textPrimary),
                        ColorPaletteItem("Secondary", themeManager.textSecondary),
                        ColorPaletteItem("Tertiary", themeManager.textTertiary)
                    ]
                )
                
                // Цвета фона
                ColorPaletteRow(
                    title: "Цвета фона",
                    colors: [
                        ColorPaletteItem("Background", themeManager.background),
                        ColorPaletteItem("Card", themeManager.cardBackground),
                        ColorPaletteItem("Card Hover", themeManager.cardHover),
                        ColorPaletteItem("Interactive", themeManager.interactiveBackground)
                    ]
                )
            }
            .padding(ConvertikSpacing.lg)
            .background(backgroundColor)
            .cornerRadius(ConvertikCornerRadius.lg)
            .padding(.horizontal, ConvertikSpacing.xl)
        }
    }
}

struct ColorPaletteRow: View {
    let title: String
    let colors: [ColorPaletteItem]
    let gradients: [ColorPaletteGradientItem]
    
    init(title: String, colors: [ColorPaletteItem], gradients: [ColorPaletteGradientItem] = []) {
        self.title = title
        self.colors = colors
        self.gradients = gradients
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.sm) {
            Text(title)
                .font(ConvertikTypography.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: ConvertikSpacing.md) {
                ForEach(colors, id: \.name) { item in
                    VStack(spacing: ConvertikSpacing.xs) {
                        RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                            .fill(item.color)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(item.name)
                            .font(ConvertikTypography.caption1)
                            .foregroundColor(.secondary)
                    }
                }
                
                ForEach(gradients, id: \.name) { item in
                    VStack(spacing: ConvertikSpacing.xs) {
                        RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                            .fill(item.gradient)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(item.name)
                            .font(ConvertikTypography.caption1)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct ColorPaletteItem {
    let name: String
    let color: Color
    
    init(_ name: String, _ color: Color) {
        self.name = name
        self.color = color
    }
}

struct ColorPaletteGradientItem {
    let name: String
    let gradient: LinearGradient
    
    init(_ name: String, _ gradient: LinearGradient) {
        self.name = name
        self.gradient = gradient
    }
}

// MARK: - Previews

#if DEBUG
struct ThemePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreviewView()
    }
}

struct ColorPalettePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPalettePreviewView()
    }
}
#endif 