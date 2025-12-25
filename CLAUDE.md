# PermitReady - iOS Drivers Ed App

## Project Overview
PermitReady is an iOS app targeting teenagers (15-17) preparing for their learner's permit exam. The app covers Massachusetts plus 11 high-volume states with state-specific test requirements.

## Technical Stack
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS Version**: iOS 17.0
- **Architecture**: MVVM
- **Build Tool**: xcodegen

## Build Instructions

### Initial Setup
1. Generate Xcode project from project.yml:
   ```bash
   xcodegen generate
   ```

2. Open the generated project:
   ```bash
   open PermitReady.xcodeproj
   ```

### Building
Always use the `--quiet` flag to prevent context overflow:

```bash
xcodebuild -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 16' build --quiet
```

### Running Tests
```bash
xcodebuild test -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 16' --quiet
```

## Project Structure
- **App/**: App entry point and root views
- **Core/**: Shared data models, services, and extensions
- **Features/**: Feature modules organized by functionality
- **Resources/**: Assets, localization, and Info.plist
- **Tests/**: Unit and UI tests

## Important Notes
- **DO NOT** edit .xcodeproj files directly - always modify project.yml and regenerate
- Keep .xcodeproj in .gitignore
- All question banks are bundled as JSON in Core/Data/QuestionBanks/
- App is designed for offline-first usage

## Version Control
This project uses Git for version control.

### Git Workflow
1. Create a feature branch for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit frequently:
   ```bash
   git add .
   git commit -m "Descriptive commit message"
   ```

3. Push to GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub for review

### Important Git Notes
- The `.xcodeproj` file is **gitignored** since it's generated from `project.yml`
- Always regenerate the project after pulling changes: `xcodegen generate`
- Commit message format: Use present tense ("Add feature" not "Added feature")
- SwiftData database files (`.sqlite*`) are gitignored

### Changelog Maintenance
**IMPORTANT**: All changes must be documented in `CHANGELOG.md` before committing.

1. Before making changes, update the `[Unreleased]` section in CHANGELOG.md
2. Categorize changes under:
   - **Added** - New features
   - **Changed** - Changes to existing functionality
   - **Deprecated** - Soon-to-be removed features
   - **Removed** - Removed features
   - **Fixed** - Bug fixes
   - **Security** - Security improvements
3. When ready to release a version, move items from `[Unreleased]` to a new version section with date
4. Commit the CHANGELOG.md with your other changes

## Development Workflow
1. Create a new feature branch from `main`
2. Make changes to source files or project.yml
3. **Update CHANGELOG.md** with your changes in the `[Unreleased]` section
4. If project.yml changed, run `xcodegen generate`
5. Build and test using xcodebuild commands above
6. Commit your changes with descriptive messages: `git add . && git commit -m "Your message"`
7. **Push to GitHub**: `git push origin your-branch-name`
8. Create a Pull Request on GitHub for review
9. Use XcodeBuildMCP for simulator interaction and screenshots

### Commit Best Practices
- **Always** update CHANGELOG.md before committing
- **Always** push commits to GitHub after local commits
- Write clear, descriptive commit messages
- Commit frequently - don't batch too many changes together
- Test your changes before committing

## Current Implementation Status

### Phase 1: Foundation (✅ Complete)
- ✅ Folder structure and basic app entry point
- ✅ Core data models (Question, State, QuizAttempt, UserProgress)
- ✅ QuestionService for JSON loading
- ✅ Complete Quiz flow with animations
- ✅ Confetti celebrations and haptic feedback

### Phase 2: Progress Tracking (✅ Complete)
- ✅ ProgressService for SwiftData queries
- ✅ Quiz history tracking
- ✅ Overall mastery percentage
- ✅ Category-by-category breakdown
- ✅ Study streak tracking (current and longest)
- ✅ Best score tracking
- ✅ ProgressView with stats dashboard

### Phase 3: Study Mode (✅ Complete)
- ✅ Category selection screen
- ✅ Category-specific quizzes
- ✅ Display mastery percentage for each category
- ✅ Visual indicators (Proficient, Learning, Needs Practice, Not Started)
- ✅ Progress bars showing category mastery

### Phase 4: Test Mode (✅ Complete)
- ✅ QuizMode enum (Practice vs Test)
- ✅ Timer functionality for test mode (30 minutes)
- ✅ Hide explanations during test mode
- ✅ No confetti celebrations in test mode
- ✅ Disable retake option in test mode results
- ✅ Different result messages for test vs practice
- ✅ Timer header with countdown display
- ✅ Timer turns red when <5 minutes remain
- ✅ Track quiz mode in QuizAttempt model

### Phase 5: Multi-State Support (✅ Complete)
- ✅ 13 state question banks (MA, CA, TX, FL, NY, PA, IL, OH, NC, MI, GA, NJ, VA)
- ✅ State selection UI with searchable list
- ✅ State-specific test requirements and passing scores
- ✅ Support for split-test states (IL, OH, NC, GA, VA)
- ✅ Per-state progress tracking
- ✅ Dynamic question count based on state requirements

### Phase 6: Enhanced Learning Features (✅ Complete)
- ✅ Missed Questions Review - review incorrect answers after quiz
- ✅ Answer shuffling to prevent answer pattern memorization
- ✅ State-specific category filtering
- ✅ QuestionResponse model for complete answer tracking
- ✅ Backward compatibility with legacy quiz attempts

### Phase 7: UX Polish & Onboarding (✅ Complete)
- ✅ 5-screen onboarding flow with state selection
- ✅ Settings screen with tutorial re-access
- ✅ Haptic feedback throughout app (medium impact for buttons, selection for state picking)
- ✅ Pulsing app icon loading states
- ✅ Share score feature for passing quizzes
- ✅ Pass celebration with triple confetti burst
- ✅ Fixed answer transition animations
- ✅ Optimized results screen layout for mobile
- ✅ Context-aware share messages (quiz type, category, state)

## Features

### Quiz Experience
- Practice Mode:
  - 25-question quizzes with no time limit
  - Detailed explanations after each answer
  - Confetti animation on correct answers
  - Retake option available on results screen
  - Review missed questions with correct/incorrect answers highlighted
- Test Mode:
  - 25-question timed test (30 minutes for MA)
  - No explanations during quiz
  - Timer header with countdown (turns red <5 min)
  - No retake option available
  - Different pass/fail messages
- Both Modes:
  - Color-coded answer feedback (green for correct, red for incorrect)
  - Haptic feedback for correct/incorrect responses
  - Progress bar showing quiz completion
  - Results screen with pass/fail status (optimized for mobile viewports)
  - Category-specific study mode
  - Randomized answer order to prevent pattern memorization
  - Share score feature (passing scores only)
  - Triple confetti celebration on pass with success haptics
  - Pulsing app icon during question loading

### Onboarding & Settings
- 5-screen interactive onboarding flow:
  1. Welcome screen with app intro
  2. State selection (required, auto-advances)
  3. Study modes explanation (Practice Quiz vs Practice Test)
  4. Learning tools overview (Study by Category, Review Mistakes)
  5. Progress tracking features with Get Started button
- Skip button on screens 3 & 4
- Help button (gear icon) in navigation bar for settings access
- Settings screen with:
  - State selection
  - Tutorial re-access
  - App version and about info
- First-launch detection with UserDefaults

### Progress Tracking
- Overall mastery percentage across all quizzes
- Category mastery breakdown with visual progress bars
- Study streak tracking (current and longest streak)
- Quiz history showing recent attempts with mode indicators
- Best score tracking
- State-specific progress tracking for all 13 supported states
- Missed questions review from quiz history

### Study Mode
- Browse available categories (varies by state)
- See mastery level for each category (Proficient 80%+, Learning 60-79%, Needs Practice <60%)
- Start category-specific quizzes to focus on weak areas
- Visual progress bars for each category
- Color-coded mastery indicators
- Only shows categories with questions available for selected state

### Multi-State Support
- 13 states supported: MA, CA, TX, FL, NY, PA, IL, OH, NC, MI, GA, NJ, VA
- Easy state switching from home screen
- State-specific test requirements displayed
- Different question counts per state (18-50 questions)
- Variable passing scores (70%-85%)
- Special handling for split-test states (IL, OH, NC, GA, VA)

## Data Models

### Question
- State-specific question banks loaded from JSON
- Categories: Road Signs, Traffic Laws, Safe Driving, Parking, Right of Way, Fines & Limits
- Difficulty levels: Easy, Medium, Hard
- Optional image assets for visual questions
- Answer order randomized to prevent pattern memorization

### QuestionResponse
- Stores complete question data with user's selected answer
- Used for missed questions review feature
- Tracks question text, all answer options, correct answer, and user's choice
- Includes explanation for review

### QuizAttempt
- Tracks each quiz completion
- Records score, time spent, and incorrect questions
- Stores full QuestionResponse array for missed questions review
- Links to specific state and category
- Stores quiz mode (practice or test)
- Used for progress calculations
- Backward compatible with legacy attempts (incorrectQuestionIDs)

### UserProgress
- Per-state progress tracking
- Total quizzes taken and questions answered
- Category mastery percentages
- Study streak calculations
- Best score achieved
