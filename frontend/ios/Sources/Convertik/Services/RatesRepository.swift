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
            await updateLocalRates(from: response)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func rate(for code: String) -> Rate? {
        rates.first { $0.code == code }
    }
    
    // MARK: - Private Methods
    
    private func updateLocalRates(from response: RatesResponse) async {
        let context = coreDataStack.persistentContainer.newBackgroundContext()
        
        await context.perform {
            // Добавляем базовую валюту (RUB)
            let rubEntity = self.createOrUpdateRate(
                code: response.base,
                name: Rate.currencyNames[response.base] ?? response.base,
                value: 1.0,
                updatedAt: response.updatedAt,
                in: context
            )
            
            // Добавляем остальные валюты
            for (code, value) in response.rates {
                let name = Rate.currencyNames[code] ?? code
                let _ = self.createOrUpdateRate(
                    code: code,
                    name: name,
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
    
    private func createOrUpdateRate(code: String, name: String, value: Double, updatedAt: Date, in context: NSManagedObjectContext) -> RateEntity {
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