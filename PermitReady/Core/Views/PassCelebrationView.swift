import SwiftUI

struct PassCelebrationView: View {
    var body: some View {
        ZStack {
            // Triple confetti burst for extra celebration!
            ConfettiView()
            ConfettiView()
            ConfettiView()
        }
        .onAppear {
            // Success haptic
            HapticManager.notification(.success)

            // Additional impact haptics for extra feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                HapticManager.impact(.heavy)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                HapticManager.impact(.heavy)
            }
        }
    }
}

#Preview {
    PassCelebrationView()
}
