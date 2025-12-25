import Foundation
import SwiftUI

@MainActor
class AdManager: ObservableObject {
    static let shared = AdManager()

    @Published var shouldShowAd = false

    private var questionCount = 0
    private let adFrequency = 10 // Show ad every 10 questions

    private init() {}

    // MARK: - Ad Display Logic

    /// Call this after each question is answered
    func trackQuestion() {
        // Don't track if user has purchased ad removal
        guard !StoreManager.shared.isAdFree else { return }

        questionCount += 1

        // Show ad every 10 questions
        if questionCount % adFrequency == 0 {
            shouldShowAd = true
        }
    }

    /// Call when ad is dismissed
    func dismissAd() {
        shouldShowAd = false
    }

    /// Reset question count (call when starting new quiz)
    func reset() {
        questionCount = 0
        shouldShowAd = false
    }

    /// Check if ads should be shown at all
    var adsEnabled: Bool {
        !StoreManager.shared.isAdFree
    }
}
