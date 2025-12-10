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
            // НЕ запускаем синхронизацию здесь - RatesRepository уже запускает её через 1 секунду
            // Это предотвращает дублирование синхронизаций и ускоряет запуск
            // Локальные данные уже загружены в RatesRepository.init()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsService.shared)
        .environmentObject(RatesRepository.shared)
}
