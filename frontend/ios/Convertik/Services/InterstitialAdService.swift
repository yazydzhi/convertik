import Foundation
import UIKit
import GoogleMobileAds

class InterstitialAdService: ObservableObject {
    static let shared = InterstitialAdService()
    
    @Published var isReady = false
    
    private var interstitialAd: InterstitialAd?
    private let adUnitID: String
    
    private init() {
        self.adUnitID = AdConfig.Interstitial.main
        loadAd()
    }
    
    private func loadAd() {
        print("🎯 InterstitialAdService: Loading interstitial ad with ID: \(adUnitID)")
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Проверяем тип ошибки
                    if let admobError = error as NSError? {
                        // Если это ошибка "No ad to show" (код 1) - это нормальная ситуация
                        if admobError.code == 1 && admobError.domain == "com.google.admob" {
                            print("ℹ️ No interstitial ad available at the moment (this is normal)")
                            print("ℹ️ Ad Unit ID: \(self?.adUnitID ?? "Unknown")")
                            self?.isReady = false
                            return
                        }
                    }
                    
                    // Для всех остальных ошибок показываем детальную информацию
                    print("❌ Interstitial ad failed to load!")
                    print("❌ Ad Unit ID: \(self?.adUnitID ?? "Unknown")")
                    print("❌ Error: \(error.localizedDescription)")
                    print("❌ Error details: \(error)")
                    self?.isReady = false
                    return
                }
                
                self?.interstitialAd = ad
                self?.isReady = true
                print("✅ Interstitial ad loaded successfully!")
                print("✅ Ad Unit ID: \(self?.adUnitID ?? "Unknown")")
            }
        }
    }
    
    @MainActor
    func showAd(from viewController: UIViewController, completion: @escaping () -> Void = {}) {
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad not ready")
            completion()
            return
        }

        interstitialAd.present(from: viewController)
        AnalyticsService.shared.trackInterstitialAdShown(adUnitId: self.adUnitID)
        completion()

        // Перезагружаем следующий interstitial
        self.interstitialAd = nil
        self.isReady = false
        loadAd()
    }
    
    func reloadAd() {
        loadAd()
    }
} 