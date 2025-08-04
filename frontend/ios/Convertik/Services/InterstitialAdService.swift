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
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    self?.isReady = false
                    return
                }
                
                self?.interstitialAd = ad
                self?.isReady = true
                print("Interstitial ad loaded successfully")
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