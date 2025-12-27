# Changelog

All notable changes to PermitReady will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SECURITY.md with comprehensive security guidelines for public repository
- Security section in CLAUDE.md with prohibited content and safe practices
- Enhanced .gitignore with security-focused exclusions for sensitive files
- Pre-commit security checklist
- Example code patterns for handling API keys safely
- Legal disclaimers in Settings screen for DMV non-affiliation and liability
- About section in Settings with app version and legal information
- StoreManager for in-app purchase handling ($1.99 ad removal)
- InterstitialAdManager for smart full-screen ad management
- Hybrid ad frequency capping (5-minute cooldown + every 2 completions)
- Purchase UI in Settings screen with restore purchases
- Ad-free status persistence with UserDefaults
- Google AdMob SDK integration for interstitial ads
- Test ad unit IDs for development and testing
- SKAdNetwork identifiers for ad attribution
- AdMob initialization in app startup
- Interstitial ads before quiz/test/category results
- PRODUCTION_CHECKLIST.md for pre-launch configuration tracking
- Production readiness section in CLAUDE.md
- Future analytics integration plan deferred to post-launch (TelemetryDeck recommended)

### Changed
- Updated .gitignore to exclude API keys, certificates, and configuration files
- Updated CLAUDE.md with security best practices for public repository
- Updated CLAUDE.md with monetization phase and production tracking requirements
- Corrected simulator name in build instructions from iPhone 16 to iPhone 17 Pro
- Downgraded Swift version from 6.0 to 5.10 for Google Ads SDK compatibility
- Set SWIFT_STRICT_CONCURRENCY to minimal for Google Ads SDK
- Privacy policy requirements simplified (AdMob + IAP only, no analytics initially)

### Fixed
- Documentation incorrectly referenced iPhone 16 simulator instead of iPhone 17 Pro
- Updated year from 2024 to 2025 in README, SECURITY, and CHANGELOG
- Interstitial ad presentation timing conflict between UIKit and SwiftUI view hierarchy (QuizView.swift:131)
- Added 9 missing SKAdNetwork identifiers from Google's recommended list (Info.plist:245-280)

## [0.1.0] - 2025-12-24

### Added
- Initial project setup with xcodegen
- 13 state question banks (MA, CA, TX, FL, NY, PA, IL, OH, NC, MI, GA, NJ, VA)
- Practice Quiz mode with detailed explanations
- Practice Test mode with 30-minute timer
- Study by Category feature
- Progress tracking with mastery percentages
- Study streak tracking
- Quiz history with missed questions review
- 5-screen onboarding flow
- State selection with unique requirements display
- Settings screen with state switching and tutorial access
- Haptic feedback throughout app
- Confetti celebrations for correct answers
- Share score functionality
- Answer randomization to prevent pattern memorization
- Optimized home screen UX with hierarchical navigation
- State-specific test requirements displayed in:
  - Home screen (expandable section)
  - State selection screen (expandable per state)
  - Onboarding flow (auto-display on selection)

### Technical
- SwiftUI + SwiftData architecture
- MVVM pattern
- iOS 17.0+ minimum deployment
- Offline-first design with bundled JSON question banks
- Git version control with GitHub integration
