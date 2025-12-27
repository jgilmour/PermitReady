// Note: Google Mobile Ads SDK doesn't fully support Swift 6 concurrency yet.
// Using @preconcurrency to handle the transition period.

import Foundation
@preconcurrency import GoogleMobileAds
import UIKit

@MainActor
class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()

    // TEST Interstitial Ad Unit ID - shows test ads in development
    // Replace with your real Ad Unit ID from AdMob for production
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

    @Published var isAdReady = false
    private var interstitial: GADInterstitialAd?
    private var onAdDismissed: (() -> Void)?

    // Frequency capping
    private let minimumTimeBetweenAds: TimeInterval = 300 // 5 minutes
    private let minimumCompletionsBeforeAd = 2
    private var lastAdShowTime: Date?
    private var completionsSinceLastAd = 0

    // UserDefaults keys
    private let lastAdTimeKey = "lastInterstitialAdTime"
    private let completionsCountKey = "completionsSinceLastAd"

    private override init() {
        super.init()
        loadFromUserDefaults()
    }

    // MARK: - Public Interface

    /// Check if we should show an ad based on frequency capping
    func shouldShowAd() -> Bool {
        // Never show ads if user purchased ad removal
        guard !StoreManager.shared.isAdFree else { return false }

        // Check completion count
        guard completionsSinceLastAd >= minimumCompletionsBeforeAd else {
            return false
        }

        // Check time since last ad
        if let lastTime = lastAdShowTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastTime)
            guard timeSinceLastAd >= minimumTimeBetweenAds else {
                return false
            }
        }

        return true
    }

    /// Track a quiz/test/category completion
    func trackCompletion() {
        completionsSinceLastAd += 1
        saveToUserDefaults()
    }

    /// Load an interstitial ad
    func loadAd() {
        guard !StoreManager.shared.isAdFree else { return }

        let request = GADRequest()

        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    self.isAdReady = false
                    return
                }

                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.isAdReady = true
                print("Interstitial ad loaded successfully")
            }
        }
    }

    /// Show the interstitial ad
    func showAd(from viewController: UIViewController, onDismiss: @escaping () -> Void) {
        guard shouldShowAd(), let interstitial = interstitial, isAdReady else {
            // If we shouldn't show ad or ad not ready, call dismiss immediately
            onDismiss()
            return
        }

        self.onAdDismissed = onDismiss
        interstitial.present(fromRootViewController: viewController)

        // Update tracking
        lastAdShowTime = Date()
        completionsSinceLastAd = 0
        isAdReady = false
        saveToUserDefaults()

        // Load next ad for future use
        loadAd()
    }

    /// Show ad with automatic root view controller detection
    func showAdIfNeeded(onDismiss: @escaping () -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            // If can't get view controller, just call dismiss
            onDismiss()
            return
        }

        showAd(from: rootViewController, onDismiss: onDismiss)
    }

    // MARK: - Persistence

    private func loadFromUserDefaults() {
        if let lastTime = UserDefaults.standard.object(forKey: lastAdTimeKey) as? Date {
            lastAdShowTime = lastTime
        }
        completionsSinceLastAd = UserDefaults.standard.integer(forKey: completionsCountKey)
    }

    private func saveToUserDefaults() {
        if let lastTime = lastAdShowTime {
            UserDefaults.standard.set(lastTime, forKey: lastAdTimeKey)
        }
        UserDefaults.standard.set(completionsSinceLastAd, forKey: completionsCountKey)
    }
}

// MARK: - GADFullScreenContentDelegate

extension InterstitialAdManager: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor [weak self] in
            print("Interstitial ad dismissed")
            self?.onAdDismissed?()
            self?.onAdDismissed = nil
        }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor [weak self] in
            print("Interstitial ad failed to present: \(error.localizedDescription)")
            self?.onAdDismissed?()
            self?.onAdDismissed = nil
        }
    }
}
