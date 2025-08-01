import SwiftUI

struct AdBannerView: View {
    @EnvironmentObject private var settingsService: SettingsService

    var body: some View {
        if !settingsService.isPremium {
            VStack {
                HStack {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(.accentColor)

                    Text("Реклама • Уберите её с Premium")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Убрать") {
                        // Переход к экрану Premium
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("AdMob Banner Placeholder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    )
            }
            .background(Color(.systemGray6))
            .accessibilityHidden(true) // Скрываем от accessibility
        }
    }
}

#Preview {
    AdBannerView()
        .environmentObject(SettingsService.shared)
        .frame(height: 50)
}
