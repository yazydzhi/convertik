import Foundation
import CoreData
import Combine

@MainActor
final class RatesRepository: ObservableObject {
    static let shared = RatesRepository()

    @Published private(set) var rates: [Rate] = []
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let coreDataStack = CoreDataStack.shared
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadLocalRates()
        // Добавляем базовые валюты, если их нет
        if rates.isEmpty {
            addDefaultRates()
        }
    }

    // MARK: - Public Methods

    func loadLocalRates() {
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RateEntity.code, ascending: true)]

        do {
            let entities = try coreDataStack.persistentContainer.viewContext.fetch(request)
            rates = entities.map(Rate.init)
            lastUpdated = rates.first?.updatedAt
        } catch {
            print("Failed to load local rates: \(error)")
        }
    }

    func syncRemote() async {
        isLoading = true
        error = nil

        do {
            let response = try await apiService.fetchRates()
            let namesResponse = try await apiService.fetchCurrencyNames()
            await updateLocalRates(from: response, names: namesResponse.names)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    func rate(for code: String) -> Rate? {
        rates.first { $0.code == code }
    }

    // MARK: - Default Rates

    private func addDefaultRates() {
        let context = coreDataStack.persistentContainer.newBackgroundContext()

        context.perform {
            let defaultRates = [
                ("RUB", "Российский рубль", 1.0),
                ("USD", "Доллар США", 90.91),      // 1 USD = 90.91 ₽
                ("EUR", "Евро", 100.00),           // 1 EUR = 100.00 ₽
                ("GBP", "Фунт стерлингов", 114.94), // 1 GBP = 114.94 ₽
                ("CNY", "Китайский юань", 12.50),   // 1 CNY = 12.50 ₽
                ("JPY", "Японская иена", 0.58),     // 1 JPY = 0.58 ₽
                ("CHF", "Швейцарский франк", 102.04), // 1 CHF = 102.04 ₽
                ("CAD", "Канадский доллар", 66.67),  // 1 CAD = 66.67 ₽
                ("AUD", "Австралийский доллар", 58.82), // 1 AUD = 58.82 ₽
                ("TRY", "Турецкая лира", 2.86)      // 1 TRY = 2.86 ₽
            ]

            for (code, name, value) in defaultRates {
                _ = self.createOrUpdateRate(
                    code: code,
                    name: name,
                    value: value,
                    updatedAt: Date(),
                    in: context
                )
            }

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.loadLocalRates()
                }
            } catch {
                print("Failed to save default rates: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func updateLocalRates(from response: RatesResponse, names: [String: String]) async {
        let context = coreDataStack.persistentContainer.newBackgroundContext()

        await context.perform {
            // Добавляем базовую валюту (RUB)
            _ = self.createOrUpdateRate(
                code: response.base,
                name: names[response.base] ?? response.base,
                value: 1.0,
                updatedAt: response.updatedAt,
                in: context
            )

            // Добавляем остальные валюты
            for (code, value) in response.rates {
                _ = self.createOrUpdateRate(
                    code: code,
                    name: names[code] ?? code,
                    value: 1.0 / value, // Инвертируем, чтобы получить рубли за единицу валюты
                    updatedAt: response.updatedAt,
                    in: context
                )
            }

            do {
                try context.save()

                // Обновляем UI на главном потоке
                DispatchQueue.main.async {
                    self.loadLocalRates()
                }
            } catch {
                print("Failed to save rates: \(error)")
            }
        }
    }

    private func createOrUpdateRate(
        code: String,
        name: String,
        value: Double,
        updatedAt: Date,
        in context: NSManagedObjectContext
    ) -> RateEntity {
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)

        let entity: RateEntity
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = RateEntity(context: context)
            entity.code = code
        }

        entity.name = name
        entity.value = value
        entity.updatedAt = updatedAt

        return entity
    }
}
