import SwiftUI
import UIKit

struct InterstitialAdView: UIViewControllerRepresentable {
    @ObservedObject var interstitialService: InterstitialAdService
    let completion: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Показываем рекламу когда view появляется
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            interstitialService.showAd(from: viewController) {
                completion()
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Обновление не требуется
    }
}

// MARK: - SwiftUI Wrapper для показа рекламы
struct InterstitialAdTrigger: View {
    @StateObject private var interstitialService = InterstitialAdService.shared
    @State private var showingAd = false
    let trigger: () -> Void
    
    var body: some View {
        EmptyView()
            .onAppear {
                if interstitialService.isReady {
                    showingAd = true
                } else {
                    trigger()
                }
            }
            .fullScreenCover(isPresented: $showingAd) {
                InterstitialAdView(interstitialService: interstitialService) {
                    showingAd = false
                    trigger()
                }
            }
    }
}

// MARK: - Модификатор для добавления рекламы к кнопкам
struct InterstitialAdModifier: ViewModifier {
    @StateObject private var interstitialService = InterstitialAdService.shared
    @State private var showingAd = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if interstitialService.isReady {
                    showingAd = true
                } else {
                    action()
                }
            }
            .fullScreenCover(isPresented: $showingAd) {
                InterstitialAdView(interstitialService: interstitialService) {
                    showingAd = false
                    action()
                }
            }
    }
}

extension View {
    func interstitialAd(action: @escaping () -> Void) -> some View {
        modifier(InterstitialAdModifier(action: action))
    }
} 