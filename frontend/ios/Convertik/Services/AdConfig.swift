import Foundation

struct AdConfig {
    
    // MARK: - Banner Ads
    struct Banner {
        #if DEBUG
        static let mainBottom = "ca-app-pub-3940256099942544/2934735716" // Test ID
        #elseif DEPLOY_OLD
        static let mainBottom = "ca-app-pub-3963008621997262/9525729746" // Production ID - Old Version
        #elseif DEPLOY_NEW
        static let mainBottom = "ca-app-pub-3963008621997262/6595790670" // Production ID - New Version
        #else
        static let mainBottom = "ca-app-pub-3963008621997262/6595790670" // Production ID - Default
        #endif
    }
    
    // MARK: - Interstitial Ads
    struct Interstitial {
        #if DEBUG
        static let main = "ca-app-pub-3940256099942544/4411468910" // Test ID
        #elseif DEPLOY_OLD
        static let main = "ca-app-pub-3963008621997262/2960321390" // Production ID - Old Version
        #elseif DEPLOY_NEW
        static let main = "ca-app-pub-3963008621997262/7703529229" // Production ID - New Version
        #else
        static let main = "ca-app-pub-3963008621997262/7703529229" // Production ID - Default
        #endif
    }
    
    // MARK: - Rewarded Ads
    struct Rewarded {
        #if DEBUG
        static let main = "ca-app-pub-3940256099942544/1712485313" // Test ID
        #elseif DEPLOY_OLD
        static let main = "ca-app-pub-3963008621997262/rewarded_main_old" // Production ID - Old Version
        #elseif DEPLOY_NEW
        static let main = "ca-app-pub-3963008621997262/rewarded_main_new" // Production ID - New Version
        #else
        static let main = "ca-app-pub-3963008621997262/rewarded_main_new" // Production ID - Default
        #endif
    }
    
    // MARK: - App ID
    #if DEBUG
    static let appID = "ca-app-pub-3940256099942544~1458002511" // Test App ID
    #elseif DEPLOY_OLD
    static let appID = "ca-app-pub-3963008621997262~3198843168" // Production App ID - Old Version
    #elseif DEPLOY_NEW
    static let appID = "ca-app-pub-3963008621997262~7232833541" // Production App ID - New Version
    #else
    static let appID = "ca-app-pub-3963008621997262~7232833541" // Production App ID - Default
    #endif
    
    // MARK: - Ad Frequency Settings
    struct Frequency {
        static let interstitialEvery = 3 // Показывать полноэкранную рекламу каждые N действий
        static let minimumInterval = 60.0 // Минимальный интервал между рекламой в секундах
    }
} 
