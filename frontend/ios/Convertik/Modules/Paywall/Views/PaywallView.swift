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
            .navigationTitle("Premium")
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
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.amberAccent)

            Text("Convertik Premium")
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
        VStack(spacing: 12) {
            if let product = storeService.monthlyProduct {
                Button {
                    purchaseProduct(product)
                } label: {
                    HStack {
                        Text("Подписаться")
                            .fontWeight(.semibold)

                        Spacer()

                        Text(product.displayPrice)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(themeManager.accentGradient)
                    .cornerRadius(12)
                }
                .disabled(isLoading)

                Text("199 ₽ в месяц, автопродление")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            } else {
                ProgressView("Загрузка...")
                    .frame(height: 50)
            }

            Button("Восстановить покупки") {
                restorePurchases()
            }
            .foregroundColor(themeManager.amberAccent)
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
        VStack(spacing: 8) {
            Text("Подписка автоматически продлевается. Отменить можно в настройках Apple ID.")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Условия", destination: URL(string: "https://convertik.app/terms")!)
                Link("Конфиденциальность", destination: URL(string: "https://convertik.app/privacy")!)
            }
            .font(.caption)
            .foregroundColor(themeManager.amberAccent)
        }
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
