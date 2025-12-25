import SwiftUI
import SwiftData

@main
struct PermitReadyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [QuizAttempt.self, UserProgress.self])
    }
}
