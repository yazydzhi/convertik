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
    private var isSyncing = false // Защита от множественных синхронизаций

    private init() {
        logger.debug("RatesRepository init() called")
        
        // Загружаем локальные данные синхронно (быстро, не блокирует UI)
        loadLocalRates()
        
        // Если данных нет, добавляем дефолтные курсы СИНХРОННО в фоне
        // Это гарантирует, что UI сразу покажет хотя бы дефолтные валюты
        if rates.isEmpty {
            logger.debug("No rates found, adding default rates synchronously")
            // Загружаем дефолтные курсы асинхронно, но не блокируя UI
            Task.detached { [weak self] in
                await self?.addDefaultRates()
                // После добавления дефолтных курсов обновляем UI
                await MainActor.run {
                    self?.loadLocalRates()
                }
            }
        }
        
        // Запускаем синхронизацию в фоне ПОСЛЕ показа UI
        // Порядок: UI → Локальные данные (уже загружены) → Синхронизация → Premium → Реклама
        logger.debug("Scheduling background sync after init()")
        Task.detached { [weak self] in
            // Увеличена задержка до 3 секунд, чтобы UI точно успел показаться
            // и пользователь мог начать работать с приложением
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 секунды
            await self?.syncRemote()
        }
    }

    // MARK: - Public Methods

    func loadLocalRates() {
        // Загрузка локальных данных - быстрая операция, не блокирует UI
        // Используем viewContext, который уже на главном потоке
        let request: NSFetchRequest<RateEntity> = RateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RateEntity.code, ascending: true)]

        do {
            let entities = try coreDataStack.persistentContainer.viewContext.fetch(request)
            // Обновляем rates на главном потоке (мы уже на MainActor)
            self.rates = entities.map(Rate.init)
            let oldLastUpdated = self.lastUpdated
            self.lastUpdated = rates.first?.updatedAt
            logger.debug("loadLocalRates: old lastUpdated=\(oldLastUpdated?.formattedForDisplay() ?? "nil"), new lastUpdated=\(self.lastUpdated?.formattedForDisplay() ?? "nil")")
        } catch {
            logger.error("Failed to load local rates: \(error)")
            // В случае ошибки оставляем пустой массив, UI все равно покажется
        }
    }

    func syncRemote() async {
        // Защита от множественных синхронизаций
        guard !isSyncing else {
            logger.debug("Sync already in progress, skipping...")
            return
        }
        
        isSyncing = true
        logger.debug("Starting remote sync...")
        
        await MainActor.run {
            isLoading = true
            error = nil
            connectionError = nil // Сбрасываем ошибку соединения
        }

        do {
            logger.debug("Fetching rates from API...")
            let response = try await apiService.fetchRates()
            logger.debug("Received \(response.rates.count) rates from API")
            logger.debug("API updated at: \(response.updatedAt)")
            
            // Используем fallback названия валют
            var currencyNames: [String: String] = [:]
            currencyNames = Rate.currencyNames
            
            await updateLocalRates(from: response, names: currencyNames)
            
            await MainActor.run {
                isLoading = false
            }
            logger.debug("Remote sync completed successfully")
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
            
            // Определяем тип ошибки и устанавливаем соответствующее сообщение
            await MainActor.run {
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
            }
            
            logger.error("Remote sync failed: \(error)")
        }
        
        isSyncing = false // Сбрасываем флаг синхронизации
    }

    func rate(for code: String) -> Rate? {
        rates.first { $0.code == code }
    }

    // MARK: - Default Rates

    private func addDefaultRates() async {
        let context = coreDataStack.persistentContainer.newBackgroundContext()

        await context.perform {
            do {
                // Добавляем базовые валюты
                let defaultRates = [
                    ("RUB", "Российский рубль", 1.0),
                    ("USD", "Доллар США", 0.012518),
                    ("EUR", "Евро", 0.0108),
                    ("GBP", "Фунт стерлингов", 0.009424),
                    ("CNY", "Китайский юань", 0.090274),
                    ("JPY", "Японская иена", 1.844905),
                    ("KRW", "Южнокорейская вона", 17.387308),
                    ("INR", "Индийская рупия", 1.091132),
                    ("BRL", "Бразильский реал", 0.06937),
                    ("CAD", "Канадский доллар", 0.017276)
                ]
                
                for (code, name, value) in defaultRates {
                    let rate = RateEntity(context: context)
                    rate.code = code
                    rate.name = name
                    rate.value = value
                    rate.updatedAt = Date()
                }
                
                try context.save()
                self.logger.debug("Added \(defaultRates.count) default rates to CoreData")
                
                // Обновляем локальные данные (будет выполнено после context.perform)
            } catch {
                self.logger.error("Failed to save default rates: \(error)")
            }
        }
        
        // Обновляем локальные данные на главном потоке
        await MainActor.run {
            self.loadLocalRates()
        }
    }

    // MARK: - Private Methods

    private func updateLocalRates(from response: RatesResponse, names: [String: String]) async {
        self.logger.debug("Starting to update local rates...")
        
        // Используем background context для избежания блокировки UI
        let context = self.coreDataStack.persistentContainer.newBackgroundContext()
        
        await context.perform {
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
                
                // Обновление UI будет выполнено после context.perform
            } catch {
                self.logger.error("Failed to save to CoreData: \(error)")
            }
        }
        
        // Обновляем UI на главном потоке асинхронно, не блокируя
        // Это гарантирует, что UI остается отзывчивым
        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.loadLocalRates()
            let oldLastUpdated = self.lastUpdated
            // Используем время из response для точности
            self.lastUpdated = response.updatedAt
            self.logger.debug("updateLocalRates: old lastUpdated=\(oldLastUpdated?.formattedForDisplay() ?? "nil"), new lastUpdated=\(self.lastUpdated?.formattedForDisplay() ?? "nil")")
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
