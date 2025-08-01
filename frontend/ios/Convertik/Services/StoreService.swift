import StoreKit
import Foundation

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()
    
    @Published private(set) var monthlyProduct: Product?
    @Published private(set) var isPremium = false
    
    private let productIds = [
        "convertik_premium_month"
    ]
    
    private let settingsService = SettingsService.shared
    private let analyticsService = AnalyticsService.shared
    
    private init() {
        // Слушаем транзакции
        Task {
            await listenForTransactions()
        }
        
        // Проверяем текущие покупки
        Task {
            await updatePremiumStatus()
        }
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            monthlyProduct = products.first { $0.id == "convertik_premium_month" }
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
        try await AppStore.sync()
        await updatePremiumStatus()
    }
    
    // MARK: - Premium Status
    
    private func updatePremiumStatus() async {
        var hasPremium = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if productIds.contains(transaction.productID) {
                    hasPremium = true
                    break
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        isPremium = hasPremium
        settingsService.setPremiumStatus(hasPremium)
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