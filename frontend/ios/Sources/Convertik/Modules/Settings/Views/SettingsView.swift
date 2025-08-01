import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsService: SettingsService
    @StateObject private var analyticsService = AnalyticsService.shared
    
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                // Раздел внешнего вида
                Section("Внешний вид") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.indigo)
                            .frame(width: 24)
                        
                        Text("Тёмная тема")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsService.isDarkMode)
                            .onChange(of: settingsService.isDarkMode) { newValue in
                                analyticsService.trackThemeChanged(isDark: newValue)
                            }
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
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Convertik Premium")
                                    .foregroundColor(.primary)
                                
                                if settingsService.isPremium {
                                    Text("Активна")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Text("Отключить рекламу • 199 ₽/мес")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if settingsService.isPremium {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Политика конфиденциальности")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://convertik.app/terms")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Условия использования")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        Text("Версия")
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .onAppear {
                analyticsService.trackSettingsOpened()
            }
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsService.shared)
}