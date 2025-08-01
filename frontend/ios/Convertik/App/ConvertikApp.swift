import SwiftUI
import CoreData

@main
struct ConvertikApp: App {
    // CoreData stack
    let persistenceContainer = CoreDataStack.shared.persistentContainer

    // Services
    @StateObject private var ratesRepository = RatesRepository.shared
    @StateObject private var settingsService = SettingsService.shared
    private let backgroundService = BackgroundService.shared

    init() {
        // Регистрируем фоновые задачи
        backgroundService.registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceContainer.viewContext)
                .environmentObject(ratesRepository)
                .environmentObject(settingsService)
                .preferredColorScheme(settingsService.colorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    backgroundService.applicationDidBecomeActive()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    backgroundService.applicationWillEnterBackground()
                }
        }
    }
}
