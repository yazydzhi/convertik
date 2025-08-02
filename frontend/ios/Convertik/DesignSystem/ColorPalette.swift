import SwiftUI

// MARK: - Color Palette Preview

/// Визуальная демонстрация цветовой палитры дизайн-системы
struct ColorPaletteView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: ConvertikSpacing.xxl) {
                
                // MARK: - Primary Colors
                ColorSection(
                    title: "Primary Colors",
                    colors: [
                        ColorItem("Primary", ConvertikColors.primary, "#223355"),
                        ColorItem("Accent", ConvertikColors.accent, "#007AFF"),
                        ColorItem("Secondary", ConvertikColors.secondary, "#00A5A5")
                    ]
                )
                
                // MARK: - Semantic Colors
                ColorSection(
                    title: "Semantic Colors",
                    colors: [
                        ColorItem("Success", ConvertikColors.success, "#33C759"),
                        ColorItem("Warning", ConvertikColors.warning, "#FF9500"),
                        ColorItem("Error", ConvertikColors.error, "#EB3B3B")
                    ]
                )
                
                // MARK: - Neutral Colors
                ColorSection(
                    title: "Neutral Colors",
                    colors: [
                        ColorItem("Text Primary", ConvertikColors.textPrimary, "#222222"),
                        ColorItem("Text Secondary", ConvertikColors.textSecondary, "#777777"),
                        ColorItem("Text Tertiary", ConvertikColors.textTertiary, "#999999"),
                        ColorItem("Separator", ConvertikColors.separator, "#DDDDDD"),
                        ColorItem("Background", ConvertikColors.background, "#F9F9F9"),
                        ColorItem("Card Background", ConvertikColors.cardBackground, "#FFFFFF")
                    ]
                )
                
                // MARK: - Light Backgrounds
                ColorSection(
                    title: "Light Backgrounds",
                    colors: [
                        ColorItem("Success Light", ConvertikColors.successLight, "Success + 10% opacity"),
                        ColorItem("Warning Light", ConvertikColors.warningLight, "Warning + 10% opacity"),
                        ColorItem("Error Light", ConvertikColors.errorLight, "Error + 10% opacity")
                    ]
                )
                
                // MARK: - Dark Mode Colors
                ColorSection(
                    title: "Dark Mode Colors",
                    colors: [
                        ColorItem("Text Primary Dark", ConvertikColors.textPrimaryDark, "#FFFFFF"),
                        ColorItem("Text Secondary Dark", ConvertikColors.textSecondaryDark, "#BBBBBB"),
                        ColorItem("Text Tertiary Dark", ConvertikColors.textTertiaryDark, "#888888"),
                        ColorItem("Separator Dark", ConvertikColors.separatorDark, "#444444"),
                        ColorItem("Card Background Dark", ConvertikColors.cardBackgroundDark, "#222222"),
                        ColorItem("Background Dark", ConvertikColors.backgroundDark, "#000000")
                    ]
                )
            }
            .padding(ConvertikSpacing.xl)
        }
        .background(ConvertikColors.background)
        .navigationTitle("Color Palette")
    }
}

// MARK: - Supporting Views

struct ColorSection: View {
    let title: String
    let colors: [ColorItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.lg) {
            Text(title)
                .font(ConvertikTypography.title2)
                .foregroundColor(ConvertikColors.textPrimary)
            
            VStack(spacing: ConvertikSpacing.sm) {
                ForEach(colors, id: \.name) { colorItem in
                    ColorItemView(item: colorItem)
                }
            }
        }
    }
}

struct ColorItemView: View {
    let item: ColorItem
    
    var body: some View {
        HStack(spacing: ConvertikSpacing.md) {
            // Color swatch
            RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                .fill(item.color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: ConvertikCornerRadius.sm)
                        .stroke(ConvertikColors.separator, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: ConvertikSpacing.xs) {
                Text(item.name)
                    .font(ConvertikTypography.headline)
                    .foregroundColor(ConvertikColors.textPrimary)
                
                Text(item.hexCode)
                    .font(ConvertikTypography.caption1)
                    .foregroundColor(ConvertikColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(ConvertikSpacing.md)
        .background(ConvertikColors.cardBackground)
        .cornerRadius(ConvertikCornerRadius.md)
        .shadow(
            color: ConvertikShadows.light.color,
            radius: ConvertikShadows.light.radius,
            x: ConvertikShadows.light.x,
            y: ConvertikShadows.light.y
        )
    }
}

struct ColorItem {
    let name: String
    let color: Color
    let hexCode: String
    
    init(_ name: String, _ color: Color, _ hexCode: String) {
        self.name = name
        self.color = color
        self.hexCode = hexCode
    }
}

// MARK: - Typography Preview

/// Визуальная демонстрация типографики
struct TypographyPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ConvertikSpacing.xxl) {
                
                // MARK: - Headings
                TypographySection(
                    title: "Headings",
                    items: [
                        TypographyItem("Large Title", ConvertikTypography.largeTitle),
                        TypographyItem("Title 1", ConvertikTypography.title1),
                        TypographyItem("Title 2", ConvertikTypography.title2),
                        TypographyItem("Title 3", ConvertikTypography.title3),
                        TypographyItem("Headline", ConvertikTypography.headline)
                    ]
                )
                
                // MARK: - Body Text
                TypographySection(
                    title: "Body Text",
                    items: [
                        TypographyItem("Body", ConvertikTypography.body),
                        TypographyItem("Callout", ConvertikTypography.callout),
                        TypographyItem("Subheadline", ConvertikTypography.subheadline)
                    ]
                )
                
                // MARK: - Captions
                TypographySection(
                    title: "Captions",
                    items: [
                        TypographyItem("Footnote", ConvertikTypography.footnote),
                        TypographyItem("Caption 1", ConvertikTypography.caption1),
                        TypographyItem("Caption 2", ConvertikTypography.caption2)
                    ]
                )
                
                // MARK: - Currency Typography
                TypographySection(
                    title: "Currency Typography",
                    items: [
                        TypographyItem("Currency Amount", ConvertikTypography.currencyAmount),
                        TypographyItem("Currency Code", ConvertikTypography.currencyCode),
                        TypographyItem("Currency Name", ConvertikTypography.currencyName)
                    ]
                )
            }
            .padding(ConvertikSpacing.xl)
        }
        .background(ConvertikColors.background)
        .navigationTitle("Typography")
    }
}

