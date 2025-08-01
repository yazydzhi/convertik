import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsService: SettingsService
    @StateObject private var storeService = StoreService.shared
    @StateObject private var analyticsService = AnalyticsService.shared

    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Заголовок
                headerSection

                // Преимущества Premium
                benefitsSection

                Spacer()

                // Кнопки покупки и восстановления
                purchaseSection

                // Мелкий текст
                disclaimerSection
            }
            .padding()
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Convertik Premium")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Уберите рекламу и получите полный доступ")
                .font(.headline)
                .foregroundColor(.secondary)
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
                .fill(Color(.systemGray6))
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
                    .background(Color.accentColor)
                    .cornerRadius(12)
                }
                .disabled(isLoading)

                Text("199 ₽ в месяц, автопродление")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ProgressView("Загрузка...")
                    .frame(height: 50)
            }

            Button("Восстановить покупки") {
                restorePurchases()
            }
            .foregroundColor(.accentColor)
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
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Условия", destination: URL(string: "https://convertik.app/terms")!)
                Link("Конфиденциальность", destination: URL(string: "https://convertik.app/privacy")!)
            }
            .font(.caption)
            .foregroundColor(.accentColor)
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
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SettingsService.shared)
}
