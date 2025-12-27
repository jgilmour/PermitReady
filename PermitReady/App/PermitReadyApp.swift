import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct PermitReadyApp: App {
    init() {
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // Configure test devices for AdMob (development only)
        // Add your test device IDs here - check console logs for the ID when running on a new device
        // These ensure you always see test ads during development
        #if DEBUG
        let testDeviceIDs = [
            "e33520eab294dc0292388b1e48ce96c8",  // Josh's iPhone
            GADSimulatorID  // iOS Simulator
        ]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDeviceIDs
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [QuizAttempt.self, UserProgress.self])
    }
}
