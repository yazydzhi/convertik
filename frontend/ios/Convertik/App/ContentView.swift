import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settingsService: SettingsService

    var body: some View {
        NavigationView {
            MainListView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsService.shared)
        .environmentObject(RatesRepository.shared)
}
