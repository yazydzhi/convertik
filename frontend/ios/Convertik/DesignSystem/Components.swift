import SwiftUI

// MARK: - Design System Components

/// Основные компоненты дизайн-системы Convertik с поддержкой тем
/// Палитра Velvet Sunset - футуристичная палитра, вдохновлённая закатными оттенками

// MARK: - Buttons

/// Основная кнопка приложения
struct ConvertikButton: View {
    @Environment(\.themeManager) private var themeManager
    
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isEnabled: Bool
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case outline
    }
    
    init(
        _ title: String,
        style: ButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ConvertikTypography.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(ConvertikCornerRadius.md)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var backgroundColor: AnyShapeStyle {
        switch style {
        case .primary:
            return isEnabled ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.textTertiary)
        case .secondary:
            return isEnabled ? AnyShapeStyle(themeManager.amberAccent) : AnyShapeStyle(themeManager.textTertiary)
        case .destructive:
            // Мягкий коралловый из палитры
            return isEnabled ? AnyShapeStyle(Color(red: 1.0, green: 0.494, blue: 0.373)) : AnyShapeStyle(themeManager.textTertiary)
        case .outline:
            return AnyShapeStyle(Color.clear)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .destructive:
            return .white
        case .outline:
            return themeManager.amberAccent
        }
    }
}

// MARK: - Cards

/// Карточка для отображения валют
struct CurrencyCard: View {
    @Environment(\.themeManager) private var themeManager
    
    let currencyCode: String
    let currencyName: String
    let amount: String
    let changePercent: Double?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: ConvertikSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: ConvertikSpacing.xs) {
                        Text(currencyCode)
                            .font(ConvertikTypography.currencyCode)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text(currencyName)
                            .font(ConvertikTypography.currencyName)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: ConvertikSpacing.xs) {
                        Text(amount)
                            .font(ConvertikTypography.currencyAmount)
                            .foregroundColor(themeManager.textPrimary)
                        
                        if let changePercent = changePercent {
                            ChangeIndicator(percent: changePercent)
                        }
                    }
                }
            }
            .padding(ConvertikSpacing.lg)
            .background(themeManager.cardBackground(isSelected: isSelected))
            .cornerRadius(ConvertikCornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                    .stroke(
                        isSelected ? themeManager.lilacHighlight : themeManager.separator,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected 
                    ? themeManager.lilacHighlight.opacity(0.3) // Лёгкое поднятие для выбранной карточки
                    : (themeManager.isDarkMode ? themeManager.cardGlowColor : ConvertikShadows.light.color), // Легкое свечение только в темной теме
                radius: isSelected 
                    ? 8 // Увеличенная тень для "возвышения"
                    : (themeManager.isDarkMode ? 4 : ConvertikShadows.light.radius), // Меньший радиус для свечения только в темной теме
                x: themeManager.isDarkMode ? ConvertikShadows.lightDark.x : ConvertikShadows.light.x,
                y: isSelected 
                    ? 2 // Лёгкое поднятие
                    : (themeManager.isDarkMode ? ConvertikShadows.lightDark.y : ConvertikShadows.light.y)
            )
            .animation(.easeInOut(duration: 0.3), value: isSelected) // Плавная анимация
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Индикатор изменения курса
struct ChangeIndicator: View {
    @Environment(\.themeManager) private var themeManager
    
    let percent: Double
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.xs) {
            Image(systemName: percent >= 0 ? "arrow.up" : "arrow.down")
                .font(.caption2)
                .foregroundColor(percent >= 0 ? ConvertikColors.success : ConvertikColors.error)
            
            Text(String(format: "%.2f%%", abs(percent)))
                .font(ConvertikTypography.caption1)
                .foregroundColor(percent >= 0 ? ConvertikColors.success : ConvertikColors.error)
        }
        .padding(.horizontal, ConvertikSpacing.sm)
        .padding(.vertical, ConvertikSpacing.xs)
        .background(
            percent >= 0 ? themeManager.successBackground : themeManager.errorBackground
        )
        .cornerRadius(ConvertikCornerRadius.sm)
    }
}

// MARK: - Input Fields

/// Поле ввода для сумм
struct AmountInputField: View {
    @Environment(\.themeManager) private var themeManager
    @Binding var amount: String
    let placeholder: String
    let currencyCode: String
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.md) {
            TextField(placeholder, text: $amount)
                .font(ConvertikTypography.currencyAmount)
                .foregroundColor(themeManager.textPrimary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            
            Text(currencyCode)
                .font(ConvertikTypography.currencyCode)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(ConvertikSpacing.lg)
        .background(themeManager.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(themeManager.lilacHighlight, lineWidth: 1) // Заменяем Amber на Lilac для полей ввода
        )
    }
}

// MARK: - Search Bar

/// Поисковая строка
struct ConvertikSearchBar: View {
    @Environment(\.themeManager) private var themeManager
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.lilacHighlight)
            
            TextField(placeholder, text: $text)
                .font(ConvertikTypography.body)
                .foregroundColor(themeManager.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.amberAccent)
                }
            }
        }
        .padding(ConvertikSpacing.md)
        .background(themeManager.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(themeManager.lilacHighlight, lineWidth: 1) // Заменяем Amber на Lilac для полей ввода
        )
    }
}

