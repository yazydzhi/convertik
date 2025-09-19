import StoreKit
import Foundation
import Combine

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()

    @Published private(set) var monthlyProduct: Product?
    @Published private(set) var isPremium = false

    private let productIds = [
        "com.azg.Convertik"
    ]

    private let settingsService = SettingsService.shared
    private let analyticsService = AnalyticsService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        #if DEBUG
        print("🔧 StoreService: Running in DEBUG mode with test configuration")
        #else
        print("🚀 StoreService: Running in RELEASE mode with production configuration")
        #endif
        
        // Синхронизируем с SettingsService при изменении статуса
        $isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPremium in
                self?.settingsService.setPremiumStatus(isPremium)
            }
            .store(in: &cancellables)
        
        // Запускаем фоновые задачи после инициализации
        Task.detached { [weak self] in
            await self?.listenForTransactions()
        }
        
        Task.detached { [weak self] in
            await self?.updatePremiumStatus()
        }
    }

    // MARK: - Product Loading

    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            monthlyProduct = products.first { $0.id == "com.azg.Convertik" }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePremiumStatus()
            await transaction.finish()
            return true

        case .pending:
            return false

        case .userCancelled:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async throws {
        #if DEBUG
        print("🔧 StoreService: Restoring purchases in DEBUG mode")
        // В DEBUG режиме используем тестовую конфигурацию
        try await AppStore.sync()
        #else
        print("🚀 StoreService: Restoring purchases in RELEASE mode")
        // В RELEASE режиме сначала проверяем локально
        await updatePremiumStatus()
        
        // Если локально нет активной подписки, пытаемся синхронизировать
        if !isPremium {
            print("🚀 StoreService: No local subscription found, attempting sync...")
            // Используем более мягкий подход - проверяем транзакции без принудительной авторизации
            do {
                try await AppStore.sync()
                await updatePremiumStatus()
            } catch {
                print("🚀 StoreService: Sync failed, but continuing with local check: \(error)")
                // Даже если синхронизация не удалась, продолжаем с локальной проверкой
            }
        } else {
            print("🚀 StoreService: Active subscription found locally, skipping sync")
        }
        #endif
    }
    
    // MARK: - Silent Subscription Check
    
    func checkSubscriptionSilently() async {
        #if DEBUG
        print("🔧 StoreService: Silent subscription check in DEBUG mode")
        #else
        print("🚀 StoreService: Silent subscription check in RELEASE mode")
        #endif
        
        // Проверяем подписку без принудительной авторизации
        await updatePremiumStatus()
        
        // Если подписка не найдена локально, пытаемся получить информацию о продуктах
        if !isPremium {
            await loadProducts()
        }
    }

    // MARK: - Ads Free Status

    func updatePremiumStatus() async {
        var hasPremium = false

        #if DEBUG
        print("🔧 StoreService: Checking premium status in DEBUG mode")
        #else
        print("🚀 StoreService: Checking premium status in RELEASE mode")
        #endif

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if productIds.contains(transaction.productID) {
                    hasPremium = true
                    #if DEBUG
                    print("🔧 StoreService: Found active subscription: \(transaction.productID)")
                    #else
                    print("🚀 StoreService: Found active subscription: \(transaction.productID)")
                    #endif
                    break
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        isPremium = hasPremium
        settingsService.setPremiumStatus(hasPremium)
        
        #if DEBUG
        print("🔧 StoreService: Premium status updated: \(hasPremium)")
        #else
        print("🚀 StoreService: Premium status updated: \(hasPremium)")
        #endif
    }

    // MARK: - Transaction Listening

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await updatePremiumStatus()
                await transaction.finish()
            } catch {
                print("Transaction update failed: \(error)")
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error, LocalizedError {
    case failedVerification
    case networkError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Не удалось подтвердить покупку"
        case .networkError:
            return "Ошибка сети"
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
}
