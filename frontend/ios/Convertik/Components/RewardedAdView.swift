import SwiftUI
import UIKit

struct RewardedAdView: UIViewControllerRepresentable {
    @ObservedObject var rewardedService: RewardedAdService
    let completion: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Показываем рекламу когда view появляется
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rewardedService.showAd(from: viewController) { success in
                completion(success)
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Обновление не требуется
    }
}

// MARK: - SwiftUI Wrapper для показа вознаграждаемой рекламы
struct RewardedAdTrigger: View {
    @StateObject private var rewardedService = RewardedAdService.shared
    @State private var showingAd = false
    let trigger: (Bool) -> Void
    
    var body: some View {
        EmptyView()
            .onAppear {
                if rewardedService.isReady {
                    showingAd = true
                } else {
                    trigger(false)
                }
            }
            .fullScreenCover(isPresented: $showingAd) {
                RewardedAdView(rewardedService: rewardedService) { success in
                    showingAd = false
                    trigger(success)
                }
            }
    }
}

// MARK: - Модификатор для добавления вознаграждаемой рекламы к кнопкам
struct RewardedAdModifier: ViewModifier {
    @StateObject private var rewardedService = RewardedAdService.shared
    @State private var showingAd = false
    let action: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if rewardedService.isReady {
                    showingAd = true
                } else {
                    action(false)
                }
            }
            .fullScreenCover(isPresented: $showingAd) {
                RewardedAdView(rewardedService: rewardedService) { success in
                    showingAd = false
                    action(success)
                }
            }
    }
}

extension View {
    func rewardedAd(action: @escaping (Bool) -> Void) -> some View {
        modifier(RewardedAdModifier(action: action))
    }
} 