struct TypographySection: View {
    let title: String
    let items: [TypographyItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.lg) {
            Text(title)
                .font(ConvertikTypography.title2)
                .foregroundColor(ConvertikColors.textPrimary)
            
            VStack(spacing: ConvertikSpacing.sm) {
                ForEach(items, id: \.name) { item in
                    TypographyItemView(item: item)
                }
            }
        }
    }
}

struct TypographyItemView: View {
    let item: TypographyItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.xs) {
            Text(item.name)
                .font(ConvertikTypography.caption1)
                .foregroundColor(ConvertikColors.textSecondary)
            
            Text("The quick brown fox jumps over the lazy dog")
                .font(item.font)
                .foregroundColor(ConvertikColors.textPrimary)
                .lineLimit(2)
        }
        .padding(ConvertikSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ConvertikColors.cardBackground)
        .cornerRadius(ConvertikCornerRadius.md)
        .shadow(
            color: ConvertikShadows.light.color,
            radius: ConvertikShadows.light.radius,
            x: ConvertikShadows.light.x,
            y: ConvertikShadows.light.y
        )
    }
}

struct TypographyItem {
    let name: String
    let font: Font
    
    init(_ name: String, _ font: Font) {
        self.name = name
        self.font = font
    }
}

// MARK: - Component Preview

/// Визуальная демонстрация компонентов
struct ComponentPreviewView: View {
    @State private var searchText = ""
    @State private var amount = "100"
    
    var body: some View {
        ScrollView {
            VStack(spacing: ConvertikSpacing.xxl) {
                
                // MARK: - Buttons
                ComponentSection(title: "Buttons") {
                    VStack(spacing: ConvertikSpacing.md) {
                        ConvertikButton("Primary Button") { }
                        ConvertikButton("Secondary Button", style: .secondary) { }
                        ConvertikButton("Destructive Button", style: .destructive) { }
                        ConvertikButton("Disabled Button", isEnabled: false) { }
                    }
                }
                
                // MARK: - Cards
                ComponentSection(title: "Currency Cards") {
                    VStack(spacing: ConvertikSpacing.md) {
                        CurrencyCard(
                            currencyCode: "USD",
                            currencyName: "US Dollar",
                            amount: "1,234.56",
                            changePercent: 2.5,
                            isSelected: false
                        ) { }
                        
                        CurrencyCard(
                            currencyCode: "EUR",
                            currencyName: "Euro",
                            amount: "987.65",
                            changePercent: -1.2,
                            isSelected: true
                        ) { }
                    }
                }
                
                // MARK: - Input Fields
                ComponentSection(title: "Input Fields") {
                    VStack(spacing: ConvertikSpacing.md) {
                        AmountInputField(
                            amount: $amount,
                            placeholder: "Enter amount",
                            currencyCode: "USD"
                        )
                        
                        ConvertikSearchBar(
                            text: $searchText,
                            placeholder: "Search currencies"
                        )
                    }
                }
                
                // MARK: - Loading States
                ComponentSection(title: "Loading States") {
                    VStack(spacing: ConvertikSpacing.md) {
                        ConvertikLoadingView(message: "Loading currencies...")
                        CurrencyCardSkeleton()
                    }
                }
                
                // MARK: - Empty States
                ComponentSection(title: "Empty States") {
                    EmptyStateView(
                        icon: "plus.circle",
                        title: "No Currencies",
                        message: "Add your first currency to get started",
                        actionTitle: "Add Currency"
                    ) { }
                }
                
                // MARK: - Badges
                ComponentSection(title: "Badges") {
                    HStack(spacing: ConvertikSpacing.md) {
                        ConvertikBadge("New")
                        ConvertikBadge("Updated", color: ConvertikColors.success)
                        ConvertikBadge("Error", color: ConvertikColors.error)
                    }
                }
            }
            .padding(ConvertikSpacing.xl)
        }
        .background(ConvertikColors.background)
        .navigationTitle("Components")
    }
}

struct ComponentSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ConvertikSpacing.lg) {
            Text(title)
                .font(ConvertikTypography.title2)
                .foregroundColor(ConvertikColors.textPrimary)
            
            content
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DesignSystemPreview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorPaletteView()
        }
    }
}

struct TypographyPreview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TypographyPreviewView()
        }
    }
}

struct ComponentPreview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComponentPreviewView()
        }
    }
}
#endif 