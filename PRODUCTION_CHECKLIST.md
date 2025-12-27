# Production Readiness Checklist

This document tracks all changes required before releasing PermitReady to the App Store.

## ⚠️ CRITICAL - Required Before Submission

### 1. Apple Developer Account Configuration
- [ ] Set up Apple Developer Account (if not already done)
- [ ] Create App ID in Apple Developer Portal
- [ ] Update `DEVELOPMENT_TEAM` in project.yml with your Team ID
- [ ] Update `PRODUCT_BUNDLE_IDENTIFIER` in project.yml (change from `com.yourname.permitready`)

**File:** `project.yml`
```yaml
DEVELOPMENT_TEAM: "YOUR_TEAM_ID_HERE"  # Line 23
PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.permitready  # Line 40
```

### 2. Google AdMob Configuration
- [ ] Create AdMob account at https://admob.google.com
- [ ] Create new AdMob app for iOS
- [ ] Create Interstitial Ad Unit for production
- [ ] Replace test IDs with production IDs
- [ ] Remove test device IDs from production build

**File:** `PermitReady/Core/Services/InterstitialAdManager.swift`
```swift
// Line 14 - Replace test ad unit ID
private let adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"  // Your real interstitial ad unit
```

**File:** `PermitReady/Resources/Info.plist`
```xml
<!-- Line 50 - Replace test app ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>  <!-- Your real AdMob app ID -->
```

**File:** `PermitReady/App/PermitReadyApp.swift`
```swift
// Lines 14-20 - Remove or update test device IDs before production
// The #if DEBUG wrapper ensures this code is only active in debug builds
// You can leave the code as-is since it won't run in release builds
// OR remove the test device ID list entirely if you prefer
```

### 3. In-App Purchase Configuration
- [ ] Create IAP in App Store Connect (Consumable or Non-Consumable)
- [ ] Set price to $1.99 USD
- [ ] Product ID should match: `com.yourcompany.permitready.removeads`
- [ ] Update product ID in code if different

**File:** `PermitReady/Core/Services/StoreManager.swift`
```swift
// Line 9 - Verify product ID matches App Store Connect
private let removeAdsProductID = "com.yourcompany.permitready.removeads"
```

**Note:** For local testing before App Store Connect setup:
- A StoreKit configuration file is included: `PermitReady.storekit`
- This allows testing IAP functionality in Xcode without App Store Connect
- The StoreKit file uses product ID: `com.yourname.permitready.removeads`
- Update this to match your final bundle ID when ready for production

### 4. App Metadata & Info.plist
- [ ] Verify app display name is correct
- [ ] Update bundle version for release
- [ ] Ensure all required permissions are documented

**File:** `project.yml`
```yaml
MARKETING_VERSION: "1.0.0"  # Line 21 - Verify version number
CURRENT_PROJECT_VERSION: "1"  # Line 22 - Build number
```

## 🔧 Technical Considerations

### 5. Swift Version (Post-Launch)
- [ ] Monitor Google Mobile Ads SDK updates for Swift 6 compatibility
- [ ] When SDK supports Swift 6, update configuration:

**File:** `project.yml`
```yaml
# Consider updating after Google Ads SDK adds Swift 6 support
SWIFT_VERSION: "6.0"  # Currently 5.10
SWIFT_STRICT_CONCURRENCY: complete  # Currently minimal
```

### 6. Ad Frequency Tuning (Post-Launch Optimization)
- [ ] Monitor ad performance in AdMob dashboard
- [ ] Adjust frequency capping based on user feedback and revenue data
- [ ] Current settings: 5 minutes + every 2 completions

**File:** `PermitReady/Core/Services/InterstitialAdManager.swift`
```swift
// Lines 21-22 - Adjust these values based on analytics
private let minimumTimeBetweenAds: TimeInterval = 300  // 5 minutes
private let minimumCompletionsBeforeAd = 2
```

## 📱 Testing Requirements

### 7. Pre-Submission Testing
- [ ] Test with real AdMob ads (not test ads)
- [ ] Verify ad-free purchase works correctly
- [ ] Test "Restore Purchases" functionality
- [ ] Test on multiple iOS versions (17.0+)
- [ ] Test on different device sizes (iPhone SE, Pro Max, iPad)
- [ ] Verify ads don't show after purchase
- [ ] Test frequency capping works as expected
- [ ] Verify all 13 state question banks load correctly
- [ ] Test offline functionality
- [ ] Complete full quiz/test flow for each state

