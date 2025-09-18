import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared

    @State private var showingPaywall = false

    var body: some View {
        NavigationView {
            List {
                // Раздел внешнего вида
                Section("Внешний вид") {
                    ThemeToggleView()
                        .onChange(of: themeService.isDarkMode) { newValue in
                            analyticsService.trackThemeChanged(isDark: newValue)
                        }
                }

                // Раздел отключения рекламы
                Section("Отключить рекламу") {
                    Button {
                        showingPaywall = true
                        analyticsService.trackPremiumViewed()
                    } label: {
                        HStack {
                            // Используем сгенерированную звезду
                            Image("star_premium_v2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Convertik Ads Free")
                                    .foregroundColor(themeManager.textPrimary)

                                if settingsService.isPremium {
                                    Text("Активна")
                                        .font(.caption)
                                        .foregroundColor(themeManager.amberAccent)
                                } else {
                                    Text("Убрать рекламу и получить полный доступ")
                                        .font(.caption)
                                        .foregroundColor(themeManager.textSecondary)
                                }
                            }

                            Spacer()

                            if settingsService.isPremium {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.amberAccent)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Раздел информации
                Section("Информация") {
                    Link(destination: URL(string: "https://convertik.ponravilos.ru/privacy.html")!) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(themeManager.lilacHighlight)
                                .frame(width: 24)

                            Text("Политика конфиденциальности")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }

                    Link(destination: URL(string: "https://convertik.ponravilos.ru/terms.html")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(themeManager.lilacHighlight)
                                .frame(width: 24)

                            Text("Условия использования")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }

                    Link(destination: URL(string: "https://convertik.ponravilos.ru/data.html")!) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(themeManager.lilacHighlight)
                                .frame(width: 24)

                            Text("Политика обработки персональных данных")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(themeManager.lilacHighlight)
                                .frame(width: 24)

                            Text("Версия")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Text(getVersionWithBuildType())
                                .foregroundColor(themeManager.textSecondary)
                        }
                        
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(themeManager.lilacHighlight)
                                .frame(width: 24)

                            Text("Сборка")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Text(getBuildType())
                                .foregroundColor(getBuildTypeColor())
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(getBuildTypeBackgroundColor())
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .background(themeManager.background) // Устанавливаем правильный фон
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.amberAccent)
                    .accessibilityIdentifier("doneButton")
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onAppear {
            analyticsService.trackSettingsOpened()
        }
        .id(themeService.isDarkMode) // Принудительное обновление при изменении темы
    }
    
    // MARK: - Helper Functions
    
    private func getVersionWithBuildType() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        #if DEBUG
        return "\(version)d (\(buildNumber))"
        #else
        return "\(version)r (\(buildNumber))"
        #endif
    }
    
    private func getBuildType() -> String {
        #if DEBUG
        return "DEBUG"
        #else
        return "RELEASE"
        #endif
    }
    
    private func getBuildTypeColor() -> Color {
        #if DEBUG
        return .orange
        #else
        return .green
        #endif
    }
    
    private func getBuildTypeBackgroundColor() -> Color {
        #if DEBUG
        return Color.orange.opacity(0.2)
        #else
        return Color.green.opacity(0.2)
        #endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsService.shared)
        // .environmentObject(ThemeService.shared)
        // .environmentObject(ThemeManager())
}
