import Foundation

@MainActor
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    private let apiService = APIService.shared
    private let settingsService = SettingsService.shared
    private var eventQueue: [StatsEvent] = []
    private let maxBatchSize = 50

    private init() {}

    // MARK: - Event Tracking

    func track(event: String, params: [String: Any]? = nil) {
        let statsEvent = StatsEvent(
            name: event,
            deviceId: settingsService.deviceId,
            timestamp: Date().timeIntervalSince1970,
            params: params?.mapValues(AnyCodable.init)
        )

        eventQueue.append(statsEvent)

        // Отправляем батч если достигли лимита
        if eventQueue.count >= maxBatchSize {
            Task {
                await sendQueuedEvents()
            }
        }
    }

    func sendQueuedEvents() async {
        guard !eventQueue.isEmpty else { return }

        let eventsToSend = Array(eventQueue.prefix(maxBatchSize))

        do {
            try await apiService.sendStats(eventsToSend)
            // Удаляем отправленные события
            eventQueue.removeFirst(min(eventsToSend.count, eventQueue.count))
            print("Sent \(eventsToSend.count) analytics events")
        } catch {
            print("Failed to send analytics: \(error)")
            // События остаются в очереди для повторной отправки
        }
    }

    // MARK: - Predefined Events

    func trackAppOpen() {
        track(event: "app_open")
    }

    func trackConversion(from: String, to targetCurrency: String, amount: Double) {
        track(event: "conversion", params: [
            "from": from,
            "to": targetCurrency,
            "amount": amount
        ])
    }

    func trackCurrencyAdded(_ code: String) {
        track(event: "currency_added", params: [
            "currency": code
        ])
    }

    func trackCurrencyRemoved(_ code: String) {
        track(event: "currency_removed", params: [
            "currency": code
        ])
    }

    func trackCurrencyMoved(_ code: String) {
        track(event: "currency_moved", params: [
            "currency": code
        ])
    }

    func trackSettingsOpened() {
        track(event: "settings_opened")
    }

    func trackThemeChanged(isDark: Bool) {
        track(event: "theme_changed", params: [
            "is_dark": isDark
        ])
    }

    func trackPremiumViewed() {
        track(event: "premium_viewed")
    }

    func trackSubscribeStart(planId: String) {
        track(event: "subscribe_start", params: [
            "plan_id": planId
        ])
    }

    func trackSubscribeSuccess(planId: String, price: String) {
        track(event: "subscribe_success", params: [
            "plan_id": planId,
            "price": price
        ])
    }

    func trackAdImpression(adUnitId: String) {
        track(event: "ad_impression", params: [
            "ad_unit_id": adUnitId
        ])
    }
    
    func trackInterstitialAdShown(adUnitId: String) {
        track(event: "interstitial_ad_shown", params: [
            "ad_unit_id": adUnitId
        ])
    }
    
    func trackRewardedAdCompleted(adUnitId: String, rewardAmount: Int, rewardType: String) {
        track(event: "rewarded_ad_completed", params: [
            "ad_unit_id": adUnitId,
            "reward_amount": rewardAmount,
            "reward_type": rewardType
        ])
    }
}
