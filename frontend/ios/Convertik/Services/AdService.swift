import Foundation
import SwiftUI
import GoogleMobileAds

class AdService: ObservableObject {
    static let shared = AdService()
    
    @Published var isBannerLoaded = false
    @Published var isInterstitialReady = false
    
    // Ad Unit IDs
    let bannerAdUnitID: String
    let interstitialAdUnitID: String
    
    private var interstitialAd: InterstitialAd?
    
    private init() {
        self.bannerAdUnitID = AdConfig.Banner.mainBottom
        self.interstitialAdUnitID = AdConfig.Interstitial.main
        setupAds()
    }
    
    private func setupAds() {
        MobileAds.shared.start { status in
            print("Google Mobile Ads SDK initialization status: \(status)")
        }
        loadInterstitialAd()
    }
    
    func reloadBanner() {
        isBannerLoaded = false
        // Баннер перезагружается автоматически через AdBannerRepresentable
    }
    
    private func loadInterstitialAd() {
        let request = Request()
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    self?.isInterstitialReady = false
                    return
                }
                
                self?.interstitialAd = ad
                self?.isInterstitialReady = true
                print("Interstitial ad loaded successfully")
            }
        }
    }
    
    @MainActor
    func showInterstitialAd(from viewController: UIViewController, completion: @escaping () -> Void = {}) {
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad not ready")
            completion()
            return
        }
        
        interstitialAd.present(from: viewController)
        self.trackAdImpression(adUnitId: self.interstitialAdUnitID)
        completion()
        
        // Перезагружаем следующий interstitial
        self.interstitialAd = nil
        self.isInterstitialReady = false
        loadInterstitialAd()
    }
    
    @MainActor
    func trackAdImpression(adUnitId: String) {
        AnalyticsService.shared.track(event: "ad_impression", params: [
            "ad_unit_id": adUnitId
        ])
    }
    
    @MainActor
    func trackAdClick(adUnitId: String) {
        AnalyticsService.shared.track(event: "ad_click", params: [
            "ad_unit_id": adUnitId
        ])
    }
} 