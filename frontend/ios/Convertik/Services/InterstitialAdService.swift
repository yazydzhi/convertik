import Foundation
import UIKit
import GoogleMobileAds

// MARK: - FullScreenContentDelegate для обработки закрытия рекламы
class InterstitialAdDelegate: NSObject, FullScreenContentDelegate {
    weak var service: InterstitialAdService?
    var onAdDismissed: (() -> Void)?

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("📊 Interstitial ad impression recorded")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Interstitial ad failed to present: \(error.localizedDescription)")
        // Если реклама не показалась, вызываем completion сразу
        onAdDismissed?()
        service?.handleAdDismissed()
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Interstitial ad will present")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Interstitial ad will dismiss")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Interstitial ad dismissed")
        // Вызываем completion только после полного закрытия рекламы
        onAdDismissed?()
        service?.handleAdDismissed()
    }
}

class InterstitialAdService: ObservableObject {
    static let shared = InterstitialAdService()

    @Published var isReady = false
    @Published var isShowingAd = false // Флаг для отслеживания активного показа рекламы (публичный для подписки)

    private var interstitialAd: InterstitialAd?
    private let adUnitID: String
    private var adDelegate: InterstitialAdDelegate?
    private var pendingCompletion: (() -> Void)?

    private init() {
        self.adUnitID = AdConfig.Interstitial.main
        // НЕ загружаем рекламу сразу - отложим до инициализации AdMob SDK
        // loadAd() будет вызван через initializeAd() после инициализации AdMob
    }

    // Метод для инициализации рекламы после загрузки AdMob SDK
    func initializeAd() {
        print("🎯 InterstitialAdService: Initializing ad after AdMob SDK is ready...")
        Task.detached { [weak self] in
            guard let self = self else { return }
            // Добавляем небольшую задержку после инициализации AdMob
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            await MainActor.run {
                self.loadAd()
            }
        }
    }

    private func loadAd() {
        // Загружаем рекламу асинхронно в фоне, не блокируя UI
        print("🎯 InterstitialAdService: Loading interstitial ad with ID: \(adUnitID)")

        Task.detached { [weak self] in
            guard let self = self else { return }
            let request = Request()

            // Загрузка выполняется в фоне
            InterstitialAd.load(with: self.adUnitID, request: request) { ad, error in
                // Обработка результата на главном потоке
                Task { @MainActor in
                    // Проверяем наличие ошибки
                    if let error = error {
                        // Проверяем тип ошибки
                        if let admobError = error as NSError? {
                            // Если это ошибка "No ad to show" (код 1) - это нормальная ситуация
                            if admobError.code == 1 && admobError.domain == "com.google.admob" {
                                print("ℹ️ No interstitial ad available at the moment (this is normal)")
                                print("ℹ️ Ad Unit ID: \(self.adUnitID)")
                                self.isReady = false
                                return
                            }
                        }

                        // Для всех остальных ошибок показываем детальную информацию
                        print("❌ Interstitial ad failed to load!")
                        print("❌ Ad Unit ID: \(self.adUnitID)")
                        print("❌ Error: \(error.localizedDescription)")
                        print("❌ Error details: \(error)")
                        self.isReady = false
                        return
                    }

                    // Проверяем, что реклама загружена
                    guard let ad = ad else {
                        print("⚠️ Interstitial ad loaded but ad is nil")
                        self.isReady = false
                        return
                    }

                    // Устанавливаем делегат для обработки закрытия рекламы
                    let delegate = InterstitialAdDelegate()
                    delegate.service = self
                    ad.fullScreenContentDelegate = delegate
                    self.adDelegate = delegate

                    self.interstitialAd = ad
                    self.isReady = true
                    print("✅ Interstitial ad loaded successfully!")
                    print("✅ Ad Unit ID: \(self.adUnitID)")
                }
            }
        }
    }

    @MainActor
    func showAd(from viewController: UIViewController, completion: @escaping () -> Void = {}) {
        // Проверяем, что реклама не показывается уже
        guard !isShowingAd else {
            print("⚠️ Interstitial ad is already showing, skipping")
            completion()
            return
        }

        guard let interstitialAd = interstitialAd else {
            print("⚠️ Interstitial ad not ready, executing completion immediately")
            completion()
            return
        }

        // Проверяем, что нет активной презентации
        if viewController.presentedViewController != nil {
            print("⚠️ Another presentation is in progress, skipping ad")
            completion()
            return
        }

        // Находим top-most view controller для показа рекламы
        let topViewController = findTopViewController(from: viewController)

        // Проверяем еще раз на top-most view controller
        if topViewController.presentedViewController != nil {
            print("⚠️ Top view controller has active presentation, skipping ad")
            completion()
            return
        }

        // Устанавливаем флаг, что реклама показывается
        isShowingAd = true

        // Сохраняем completion для вызова после закрытия рекламы
        pendingCompletion = completion

        // Устанавливаем делегат с completion
        adDelegate?.onAdDismissed = { [weak self] in
            // Вызываем completion на главном потоке после закрытия рекламы
            // Добавляем небольшую задержку, чтобы UI успел обновиться после закрытия рекламы
            Task { @MainActor in
                // Даем время UI обновиться после закрытия рекламы
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 секунды
                completion()
            }
        }

        // Показываем рекламу на top-most view controller
        interstitialAd.present(from: topViewController)
        AnalyticsService.shared.trackInterstitialAdShown(adUnitId: self.adUnitID)

        // НЕ вызываем completion здесь и НЕ очищаем рекламу
        // Это будет сделано в handleAdDismissed() после закрытия
    }

    /// Находит top-most view controller для показа рекламы
    private func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return findTopViewController(from: presented)
        }

        if let navController = viewController as? UINavigationController,
           let topVC = navController.topViewController {
            return findTopViewController(from: topVC)
        }

        if let tabController = viewController as? UITabBarController,
           let selectedVC = tabController.selectedViewController {
            return findTopViewController(from: selectedVC)
        }

        return viewController
    }

    @MainActor
    func handleAdDismissed() {
        // Сбрасываем флаг показа рекламы
        isShowingAd = false

        // Очищаем текущую рекламу и загружаем следующую
        self.interstitialAd = nil
        self.isReady = false
        self.adDelegate = nil
        self.pendingCompletion = nil

        // Загружаем следующую рекламу
        loadAd()
    }

    func reloadAd() {
        loadAd()
    }
}
