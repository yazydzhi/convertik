import Foundation

struct AdConfig {
    
    // MARK: - Helper to read from Info.plist
    private static func infoPlistValue(for key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
    
    // MARK: - Banner Ads
    struct Banner {
        static var mainBottom: String {
            #if DEBUG
            // В DEBUG режиме используем тестовые ID (если не переопределены в конфиге)
            return infoPlistValue(for: "ADMOB_BANNER_MAIN_BOTTOM") ?? "ca-app-pub-3940256099942544/2934735716"
            #else
            // В Release читаем из Info.plist (установлено через xcconfig)
            return infoPlistValue(for: "ADMOB_BANNER_MAIN_BOTTOM") ?? "ca-app-pub-3940256099942544/2934735716"
            #endif
        }
    }
    
    // MARK: - Interstitial Ads
    struct Interstitial {
        static var main: String {
            #if DEBUG
            return infoPlistValue(for: "ADMOB_INTERSTITIAL_MAIN") ?? "ca-app-pub-3940256099942544/4411468910"
            #else
            return infoPlistValue(for: "ADMOB_INTERSTITIAL_MAIN") ?? "ca-app-pub-3940256099942544/4411468910"
            #endif
        }
    }
    
    // MARK: - Rewarded Ads
    struct Rewarded {
        static var main: String {
            #if DEBUG
            return infoPlistValue(for: "ADMOB_REWARDED_MAIN") ?? "ca-app-pub-3940256099942544/1712485313"
            #else
            return infoPlistValue(for: "ADMOB_REWARDED_MAIN") ?? "ca-app-pub-3940256099942544/1712485313"
            #endif
        }
    }
    
    // MARK: - App ID
    static var appID: String {
        #if DEBUG
        return infoPlistValue(for: "ADMOB_APP_ID") ?? "ca-app-pub-3940256099942544~1458002511"
        #else
        return infoPlistValue(for: "ADMOB_APP_ID") ?? "ca-app-pub-3940256099942544~1458002511"
        #endif
    }
    
    // MARK: - Ad Frequency Settings
    struct Frequency {
        static let interstitialEvery = 3 // Показывать полноэкранную рекламу каждые N действий
        static let minimumInterval = 60.0 // Минимальный интервал между рекламой в секундах
    }
}
