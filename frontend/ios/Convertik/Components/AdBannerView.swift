import SwiftUI

struct AdBannerView: View {
    @EnvironmentObject private var settingsService: SettingsService
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        if !settingsService.isPremium {
            VStack {
                HStack {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(themeManager.amberAccent)

                    Text("Реклама • Уберите её с Ads Free")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)

                    Spacer()

                    Button("Убрать") {
                        // Переход к экрану Ads Free
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.amberAccent)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Rectangle()
                    .fill(themeManager.cardBackground)
                    .overlay(
                        Text("AdMob Banner Placeholder")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    )
            }
            .background(themeManager.cardBackground)
            .accessibilityHidden(true) // Скрываем от accessibility
        }
    }
}

#Preview {
    AdBannerView()
        .environmentObject(SettingsService.shared)
        .environmentObject(ThemeService.shared)
        .frame(height: 50)
}
