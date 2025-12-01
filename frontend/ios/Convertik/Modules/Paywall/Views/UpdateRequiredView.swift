import SwiftUI

struct UpdateRequiredView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeManager) private var themeManager
    
    private let appStoreURL = "https://apps.apple.com/ge/app/convertik-currency-calculator/id6749779316"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    benefitsSection
                    updateSection
                    infoSection
                }
                .padding()
            }
            .background(themeManager.background)
            .navigationTitle("Обновление приложения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(themeManager.amberAccent)
            
            Text("Доступна новая версия")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Обновите приложение, чтобы получить доступ к подписке и новым функциям")
                .font(.headline)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitRow(
                icon: "sparkles",
                title: "Новые функции",
                description: "Улучшенный интерфейс и дополнительные возможности"
            )
            
            BenefitRow(
                icon: "creditcard.fill",
                title: "Подписка Ads Free",
                description: "Уберите рекламу и поддержите разработку"
            )
            
            BenefitRow(
                icon: "bolt.fill",
                title: "Быстрая работа",
                description: "Оптимизированная производительность"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
        )
    }
    
    private var updateSection: some View {
        VStack(spacing: 16) {
            Button {
                openAppStore()
            } label: {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                        
                        Text("Обновить в App Store")
                            .fontWeight(.semibold)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(themeManager.accentGradient)
                .cornerRadius(12)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 12) {
            Text("После обновления вы сможете:")
                .font(.subheadline)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(text: "Оформить подписку Ads Free")
                InfoRow(text: "Отменить подписку в настройках Apple ID")
                InfoRow(text: "Использовать все новые функции")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardBackground)
            )
        }
        .padding(.top, 8)
    }
    
    // MARK: - Actions
    
    private func openAppStore() {
        guard let url = URL(string: appStoreURL) else { return }
        UIApplication.shared.open(url)
    }
}

struct InfoRow: View {
    @Environment(\.themeManager) private var themeManager
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundColor(themeManager.amberAccent)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    UpdateRequiredView()
        .environmentObject(SettingsService.shared)
}

