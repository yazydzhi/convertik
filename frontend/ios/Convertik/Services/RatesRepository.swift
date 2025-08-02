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
        
        // Автоматически синхронизируемся с API при инициализации
        Task {
            await syncRemote()
        }
    }

    // MARK: - Public Methods

    func loadLocalRates() {
        print("📱 Loading local rates from CoreData...")
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RateEntity.code, ascending: true)]

        do {
            let entities = try coreDataStack.persistentContainer.viewContext.fetch(request)
            rates = entities.map(Rate.init)
            lastUpdated = rates.first?.updatedAt
            print("📱 Loaded \(rates.count) rates from CoreData")
        } catch {
            print("❌ Failed to load local rates: \(error)")
        }
    }

    func syncRemote() async {
        print("🔄 Starting remote sync...")
        isLoading = true
        error = nil

        do {
            print("📡 Fetching rates from API...")
            let response = try await apiService.fetchRates()
            print("✅ Received \(response.rates.count) rates from API")
            
            // Пытаемся получить названия валют с backend'а
            var currencyNames: [String: String] = [:]
            do {
                print("📡 Fetching currency names from API...")
                let namesResponse = try await apiService.fetchCurrencyNames()
                currencyNames = namesResponse.names
                print("✅ Received \(currencyNames.count) currency names from API")
            } catch {
                print("⚠️ Failed to fetch currency names from API, using fallback: \(error)")
                // Fallback на статический словарь названий
                currencyNames = Rate.currencyNames
                print("📋 Using \(currencyNames.count) fallback currency names")
            }
            
            print("💾 Updating local rates...")
            await updateLocalRates(from: response, names: currencyNames)
            print("✅ Sync completed successfully")
            isLoading = false
        } catch {
            print("❌ Sync failed: \(error)")
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
        print("💾 Starting to update local rates...")
        let context = coreDataStack.persistentContainer.newBackgroundContext()

        await context.perform {
            print("📝 Processing \(response.rates.count + 1) currencies...")
            
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
                print("✅ Successfully saved \(response.rates.count + 1) currencies to CoreData")

                // Обновляем UI на главном потоке
                DispatchQueue.main.async {
                    self.loadLocalRates()
                    print("🔄 Reloaded local rates, now have \(self.rates.count) currencies")
                }
            } catch {
                print("❌ Failed to save rates: \(error)")
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
