import BackgroundTasks
import Foundation

final class BackgroundService {
    static let shared = BackgroundService()

    private let refreshTaskId: String = {
        #if DEBUG
        return "com.azg.convertik.refresh"
        #elseif DEPLOY_OLD
        return "com.yazydzhi.convertik.refresh"
        #elseif DEPLOY_NEW
        return "com.azg.convertik.refresh"
        #else
        return "com.azg.convertik.refresh"
        #endif
    }()

    private init() {}

    // MARK: - Registration

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskId,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleAppRefresh(task: refreshTask)
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
            await MainActor.run {
                Task {
                    await RatesRepository.shared.syncRemote()
                    task.setTaskCompleted(success: true)
                }
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
            await MainActor.run {
                Task {
                    await RatesRepository.shared.syncRemote()
                }
            }
        }
    }
}
