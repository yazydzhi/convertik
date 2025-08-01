import BackgroundTasks
import Foundation

final class BackgroundService {
    static let shared = BackgroundService()
    
    private let refreshTaskId = "com.azg.convertik.refresh"
    private let ratesRepository = RatesRepository.shared
    
    private init() {}
    
    // MARK: - Registration
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskId,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60) // 6 часов
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    // MARK: - Handling
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Планируем следующее обновление
        scheduleAppRefresh()
        
        // Создаем задачу для обновления курсов
        let refreshTask = Task {
            do {
                await ratesRepository.syncRemote()
                task.setTaskCompleted(success: true)
            } catch {
                print("Background refresh failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
        
        // Отменяем задачу если система остановила выполнение
        task.expirationHandler = {
            refreshTask.cancel()
            task.setTaskCompleted(success: false)
        }
    }
    
    // MARK: - Application Lifecycle
    
    func applicationWillEnterBackground() {
        scheduleAppRefresh()
    }
    
    func applicationDidBecomeActive() {
        // Обновляем курсы при активации приложения
        Task {
            await ratesRepository.syncRemote()
        }
    }
}