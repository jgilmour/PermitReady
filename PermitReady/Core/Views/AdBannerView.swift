import SwiftUI

/// Placeholder ad banner view
/// Replace with actual ad network SDK (Google AdMob, etc.) when ready to monetize
struct AdBannerView: View {
    let isDevelopment = true // Set to false when using real ads

    var body: some View {
        if isDevelopment {
            // Development placeholder
            VStack(spacing: 4) {
                Text("Ad Banner Placeholder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Replace with AdMob/ad network")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
        } else {
            // TODO: Integrate real ad network here
            // Example for Google AdMob:
            // GADBannerView(adSize: GADAdSizeBanner, adUnitID: "your-ad-unit-id")
            EmptyView()
        }
    }
}

#Preview {
    AdBannerView()
}
