# PermitReady

An iOS app designed to help teenagers (15-17) prepare for their learner's permit exam with state-specific practice tests and study tools.

## Features

### Multi-State Support
- **13 states supported**: Massachusetts, California, Texas, Florida, New York, Pennsylvania, Illinois, Ohio, North Carolina, Michigan, Georgia, New Jersey, Virginia
- State-specific test requirements and passing scores
- Unique requirements displayed for each state
- Easy state switching from the home screen

### Quiz Modes
- **Practice Quiz**: 25-question quizzes with detailed explanations, no time limit, and immediate feedback
- **Practice Test**: Timed 30-minute tests that simulate the real exam experience

### Learning Tools
- **Study by Category**: Focus on specific topics like Road Signs, Traffic Laws, Safe Driving, Parking, Right of Way, and Fines & Limits
- **Review Mistakes**: Revisit incorrect answers from previous quizzes
- **Answer Randomization**: Prevents pattern memorization for better learning

### Progress Tracking
- Overall mastery percentage across all quizzes
- Category-by-category breakdown with visual progress bars
- Study streak tracking (current and longest)
- Best score tracking
- Complete quiz history with mode indicators

### User Experience
- 5-screen interactive onboarding flow
- Haptic feedback throughout the app
- Confetti celebrations for correct answers and passing scores
- Share your passing scores
- Optimized for all iOS device sizes

## Technical Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS Version**: iOS 17.0
- **Architecture**: MVVM
- **Build Tool**: xcodegen

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ simulator or device
- [xcodegen](https://github.com/yonaskolb/XcodeGen) installed

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jgilmour/PermitReady.git
   cd PermitReady
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open PermitReady.xcodeproj
   ```

4. Build and run in Xcode (⌘R)

### Building from Command Line

```bash
# Build
xcodebuild -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build --quiet

# Run tests
xcodebuild test -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 17 Pro' --quiet
```

## Project Structure

```
PermitReady/
├── App/                    # App entry point and root views
├── Core/                   # Shared data models, services, and extensions
│   ├── Data/              # Data models and question banks (JSON)
│   ├── Services/          # Business logic and data services
│   ├── Extensions/        # SwiftUI extensions and utilities
│   └── Views/             # Reusable UI components
├── Features/              # Feature modules
│   ├── Onboarding/       # First-launch onboarding flow
│   ├── Quiz/             # Quiz and test experience
│   ├── Progress/         # Progress tracking and analytics
│   ├── Settings/         # App settings
│   └── StateSelection/   # State picker
└── Resources/             # Assets, localization, and Info.plist
```

## Development

### Workflow
1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. If you modified `project.yml`, regenerate: `xcodegen generate`
4. Build and test
5. Commit: `git commit -m "Add feature description"`
6. Push: `git push origin feature/your-feature-name`
7. Create a Pull Request on GitHub

### Important Notes
- **DO NOT** edit `.xcodeproj` files directly - always modify `project.yml` and regenerate
- The `.xcodeproj` directory is gitignored since it's generated from `project.yml`
- Always run `xcodegen generate` after pulling changes that modify `project.yml`
- All question banks are bundled as JSON in `Core/Data/QuestionBanks/`
- SwiftData database files are gitignored (`.sqlite*`)

## Data Models

- **Question**: State-specific questions with categories, difficulty levels, and optional images
- **QuestionResponse**: Complete question data with user's selected answer for review
- **QuizAttempt**: Tracks each quiz completion with score, time, and incorrect questions
- **UserProgress**: Per-state progress tracking with mastery percentages and streaks
- **StateInfo**: State-specific test requirements and configurations

## Legal Disclaimer

**Important Notice:**

This app is not affiliated with, endorsed by, or sponsored by any Department of Motor Vehicles (DMV), Registry of Motor Vehicles (RMV), or government agency.

Practice questions are for informational and educational purposes only and do not guarantee passing the official permit exam. All content is derived from publicly available state driver handbooks and manuals. Question formats and content may differ from actual state exams.

Always verify current requirements and regulations with your state's official DMV/RMV website before taking the official exam.

## License

Copyright © 2025 Josh Gilmour. All rights reserved.

## Contact

Josh Gilmour - [@jgilmour](https://github.com/jgilmour)

Project Link: [https://github.com/jgilmour/PermitReady](https://github.com/jgilmour/PermitReady)