// MARK: - Dividers

/// Разделитель секций
struct ConvertikDivider: View {
    @Environment(\.themeManager) private var themeManager
    let color: Color?
    
    init(color: Color? = nil) {
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .fill(color ?? themeManager.separator)
            .frame(height: 1)
    }
}

// MARK: - Loading States

/// Индикатор загрузки
struct ConvertikLoadingView: View {
    @Environment(\.themeManager) private var themeManager
    let message: String
    
    var body: some View {
        VStack(spacing: ConvertikSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: ConvertikColors.amberAccent))
            
            Text(message)
                .font(ConvertikTypography.body)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(ConvertikSpacing.xxl)
    }
}

/// Скелетон для карточек валют
struct CurrencyCardSkeleton: View {
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: ConvertikSpacing.xs) {
                    Rectangle()
                        .fill(themeManager.selectedBackground)
                        .frame(width: 60, height: 16)
                        .cornerRadius(ConvertikCornerRadius.sm)
                    
                    Rectangle()
                        .fill(themeManager.selectedBackground)
                        .frame(width: 100, height: 14)
                        .cornerRadius(ConvertikCornerRadius.sm)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ConvertikSpacing.xs) {
                    Rectangle()
                        .fill(themeManager.selectedBackground)
                        .frame(width: 80, height: 24)
                        .cornerRadius(ConvertikCornerRadius.sm)
                    
                    Rectangle()
                        .fill(themeManager.selectedBackground)
                        .frame(width: 50, height: 14)
                        .cornerRadius(ConvertikCornerRadius.sm)
                }
            }
        }
        .padding(ConvertikSpacing.lg)
        .background(themeManager.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(themeManager.separator, lineWidth: 1)
        )
    }
}

// MARK: - Empty States

/// Состояние пустого списка
struct EmptyStateView: View {
    @Environment(\.themeManager) private var themeManager
    
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: ConvertikSpacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(themeManager.textTertiary)
            
            VStack(spacing: ConvertikSpacing.sm) {
                Text(title)
                    .font(ConvertikTypography.title3)
                    .foregroundColor(themeManager.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(ConvertikTypography.body)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                ConvertikButton(actionTitle, action: action)
                    .padding(.horizontal, ConvertikSpacing.xxl)
            }
        }
        .padding(ConvertikSpacing.xxxl)
    }
}

// MARK: - Badges

/// Бейдж для статусов
struct ConvertikBadge: View {
    @Environment(\.themeManager) private var themeManager
    
    let text: String
    let color: Color?
    let backgroundColor: Color?
    
    init(
        _ text: String,
        color: Color? = nil,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        let resolvedColor: Color
        let resolvedBackground: Color
        if color == nil && text.lowercased().contains("новое") {
            resolvedColor = .white
            resolvedBackground = themeManager.amberAccent
        } else if color == nil && text.lowercased().contains("обновлено") {
            resolvedColor = .white
            resolvedBackground = themeManager.lilacHighlight
        } else {
            resolvedColor = color ?? themeManager.textPrimary
            resolvedBackground = backgroundColor ?? themeManager.selectedBackground
        }
        
        return Text(text)
            .font(ConvertikTypography.caption1)
            .foregroundColor(resolvedColor)
            .padding(.horizontal, ConvertikSpacing.sm)
            .padding(.vertical, ConvertikSpacing.xs)
            .background(resolvedBackground)
            .cornerRadius(ConvertikCornerRadius.sm)
    }
}

// MARK: - Theme Toggle

/// Переключатель темы
struct ThemeToggleView: View {
    @Environment(\.themeManager) private var themeManager
    @EnvironmentObject private var themeService: ThemeService
    
    var body: some View {
        HStack {
            Image(systemName: themeService.isDarkMode ? "moon.fill" : "sun.max.fill")
                .foregroundColor(themeManager.lilacHighlight)
            
            Text(themeService.isDarkMode ? "Темная тема" : "Светлая тема")
                .font(ConvertikTypography.body)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $themeService.isDarkMode)
                .toggleStyle(SwitchToggleStyle(tint: themeManager.amberAccent))
                .onChange(of: themeService.isDarkMode) { _ in
                    // Принудительно обновляем ThemeManager
                    themeManager.refreshTheme()
                }
        }
        .padding(ConvertikSpacing.lg)
        .background(themeManager.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
    }
}

// MARK: - Previews

#if DEBUG
struct DesignSystemComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: ConvertikSpacing.lg) {
            ConvertikButton("Primary Button") {}
            ConvertikButton("Secondary Button", style: .secondary) {}
            ConvertikButton("Destructive Button", style: .destructive) {}
            
            CurrencyCard(
                currencyCode: "USD",
                currencyName: "US Dollar",
                amount: "1,234.56",
                changePercent: 2.5,
                isSelected: false
            ) {}
            
            AmountInputField(
                amount: .constant("100"),
                placeholder: "Enter amount",
                currencyCode: "USD"
            )
            
            ConvertikSearchBar(
                text: .constant(""),
                placeholder: "Search currencies"
            )
            
            ThemeToggleView()
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environmentObject(ThemeManager(themeService: ThemeService.shared))
        .environmentObject(ThemeService.shared)
    }
}
#endif 