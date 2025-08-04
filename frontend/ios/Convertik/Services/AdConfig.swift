import Foundation

struct AdConfig {
    
    // MARK: - Banner Ads
    struct Banner {
        #if DEBUG
        static let mainBottom = "ca-app-pub-3940256099942544/2934735716" // Test ID
        #else
        static let mainBottom = "ca-app-pub-xxx/banner_main_bottom" // Production ID
        #endif
    }
    
    // MARK: - Interstitial Ads
    struct Interstitial {
        #if DEBUG
        static let main = "ca-app-pub-3940256099942544/4411468910" // Test ID
        #else
        static let main = "ca-app-pub-xxx/interstitial_main" // Production ID
        #endif
    }
    
    // MARK: - Rewarded Ads
    struct Rewarded {
        #if DEBUG
        static let main = "ca-app-pub-3940256099942544/1712485313" // Test ID
        #else
        static let main = "ca-app-pub-xxx/rewarded_main" // Production ID
        #endif
    }
    
    // MARK: - App ID
    #if DEBUG
    static let appID = "ca-app-pub-3940256099942544~1458002511" // Test App ID
    #else
    static let appID = "ca-app-pub-xxx~app_id" // Production App ID
    #endif
    
    // MARK: - Ad Frequency Settings
    struct Frequency {
        static let interstitialEvery = 3 // Показывать полноэкранную рекламу каждые N действий
        static let minimumInterval = 60.0 // Минимальный интервал между рекламой в секундах
    }
} 