### 8. App Store Connect Configuration
- [ ] Create app listing in App Store Connect
- [ ] Prepare app screenshots (required sizes)
- [ ] Write app description
- [ ] Add app privacy details
- [ ] Set age rating (likely 4+)
- [ ] Configure pricing and availability
- [ ] Set up App Store Connect API key for CI/CD (optional)

### 9. Legal & Compliance
- [ ] Review and finalize disclaimer text in Settings
- [ ] Create Privacy Policy (required for IAP and AdMob)
  - Disclose: AdMob ad serving, IAP data handling
  - Host publicly: GitHub Pages, Netlify, or similar
  - Keep it simple: No analytics tracking yet (deferred post-launch)
- [ ] Add Privacy Policy URL to App Store Connect
- [ ] Add Privacy Policy link to Settings → About section (in-app)
- [ ] Review AdMob compliance (COPPA, GDPR if applicable)
- [ ] Verify SKAdNetwork identifiers are complete in Info.plist

### 10. Build & Archive
- [ ] Regenerate Xcode project: `xcodegen generate`
- [ ] Set scheme to Release configuration
- [ ] Archive build from Xcode
- [ ] Upload to App Store Connect via Xcode or Transporter
- [ ] Submit for App Store Review

## 📊 Post-Launch Monitoring

### Week 1-2 After Launch
- [ ] Monitor crash reports in App Store Connect
- [ ] Check AdMob dashboard for ad performance (CPM, fill rate, impressions)
- [ ] Monitor IAP conversion rate
- [ ] Review user feedback and ratings
- [ ] Track key metrics:
  - Downloads
  - Active users
  - Average revenue per user (ARPU)
  - Ad impressions vs IAP purchases
  - Retention rate

### Optimization Opportunities
- [ ] A/B test ad frequency if revenue is low
- [ ] Consider adding banner ads to home screen if interstitials underperform
- [ ] Monitor which states are most popular (currently manual via App Store Analytics)
- [ ] Track which quiz modes are used most (practice vs test)
- [ ] Gather feedback for future feature updates

### Future Feature: Analytics Integration (Post-Launch)
**Decision:** Deferred until after initial launch to reduce complexity and privacy concerns.

When ready to add analytics, recommended approach:
- [ ] **TelemetryDeck** (privacy-first, free tier, no consent required)
  - Track state selection distribution
  - Quiz vs Test mode usage
  - Category popularity and difficulty
  - Completion rates and scores
  - Daily/weekly active users
  - IAP conversion funnel
- [ ] Create privacy policy (required with analytics)
- [ ] Add Privacy Policy link to Settings → About section
- [ ] Host privacy policy on GitHub Pages or similar
- [ ] Update App Store Connect with privacy policy URL
- [ ] Add Privacy Nutrition Labels in App Store Connect

**Why wait:**
- Launch faster with simpler app
- Less privacy concerns for teen audience
- Use App Store Analytics + AdMob dashboard initially
- Add based on actual user feedback and needs
- Avoid premature optimization

**Documentation:** See analytics discussion in session notes for full implementation plan.

## 🚀 Quick Reference - Production IDs Needed

Create these before launch:

1. **Apple Developer Portal:**
   - Team ID
   - Bundle Identifier (recommend: `com.yourcompany.permitready`)

2. **AdMob:**
   - App ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)
   - Interstitial Ad Unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)

3. **App Store Connect:**
   - IAP Product ID (recommend: `com.yourcompany.permitready.removeads`)
   - Set price: $1.99 USD

## 📝 Notes

- Test ad IDs are safe to commit to public repo
- Production ad IDs are also safe to commit (they're not secrets)
- Never commit: certificates, provisioning profiles, API keys, passwords
- Keep `.gitignore` up to date with security exclusions

## ✅ Pre-Submission Command

Before submitting, run these commands to verify everything builds:

```bash
# Regenerate project
xcodegen generate

# Build for release
xcodebuild -scheme PermitReady -configuration Release -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run tests
xcodebuild test -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

**Last Updated:** 2025-12-27
**Current Status:** Development with test IDs
**Target Launch:** TBD
