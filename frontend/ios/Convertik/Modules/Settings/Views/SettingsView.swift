import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared

    @State private var showingPaywall = false
    @State private var showBuildInfo = false
    @State private var showDebugInfo = false
    @State private var versionTapCount = 0

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

                            Text(getDisplayVersion())
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .onTapGesture {
                            showBuildInfo.toggle()
                            if !showBuildInfo {
                                versionTapCount = 0
                            }
                        }
                        
                        #if DEBUG
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
                        #endif
                        
                        if showBuildInfo {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Версия сборки:")
                                        .font(.caption)
                                        .foregroundColor(themeManager.textSecondary)
                                    Spacer()
                                    Text(getVersionWithBuildType())
                                        .font(.caption)
                                        .foregroundColor(themeManager.textSecondary)
                                }
                                
                                HStack {
                                    Text("Тип сборки:")
                                        .font(.caption)
                                        .foregroundColor(themeManager.textSecondary)
                                    Spacer()
                                    Text(getBuildType())
                                        .font(.caption)
                                        .foregroundColor(getBuildTypeColor())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(getBuildTypeBackgroundColor())
                                        .cornerRadius(6)
                                }
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .scale))
                            .onTapGesture {
                                versionTapCount += 1
                                if versionTapCount >= 5 {
                                    showDebugInfo = true
                                    versionTapCount = 0
                                }
                            }
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
        .sheet(isPresented: $showDebugInfo) {
            DebugInfoView()
        }
        .onAppear {
            analyticsService.trackSettingsOpened()
        }
        .id(themeService.isDarkMode) // Принудительное обновление при изменении темы
    }
    
    // MARK: - Helper Functions
    
    private func getDisplayVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        #if DEBUG
        return "\(version)d"
        #else
        return version
        #endif
    }
    
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

// MARK: - Debug Info View
struct DebugInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Bundle ID
                    InfoRow(
                        title: "Bundle ID",
                        value: Bundle.main.bundleIdentifier ?? "N/A",
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // AdMob App ID
                    InfoRow(
                        title: "AdMob App ID",
                        value: AdConfig.appID,
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // Banner Ad Unit ID
                    InfoRow(
                        title: "Banner Ad Unit ID",
                        value: AdConfig.Banner.mainBottom,
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // Interstitial Ad Unit ID
                    InfoRow(
                        title: "Interstitial Ad Unit ID",
                        value: AdConfig.Interstitial.main,
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // Rewarded Ad Unit ID
                    InfoRow(
                        title: "Rewarded Ad Unit ID",
                        value: AdConfig.Rewarded.main,
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // App Encryption Export Compliance
                    InfoRow(
                        title: "ITSAppUsesNonExemptEncryption",
                        value: {
                            if let value = Bundle.main.object(forInfoDictionaryKey: "ITSAppUsesNonExemptEncryption") as? Bool {
                                return value ? "YES" : "NO"
                            }
                            return "not set"
                        }(),
                        themeManager: themeManager
                    )
                    
                    Divider()
                    
                    // Encryption Export Compliance Code (for France)
                    InfoRow(
                        title: "ITSEncryptionExportComplianceCode",
                        value: Bundle.main.object(forInfoDictionaryKey: "ITSEncryptionExportComplianceCode") as? String ?? "not set",
                        themeManager: themeManager
                    )
                }
                .padding()
            }
            .background(themeManager.background)
            .navigationTitle("Отладочная информация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.amberAccent)
                }
            }
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String
    let themeManager: ThemeManager
    
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(themeManager.textSecondary)
                    .textSelection(.enabled)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = value
                    isCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isCopied = false
                    }
                } label: {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundColor(isCopied ? .green : themeManager.amberAccent)
                }
            }
            .padding()
            .background(themeManager.cardBackground)
            .cornerRadius(8)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsService.shared)
        // .environmentObject(ThemeService.shared)
        // .environmentObject(ThemeManager())
}
