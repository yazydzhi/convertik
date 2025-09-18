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
        
        print("📱 AdBannerRepresentable: Creating banner with Ad Unit ID: \(adService.bannerAdUnitID)")
        print("📱 AdBannerRepresentable: Root view controller: \(context.coordinator.getRootViewController() != nil ? "Found" : "Not found")")
        
        // Загружаем рекламу
        let request = Request()
        
        print("📱 AdBannerRepresentable: Loading banner ad...")
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
        private var retryCount = 0
        private let maxRetries = 3 // Максимум 3 попытки
        
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
                print("✅ Banner ad loaded successfully!")
                print("✅ Ad Unit ID: \(bannerView.adUnitID ?? "Unknown")")
                self.parent.adService.isBannerLoaded = true
                self.parent.adService.bannerLoadAttempted = true
                self.parent.adService.trackAdImpression(adUnitId: bannerView.adUnitID ?? "")
            }
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            DispatchQueue.main.async { [self] in
                // Проверяем тип ошибки
                if let admobError = error as NSError? {
                    print("❌ AdMob Error Code: \(admobError.code)")
                    print("❌ AdMob Error Domain: \(admobError.domain)")
                    
                    // Если это ошибка "No ad to show" (код 1) - это нормальная ситуация, не ошибка
                    if admobError.code == 1 && admobError.domain == "com.google.admob" {
                        print("ℹ️ No banner ad available at the moment (this is normal)")
                        print("ℹ️ Ad Unit ID: \(bannerView.adUnitID ?? "Unknown")")
                        self.parent.adService.bannerLoadAttempted = true
                        // Не устанавливаем isBannerLoaded = false для "No ad to show"
                        return
                    }
                }
                
                // Для всех остальных ошибок показываем детальную информацию
                print("❌ Banner ad failed to load!")
                print("❌ Ad Unit ID: \(bannerView.adUnitID ?? "Unknown")")
                print("❌ Error: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                
                // Для реальных ошибок (не "No ad to show") можем попробовать retry
                if let admobError = error as NSError?,
                   !(admobError.code == 1 && admobError.domain == "com.google.admob") {
                    if retryCount < maxRetries {
                        retryCount += 1
                        print("🔄 Retrying banner ad load in 5 seconds... (attempt \(retryCount)/\(maxRetries))")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            bannerView.load(Request())
                        }
                    } else {
                        print("❌ Max retry attempts reached, giving up on banner ad")
                    }
                }
                
                self.parent.adService.isBannerLoaded = false
                self.parent.adService.bannerLoadAttempted = true
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
                    // Всегда создаем AdBannerRepresentable для загрузки рекламы
                    AdBannerRepresentable(adService: adService)
                        .frame(height: 50)
                        .opacity(adService.isBannerLoaded ? 1.0 : 0.0)
                    
                    // Показываем placeholder только если загрузка еще не была попыткой
                    if !adService.isBannerLoaded && !adService.bannerLoadAttempted {
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
            .onAppear {
                print("📱 AdBannerContainerView: isPremium = \(storeService.isPremium)")
                print("📱 AdBannerContainerView: Banner should be visible")
                print("📱 AdBannerContainerView: adService.isBannerLoaded = \(adService.isBannerLoaded)")
            }
        } else {
            EmptyView()
                .onAppear {
                    print("📱 AdBannerContainerView: isPremium = \(storeService.isPremium)")
                    print("📱 AdBannerContainerView: Banner hidden (premium user)")
                }
        }
    }
}

#Preview {
    AdBannerContainerView()
        .environmentObject(SettingsService.shared)
        .environmentObject(ThemeService.shared)
} 