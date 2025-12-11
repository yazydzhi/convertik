import SwiftUI
import GoogleMobileAds

// MARK: - UIKit Wrapper для BannerView
struct AdBannerRepresentable: UIViewRepresentable {
    @ObservedObject var adService: AdService

    func makeUIView(context: Context) -> BannerView {
        // Используем адаптивный баннер для лучшего использования пространства
        // Создание BannerView не блокирует UI - это легкая операция
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adService.bannerAdUnitID
        bannerView.delegate = context.coordinator

        print("📱 AdBannerRepresentable: Creating adaptive banner with Ad Unit ID: \(adService.bannerAdUnitID)")

        // НЕ получаем rootViewController сразу - это может блокировать UI
        // Установим его асинхронно в updateUIView когда AdMob будет готов
        // Это критично для быстрого запуска и неблокирующего UI

        // НЕ загружаем рекламу сразу - отложим до инициализации AdMob SDK
        // Загрузка будет выполнена через updateUIView после инициализации AdMob
        // Это ускоряет показ UI и не блокирует интерфейс

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Загружаем рекламу только если AdMob SDK инициализирован и еще не пытались загрузить
        // ВСЕ операции выполняются асинхронно, не блокируя UI
        if adService.isAdMobInitialized && !adService.bannerLoadAttempted {
            // Получаем rootViewController и загружаем рекламу асинхронно на главном потоке
            // Это гарантирует, что UI не блокируется, но rootViewController будет найден
            Task { @MainActor in
                let coordinator = context.coordinator
                let rootVC = coordinator.getRootViewController()

                uiView.rootViewController = rootVC
                print("📱 AdBannerRepresentable: Root view controller: \(rootVC != nil ? "Found" : "Not found")")

                if rootVC != nil {
                    print("📱 AdBannerRepresentable: Loading banner ad (AdMob is ready, async)...")
                    // Загружаем рекламу асинхронно - это не блокирует UI
                    let request = Request()
                    uiView.load(request)
                } else {
                    // Если rootViewController еще не готов, попробуем через небольшую задержку
                    print("⚠️ AdBannerRepresentable: Root view controller not ready, retrying in 0.5s...")
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
                    let retryRootVC = coordinator.getRootViewController()
                    uiView.rootViewController = retryRootVC
                    if retryRootVC != nil {
                        print("📱 AdBannerRepresentable: Root view controller found on retry, loading ad...")
                        let request = Request()
                        uiView.load(request)
                    } else {
                        print("⚠️ AdBannerRepresentable: Root view controller still not found, ad will load when ready")
                    }
                }
            }
        }
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
            // Получаем rootViewController - должен вызываться на главном потоке
            // Пробуем несколько способов получения rootViewController для надежности
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return nil
            }

            // Пробуем получить из первого окна
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window.rootViewController
            }

            // Если ключевое окно не найдено, пробуем первое доступное
            if let window = windowScene.windows.first {
                return window.rootViewController
            }

            return nil
        }

        // MARK: - BannerViewDelegate

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            Task { @MainActor in
                print("✅ Banner ad loaded successfully!")
                print("✅ Ad Unit ID: \(bannerView.adUnitID ?? "Unknown")")
                // Обновляем состояние на главном потоке для правильного обновления SwiftUI
                self.parent.adService.isBannerLoaded = true
                self.parent.adService.bannerLoadAttempted = true
                self.parent.adService.trackAdImpression(adUnitId: bannerView.adUnitID ?? "")

                // Принудительно обновляем view для отображения баннера
                // Это гарантирует, что SwiftUI обновит opacity
                print("📱 Banner visibility updated: isBannerLoaded = \(self.parent.adService.isBannerLoaded)")

                // Планируем автоматическое обновление баннера через 45 секунд
                // Это соответствует рекомендациям Google AdMob
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 45_000_000_000) // 45 секунд
                    print("🔄 Auto-refreshing banner ad...")
                    bannerView.load(Request())
                }
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
            .frame(height: 60) // Увеличиваем высоту для лучшей видимости
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
                // Показываем placeholder сразу, реклама загрузится асинхронно в фоне
                ZStack {
                    // AdBannerRepresentable создается, но не блокирует UI
                    // Загрузка рекламы происходит асинхронно в фоне
                    if adService.isBannerLoaded {
                        AdBannerRepresentable(adService: adService)
                            .frame(height: 60)
                            .transition(.opacity)
                    } else {
                        // Показываем минималистичный placeholder пока реклама не загружена
                        // Это не блокирует UI - просто визуальный элемент
                        Rectangle()
                            .fill(themeManager.cardBackground.opacity(0.5))
                            .frame(height: 60)
                            .overlay(
                                // Показываем индикатор только если AdMob еще не инициализирован
                                Group {
                                    if !adService.isAdMobInitialized {
                                        HStack(spacing: 4) {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                            Text("Загрузка...")
                                                .font(.caption2)
                                                .foregroundColor(themeManager.textSecondary.opacity(0.6))
                                        }
                                    } else {
                                        // После инициализации AdMob показываем минимальный placeholder
                                        Color.clear
                                    }
                                }
                            )
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: adService.isBannerLoaded)
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
