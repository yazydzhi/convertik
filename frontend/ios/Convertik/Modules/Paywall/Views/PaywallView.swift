import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeService: StoreService
    @Environment(\.themeManager) private var themeManager
    @StateObject private var analyticsService = AnalyticsService.shared

    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    benefitsSection
                    purchaseSection
                    disclaimerSection
                }
                .padding()
            }
            .background(themeManager.background)
            .navigationTitle("Ads Free")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .task {
                await storeService.loadProducts()
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            analyticsService.trackPremiumViewed()
        }
    }

    // MARK: - Views

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Используем сгенерированную звезду вместо короны
            Image("star_premium_v2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)

            Text("Convertik Ads Free")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Уберите рекламу и получите полный доступ")
                .font(.headline)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitRow(
                icon: "xmark.circle.fill",
                title: "Без рекламы",
                description: "Никаких баннеров и отвлекающей рекламы"
            )

            BenefitRow(
                icon: "bolt.fill",
                title: "Быстрая работа",
                description: "Приложение работает ещё быстрее"
            )

            BenefitRow(
                icon: "heart.fill",
                title: "Поддержка разработки",
                description: "Помогите нам создавать лучшие приложения"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
        )
    }

    private var purchaseSection: some View {
        VStack(spacing: 16) {
            if let product = storeService.monthlyProduct {
                // Основная кнопка подписки
                Button {
                    purchaseProduct(product)
                } label: {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Подписаться")
                                .fontWeight(.semibold)
                                .font(.headline)

                            Spacer()

                            Text(product.displayPrice)
                                .fontWeight(.bold)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        
                        Text("в месяц")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(themeManager.accentGradient)
                    .cornerRadius(12)
                }
                .disabled(isLoading)

                // Информация о подписке
                VStack(spacing: 4) {
                    Text("Автоматическое продление")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("Отменить можно в настройках Apple ID")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView("Загрузка...")
                        .frame(height: 50)
                    
                    Text("Получение информации о подписке")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }

            // Кнопка восстановления покупок
            Button("Восстановить покупки") {
                restorePurchases()
            }
            .foregroundColor(themeManager.amberAccent)
            .font(.subheadline)
            .disabled(isLoading)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .background(Color.black.opacity(0.1))
            }
        }
    }

    private var disclaimerSection: some View {
        VStack(spacing: 12) {
            // Основная информация о подписке
            VStack(spacing: 4) {
                Text("Подписка автоматически продлевается")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Отменить можно в настройках Apple ID")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Ссылки на условия и политики
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    Link("Условия использования", destination: URL(string: "https://convertik.ponravilos.ru/terms.html")!)
                        .font(.caption)
                        .foregroundColor(themeManager.amberAccent)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Link("Политика конфиденциальности", destination: URL(string: "https://convertik.ponravilos.ru/privacy.html")!)
                        .font(.caption)
                        .foregroundColor(themeManager.amberAccent)
                }
                
                Link("Политика обработки персональных данных", destination: URL(string: "https://convertik.ponravilos.ru/data.html")!)
                    .font(.caption)
                    .foregroundColor(themeManager.amberAccent)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func purchaseProduct(_ product: Product) {
        isLoading = true
        analyticsService.trackSubscribeStart(planId: product.id)

        Task {
            do {
                let result = try await storeService.purchase(product)
                await MainActor.run {
                    if result {
                        analyticsService.trackSubscribeSuccess(
                            planId: product.id,
                            price: product.displayPrice
                        )
                        dismiss()
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }

    private func restorePurchases() {
        isLoading = true

        Task {
            do {
                try await storeService.restorePurchases()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
}

struct BenefitRow: View {
    @Environment(\.themeManager) private var themeManager
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.amberAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
            }

            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SettingsService.shared)
}
