import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct PermitReadyApp: App {
    init() {
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [QuizAttempt.self, UserProgress.self])
    }
}
