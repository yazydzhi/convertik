import SwiftUI

// MARK: - Design System Components

/// Основные компоненты дизайн-системы Convertik

// MARK: - Buttons

/// Основная кнопка приложения
struct ConvertikButton: View {
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
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? ConvertikColors.primary : ConvertikColors.textTertiary
        case .secondary:
            return isEnabled ? ConvertikColors.secondary : ConvertikColors.textTertiary
        case .destructive:
            return isEnabled ? ConvertikColors.error : ConvertikColors.textTertiary
        case .outline:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .destructive:
            return .white
        case .outline:
            return ConvertikColors.primary
        }
    }
}

// MARK: - Cards

/// Карточка для отображения валют
struct CurrencyCard: View {
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
                            .foregroundColor(ConvertikColors.textPrimary)
                        
                        Text(currencyName)
                            .font(ConvertikTypography.currencyName)
                            .foregroundColor(ConvertikColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: ConvertikSpacing.xs) {
                        Text(amount)
                            .font(ConvertikTypography.currencyAmount)
                            .foregroundColor(ConvertikColors.textPrimary)
                        
                        if let changePercent = changePercent {
                            ChangeIndicator(percent: changePercent)
                        }
                    }
                }
            }
            .padding(ConvertikSpacing.lg)
            .background(ConvertikColors.cardBackground)
            .cornerRadius(ConvertikCornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                    .stroke(
                        isSelected ? ConvertikColors.primary : ConvertikColors.separator,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: ConvertikShadows.light.color,
                radius: ConvertikShadows.light.radius,
                x: ConvertikShadows.light.x,
                y: ConvertikShadows.light.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Индикатор изменения курса
struct ChangeIndicator: View {
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
            (percent >= 0 ? ConvertikColors.successLight : ConvertikColors.errorLight)
        )
        .cornerRadius(ConvertikCornerRadius.sm)
    }
}

// MARK: - Input Fields

/// Поле ввода для сумм
struct AmountInputField: View {
    @Binding var amount: String
    let placeholder: String
    let currencyCode: String
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.md) {
            TextField(placeholder, text: $amount)
                .font(ConvertikTypography.currencyAmount)
                .foregroundColor(ConvertikColors.textPrimary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            
            Text(currencyCode)
                .font(ConvertikTypography.currencyCode)
                .foregroundColor(ConvertikColors.textSecondary)
        }
        .padding(ConvertikSpacing.lg)
        .background(ConvertikColors.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(ConvertikColors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Search Bar

/// Поисковая строка
struct ConvertikSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ConvertikColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(ConvertikTypography.body)
                .foregroundColor(ConvertikColors.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ConvertikColors.textTertiary)
                }
            }
        }
        .padding(ConvertikSpacing.md)
        .background(ConvertikColors.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(ConvertikColors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Dividers

/// Разделитель секций
struct ConvertikDivider: View {
    let color: Color
    
    init(color: Color = ConvertikColors.separator) {
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

// MARK: - Loading States

/// Индикатор загрузки
struct ConvertikLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: ConvertikSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: ConvertikColors.primary))
            
            Text(message)
                .font(ConvertikTypography.body)
                .foregroundColor(ConvertikColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(ConvertikSpacing.xxl)
    }
}

/// Скелетон для карточек валют
struct CurrencyCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: ConvertikSpacing.xs) {
                    Rectangle()
                        .fill(ConvertikColors.selectedBackground)
                        .frame(width: 60, height: 16)
                        .cornerRadius(ConvertikCornerRadius.sm)
                    
                    Rectangle()
                        .fill(ConvertikColors.selectedBackground)
                        .frame(width: 100, height: 14)
                        .cornerRadius(ConvertikCornerRadius.sm)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ConvertikSpacing.xs) {
                    Rectangle()
                        .fill(ConvertikColors.selectedBackground)
                        .frame(width: 80, height: 24)
                        .cornerRadius(ConvertikCornerRadius.sm)
                    
                    Rectangle()
                        .fill(ConvertikColors.selectedBackground)
                        .frame(width: 50, height: 14)
                        .cornerRadius(ConvertikCornerRadius.sm)
                }
            }
        }
        .padding(ConvertikSpacing.lg)
        .background(ConvertikColors.cardBackground)
        .cornerRadius(ConvertikCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.lg)
                .stroke(ConvertikColors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Empty States

/// Состояние пустого списка
struct EmptyStateView: View {
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
                .foregroundColor(ConvertikColors.textTertiary)
            
            VStack(spacing: ConvertikSpacing.sm) {
                Text(title)
                    .font(ConvertikTypography.title3)
                    .foregroundColor(ConvertikColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(ConvertikTypography.body)
                    .foregroundColor(ConvertikColors.textSecondary)
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
    let text: String
    let color: Color
    let backgroundColor: Color
    
    init(
        _ text: String,
        color: Color = ConvertikColors.textPrimary,
        backgroundColor: Color = ConvertikColors.selectedBackground
    ) {
        self.text = text
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Text(text)
            .font(ConvertikTypography.caption1)
            .foregroundColor(color)
            .padding(.horizontal, ConvertikSpacing.sm)
            .padding(.vertical, ConvertikSpacing.xs)
            .background(backgroundColor)
            .cornerRadius(ConvertikCornerRadius.sm)
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
        }
        .padding()
        .background(ConvertikColors.background)
    }
}
#endif 