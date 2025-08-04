import Foundation
import UIKit
import GoogleMobileAds

class RewardedAdService: ObservableObject {
    static let shared = RewardedAdService()
    
    @Published var isReady = false
    
    private var rewardedAd: RewardedAd?
    private let adUnitID: String
    
    private init() {
        self.adUnitID = AdConfig.Rewarded.main
        loadAd()
    }
    
    private func loadAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load rewarded ad: \(error.localizedDescription)")
                    self?.isReady = false
                    return
                }
                
                self?.rewardedAd = ad
                self?.isReady = true
                print("Rewarded ad loaded successfully")
            }
        }
    }
    
    @MainActor
    func showAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let rewardedAd = rewardedAd else {
            print("Rewarded ad not ready")
            completion(false)
            return
        }

        rewardedAd.present(from: viewController) {
            // Пользователь получил награду
            AnalyticsService.shared.trackRewardedAdCompleted(adUnitId: self.adUnitID, rewardAmount: 1, rewardType: "currency")
            completion(true)
        }

        // Перезагружаем следующий rewarded ad
        self.rewardedAd = nil
        self.isReady = false
        loadAd()
    }
    
    func reloadAd() {
        loadAd()
    }
} 