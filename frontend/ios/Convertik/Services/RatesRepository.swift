import Foundation
import CoreData
import Combine
import os

// MARK: - Date Extension
extension Date {
    func formattedForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

@MainActor
final class RatesRepository: ObservableObject {
    static let shared = RatesRepository()
    
    @Published var rates: [Rate] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUpdated: Date?
    @Published var connectionError: String? // Добавляем состояние для ошибки соединения
    
    private let coreDataStack = CoreDataStack.shared
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(subsystem: "com.azg.Convertik", category: "RatesRepository")

    private init() {
        logger.debug("RatesRepository init() called")
        loadLocalRates()
        // Добавляем базовые валюты, если их нет
        if rates.isEmpty {
            logger.debug("No rates found, adding default rates")
            addDefaultRates()
        }
        
        // Автоматически синхронизируемся с API при инициализации
        logger.debug("Starting automatic sync in init()")
        Task {
            await syncRemote()
        }
    }

    // MARK: - Public Methods

    func loadLocalRates() {
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RateEntity.code, ascending: true)]

        do {
            let entities = try coreDataStack.persistentContainer.viewContext.fetch(request)
            self.rates = entities.map(Rate.init)
            let oldLastUpdated = self.lastUpdated
            self.lastUpdated = rates.first?.updatedAt
            logger.debug("loadLocalRates: old lastUpdated=\(oldLastUpdated?.formattedForDisplay() ?? "nil"), new lastUpdated=\(self.lastUpdated?.formattedForDisplay() ?? "nil")")
        } catch {
            logger.error("Failed to load local rates: \(error)")
        }
    }

    func syncRemote() async {
        logger.debug("Starting remote sync...")
        isLoading = true
        error = nil
        connectionError = nil // Сбрасываем ошибку соединения

        do {
            logger.debug("Fetching rates from API...")
            let response = try await apiService.fetchRates()
            logger.debug("Received \(response.rates.count) rates from API")
            logger.debug("API updated at: \(response.updatedAt)")
            
            // Используем fallback названия валют
            var currencyNames: [String: String] = [:]
            currencyNames = Rate.currencyNames
            
            await updateLocalRates(from: response, names: currencyNames)
            isLoading = false
            logger.debug("Remote sync completed successfully")
        } catch {
            self.error = error
            isLoading = false
            
            // Определяем тип ошибки и устанавливаем соответствующее сообщение
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    connectionError = "Нет подключения к интернету"
                case .timedOut:
                    connectionError = "Превышено время ожидания"
                case .cannotFindHost, .cannotConnectToHost:
                    connectionError = "Не удается подключиться к серверу"
                default:
                    connectionError = "Ошибка сети: \(urlError.localizedDescription)"
                }
            } else {
                connectionError = "Ошибка синхронизации: \(error.localizedDescription)"
            }
            
            logger.error("Remote sync failed: \(error)")
        }
    }

    func rate(for code: String) -> Rate? {
        rates.first { $0.code == code }
    }

    // MARK: - Default Rates

    private func addDefaultRates() {
        let context = coreDataStack.persistentContainer.newBackgroundContext()

        context.perform {
            do {
                try context.save()
            } catch {
                self.logger.error("Failed to save default rates: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func updateLocalRates(from response: RatesResponse, names: [String: String]) async {
        self.logger.debug("Starting to update local rates...")
        
        await DispatchQueue.main.async {
            let context = self.coreDataStack.persistentContainer.viewContext
            self.logger.debug("Processing \(response.rates.count + 1) currencies...")
            
            // Создаем или обновляем базовую валюту
            _ = self.createOrUpdateRate(
                code: response.base,
                name: names[response.base] ?? response.base,
                value: 1.0,
                updatedAt: response.updatedAt,
                in: context
            )
            
            // Создаем или обновляем все остальные валюты
            for (code, value) in response.rates {
                _ = self.createOrUpdateRate(
                    code: code,
                    name: names[code] ?? code,
                    value: 1.0 / value,
                    updatedAt: response.updatedAt,
                    in: context
                )
            }
            
            do {
                try context.save()
                self.logger.debug("Successfully saved to CoreData")
                
                self.loadLocalRates()
                let oldLastUpdated = self.lastUpdated
                // Используем текущее время для отладки, если API время не меняется
                let newTime = Date()
                self.lastUpdated = newTime
                self.logger.debug("updateLocalRates: old lastUpdated=\(oldLastUpdated?.formattedForDisplay() ?? "nil"), new lastUpdated=\(self.lastUpdated?.formattedForDisplay() ?? "nil")")
            } catch {
                self.logger.error("Failed to save to CoreData: \(error)")
            }
        }
    }

    private func createOrUpdateRate(code: String, name: String, value: Double, updatedAt: Date, in context: NSManagedObjectContext) -> RateEntity {
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        
        do {
            let existingRates = try context.fetch(request)
            
            if let existingRate = existingRates.first {
                // Обновляем существующую запись
                existingRate.name = name
                existingRate.value = value
                existingRate.updatedAt = updatedAt
                return existingRate
            } else {
                // Создаем новую запись
                let newRate = RateEntity(context: context)
                newRate.code = code
                newRate.name = name
                newRate.value = value
                newRate.updatedAt = updatedAt
                return newRate
            }
        } catch {
            logger.error("Error in createOrUpdateRate for \(code): \(error)")
            // Создаем новую запись в случае ошибки
            let newRate = RateEntity(context: context)
            newRate.code = code
            newRate.name = name
            newRate.value = value
            newRate.updatedAt = updatedAt
            return newRate
        }
    }
}
