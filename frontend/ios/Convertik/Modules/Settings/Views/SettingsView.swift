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

                // Раздел Premium
                Section("Premium") {
                    Button {
                        showingPaywall = true
                        analyticsService.trackPremiumViewed()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(themeManager.amberAccent)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Convertik Premium")
                                    .foregroundColor(themeManager.textPrimary)

                                if settingsService.isPremium {
                                    Text("Активна")
                                        .font(.caption)
                                        .foregroundColor(themeManager.amberAccent)
                                } else {
                                    Text("Отключить рекламу • 199 ₽/мес")
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
                    Link(destination: URL(string: "https://convertik.app/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(themeManager.amberAccent)
                                .frame(width: 24)

                            Text("Политика конфиденциальности")
                                .foregroundColor(themeManager.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }

                    Link(destination: URL(string: "https://convertik.app/terms")!) {
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

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(themeManager.textSecondary)
                            .frame(width: 24)

                        Text("Версия")
                            .foregroundColor(themeManager.textPrimary)

                        Spacer()

                        Text("2.1")
                            .foregroundColor(themeManager.textSecondary)
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
}

#Preview {
    SettingsView()
        .environmentObject(SettingsService.shared)
        // .environmentObject(ThemeService.shared)
        // .environmentObject(ThemeManager())
}
