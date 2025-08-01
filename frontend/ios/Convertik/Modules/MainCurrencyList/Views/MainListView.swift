import SwiftUI

struct MainListView: View {
    @EnvironmentObject private var ratesRepository: RatesRepository
    @EnvironmentObject private var settingsService: SettingsService
    @StateObject private var analyticsService = AnalyticsService.shared
    @StateObject private var viewModel = MainListViewModel()
    
    @State private var showingAddCurrency = false
    @State private var showingSettings = false
    @State private var amount: String = "100"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поле ввода суммы
                amountInputSection
                
                // Список валют
                currencyListSection
                
                // Баннер рекламы (если не Premium)
                if !settingsService.isPremium {
                    AdBannerView()
                        .frame(height: 50)
                        .onAppear {
                            analyticsService.trackAdImpression(adUnitId: "ca-app-pub-test/banner_main_bottom")
                        }
                }
            }
            .navigationTitle("Конвертик v1.1")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    lastUpdatedView
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingAddCurrency = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .refreshable {
                await ratesRepository.syncRemote()
            }
            .sheet(isPresented: $showingAddCurrency) {
                AddCurrencyView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                analyticsService.trackAppOpen()
                
                // Загружаем курсы в фоне
                Task {
                    await ratesRepository.syncRemote()
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var amountInputSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Сумма для конвертации:")
                    .font(.headline)
                Spacer()
            }
            
            TextField("Введите сумму", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: amount) { newValue in
                    viewModel.updateAmount(newValue)
                }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var currencyListSection: some View {
        List {
            ForEach(viewModel.displayedCurrencies, id: \.rate.code) { item in
                CurrencyRowView(
                    rate: item.rate,
                    convertedAmount: item.convertedAmount,
                    inputAmount: viewModel.amountValue
                )
            }
            .onDelete(perform: deleteCurrencies)
        }
        .listStyle(PlainListStyle())
    }
    
    private var lastUpdatedView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let lastUpdated = ratesRepository.lastUpdated {
                Text("Обновлено")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Не обновлено")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteCurrencies(offsets: IndexSet) {
        for index in offsets {
            let currency = viewModel.displayedCurrencies[index]
            settingsService.removeCurrency(currency.rate.code)
            analyticsService.trackCurrencyRemoved(currency.rate.code)
        }
        viewModel.updateDisplayedCurrencies()
    }
}

#Preview {
    MainListView()
        .environmentObject(RatesRepository.shared)
        .environmentObject(SettingsService.shared)
}