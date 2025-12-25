# Changelog

All notable changes to PermitReady will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CHANGELOG.md to track all project changes
- README.md with comprehensive project documentation

### Changed
- Updated CLAUDE.md with Git workflow instructions

## [0.1.0] - 2024-12-24

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
