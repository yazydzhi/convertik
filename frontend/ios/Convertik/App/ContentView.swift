import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var ratesRepository: RatesRepository

    var body: some View {
        NavigationView {
            MainListView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Автоматически обновляем курсы при загрузке приложения
            Task {
                await ratesRepository.syncRemote()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsService.shared)
        .environmentObject(RatesRepository.shared)
}
