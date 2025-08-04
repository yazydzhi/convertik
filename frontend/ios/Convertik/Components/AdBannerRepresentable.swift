import SwiftUI
import GoogleMobileAds

// MARK: - UIKit Wrapper для BannerView
struct AdBannerRepresentable: UIViewRepresentable {
    @ObservedObject var adService: AdService
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adService.bannerAdUnitID
        bannerView.rootViewController = context.coordinator.getRootViewController()
        bannerView.delegate = context.coordinator
        
        // Загружаем рекламу
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Обновление не требуется
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        var parent: AdBannerRepresentable
        
        init(_ parent: AdBannerRepresentable) {
            self.parent = parent
        }
        
        func getRootViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return nil
            }
            return window.rootViewController
        }
        
        // MARK: - BannerViewDelegate
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            DispatchQueue.main.async {
                self.parent.adService.isBannerLoaded = true
                self.parent.adService.trackAdImpression(adUnitId: bannerView.adUnitID ?? "")
            }
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            DispatchQueue.main.async {
                self.parent.adService.isBannerLoaded = false
                print("Banner ad failed to load: \(error.localizedDescription)")
            }
        }
        
        func bannerViewDidRecordClick(_ bannerView: BannerView) {
            self.parent.adService.trackAdClick(adUnitId: bannerView.adUnitID ?? "")
        }
    }
}

// MARK: - Placeholder для случаев когда реклама недоступна
struct AdBannerPlaceholder: View {
    @ObservedObject var adService: AdService
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        Rectangle()
            .fill(themeManager.cardBackground)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "megaphone.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.amberAccent)
                    
                    Text("Рекламный баннер")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("Здесь будет реклама Google AdMob")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary.opacity(0.7))
                }
            )
            .frame(height: 50)
    }
}

// MARK: - Основной контейнер рекламы
struct AdBannerContainerView: View {
    @StateObject private var adService = AdService.shared
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var storeService: StoreService
    @Environment(\.themeManager) private var themeManager
    @State private var showingPaywall = false
    
    var body: some View {
        if !storeService.isPremium {
            VStack(spacing: 0) {
                // Заголовок рекламы
                HStack {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(themeManager.amberAccent)
                        .font(.caption)
                    
                    Text("Реклама")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Spacer()
                    
                    Button("Убрать") {
                        showingPaywall = true
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.amberAccent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.cardBackground)
                
                // Баннер рекламы
                ZStack {
                    if adService.isBannerLoaded {
                        AdBannerRepresentable(adService: adService)
                            .frame(height: 50)
                    } else {
                        // Placeholder пока баннер загружается
                        Rectangle()
                            .fill(themeManager.cardBackground)
                            .overlay(
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Загрузка рекламы...")
                                        .font(.caption)
                                        .foregroundColor(themeManager.textSecondary)
                                }
                            )
                            .frame(height: 50)
                    }
                }
            }
            .background(themeManager.cardBackground)
            .cornerRadius(ConvertikCornerRadius.sm)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .accessibilityHidden(true) // Скрываем от accessibility
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

#Preview {
    AdBannerContainerView()
        .environmentObject(SettingsService.shared)
        .environmentObject(ThemeService.shared)
} 