import SwiftUI
import GoogleMobileAds

/// Google AdMob banner ad view
/// Uses test ad unit ID - replace with real ID for production
struct AdBannerView: UIViewRepresentable {
    // TEST Ad Unit ID - shows test ads in development
    // Replace with your real Ad Unit ID from AdMob for production:
    // private let adUnitID = "ca-app-pub-XXXXXXXXXX/YYYYYYYYYY"
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID

        // Get root view controller for ad requests
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }

        // Load the ad
        let request = GADRequest()
        banner.load(request)

        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // No updates needed for static banner
    }
}

#Preview {
    AdBannerView()
}
