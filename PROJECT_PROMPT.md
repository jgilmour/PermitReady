# iOS Drivers Ed App - Claude Code Project Prompt

## Project Overview

Build an iOS app called **"PermitReady"** (working title) - a drivers ed test prep app targeting teenagers (15-17) preparing for their learner's permit exam. The app will cover Massachusetts plus high-volume states (California, Texas, Florida, New York, Pennsylvania, Illinois, Ohio, North Carolina, Michigan, Georgia, New Jersey, Virginia).

## Technical Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS Version**: iOS 17.0
- **Architecture**: MVVM
- **Build Tool**: xcodegen (do NOT edit .xcodeproj directly - modify project.yml and regenerate)

## Project Structure

Create the following folder hierarchy:

```
PermitReady/
├── project.yml                 # xcodegen configuration
├── CLAUDE.md                   # Root project context file
├── App/
│   ├── PermitReadyApp.swift
│   └── ContentView.swift
├── Core/
│   ├── CLAUDE.md              # Core module context
│   ├── Data/
│   │   ├── QuestionBanks/     # JSON files per state
│   │   │   ├── massachusetts.json
│   │   │   ├── california.json
│   │   │   └── ... (other states)
│   │   └── Models/
│   │       ├── Question.swift
│   │       ├── QuizAttempt.swift
│   │       ├── UserProgress.swift
│   │       └── State.swift
│   ├── Services/
│   │   ├── QuestionService.swift
│   │   ├── ProgressService.swift
│   │   └── ContentUpdateService.swift
│   └── Extensions/
├── Features/
│   ├── CLAUDE.md              # Features module context
│   ├── Onboarding/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── StateSelection/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Quiz/
│   │   ├── Views/
│   │   │   ├── QuizView.swift
│   │   │   ├── QuestionCardView.swift
│   │   │   ├── AnswerButtonView.swift
│   │   │   └── QuizResultsView.swift
│   │   └── ViewModels/
│   │       └── QuizViewModel.swift
│   ├── Progress/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── StudyMode/
│   │   ├── Views/
│   │   └── ViewModels/
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
└── Tests/
    ├── UnitTests/
    └── UITests/
```

## Data Models

### Question.swift
```swift
struct Question: Codable, Identifiable {
    let id: UUID
    let stateCode: String           // "MA", "CA", "TX", etc.
    let category: QuestionCategory
    let questionText: String
    let answers: [Answer]
    let correctAnswerIndex: Int
    let explanation: String
    let imageAssetName: String?     // For road sign questions
    let difficulty: Difficulty
    
    enum QuestionCategory: String, Codable, CaseIterable {
        case roadSigns
        case rightOfWay
        case speedLimits
        case parking
        case safeDriving
        case alcoholDrugs
        case emergencies
        case stateSpecific
    }
    
    enum Difficulty: String, Codable {
        case easy, medium, hard
    }
}

struct Answer: Codable, Identifiable {
    let id: UUID
    let text: String
}
```

### State.swift
```swift
struct StateInfo: Codable, Identifiable {
    let id: String                  // State code: "MA", "CA"
    let name: String
    let minimumPermitAge: Double    // 15.5 for California
    let testQuestionCount: Int
    let passingPercentage: Int
    let hasSplitTest: Bool          // Illinois, Ohio, NC
    let splitTestInfo: SplitTestInfo?
    let uniqueRequirements: [String]
}

struct SplitTestInfo: Codable {
    let sections: [TestSection]
}

struct TestSection: Codable {
    let name: String                // "Road Signs", "Traffic Rules"
    let questionCount: Int
    let passingPercentage: Int
}
```

### QuizAttempt.swift (SwiftData)
```swift
@Model
class QuizAttempt {
    var id: UUID
    var stateCode: String
    var category: String?           // nil for full practice test
    var totalQuestions: Int
    var correctAnswers: Int
    var incorrectQuestionIDs: [UUID]
    var completedAt: Date
    var timeSpentSeconds: Int
    
    var score: Double {
        Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var passed: Bool {
        // Compare against state's passing percentage
    }
}
```

## State Test Requirements Reference

Build the app to accommodate these variations:

| State | Questions | Pass % | Special Format |
|-------|-----------|--------|----------------|
| Massachusetts | 25 | 72% | Standard |
| California | 46 | 83% | Longest test |
| Texas | 30 | 70% | Lowest threshold |
| Florida | 50 | 80% | Standard |
| New York | 20 | 70% | Must pass 2/4 road signs |
| Pennsylvania | 18 | 83% | Highest threshold |
| Illinois | 35 | 80% | Split: 15 signs + 20 rules |
| Ohio | 40 | 75% | Split: two 20-question sections |
| North Carolina | 25 | 80% | Separate oral signs test |

## Core Features to Implement

### 1. State Selection & Onboarding
- Clean state picker with search
- Show state-specific requirements (age, test format, passing score)
- Allow changing state later in settings
- Store selected state in UserDefaults

### 2. Practice Quiz Modes
- **Quick Quiz**: 10-15 random questions from selected categories
- **Full Practice Test**: Mirrors actual state test (question count, time limit if applicable, passing threshold)
- **Category Focus**: Practice specific topics (road signs, right-of-way, etc.)
- **Missed Questions Review**: Quiz only on previously incorrect answers
- **Split Test Mode**: For IL, OH, NC - separate section practice

### 3. Progress Tracking (SwiftData)
- Overall mastery percentage per state
- Category-by-category breakdown
- Study streak tracking (consecutive days)
- Quiz history with scores
- "Ready to Test" indicator when consistently scoring above passing

### 4. Study Mode (Non-Quiz)
- Flashcard-style review of questions
- Swipe right = know it, swipe left = need practice
- Spaced repetition algorithm for review scheduling
- Road sign gallery with meanings

### 5. Offline Support
- All questions bundled in app
- Progress synced to SwiftData locally
- No network required for core functionality

## UI/UX Guidelines

### Design Principles
- **Teen-friendly**: Modern, clean, not patronizing
- **Confidence-building**: Celebrate progress, encouraging messaging
- **Anxiety-reducing**: Clear feedback, no harsh failure states
- **Fast**: Minimize taps to start practicing

### Color Scheme (Suggestions)
- Primary: Confident blue (#2563EB)
- Success: Green (#10B981)
- Error: Soft red (#EF4444) - not alarming
- Background: Clean white/light gray
- Support dark mode

### Key Screens
1. **Home**: State shown, quick actions (Start Quiz, Continue Studying), progress ring
2. **Quiz**: Card-based questions, clear answer buttons, immediate feedback with explanation
3. **Results**: Score, pass/fail against state threshold, breakdown by category, option to review missed
4. **Progress**: Charts showing improvement over time, category mastery, streak counter
5. **Settings**: Change state, notifications, reset progress

## Question Bank JSON Format

Each state file (e.g., `massachusetts.json`):

```json
{
  "stateCode": "MA",
  "version": "1.0.0",
  "lastUpdated": "2025-01-15",
  "questions": [
    {
      "id": "uuid-here",
      "category": "roadSigns",
      "questionText": "What does a yellow diamond-shaped sign indicate?",
      "answers": [
        {"id": "a1", "text": "A warning about road conditions ahead"},
        {"id": "a2", "text": "A regulatory requirement you must follow"},
        {"id": "a3", "text": "Information about services nearby"},
        {"id": "a4", "text": "A route marker"}
      ],
      "correctAnswerIndex": 0,
      "explanation": "Yellow diamond-shaped signs are warning signs that alert drivers to potential hazards or changes in road conditions ahead.",
      "imageAssetName": "sign_warning_diamond",
      "difficulty": "easy"
    }
  ]
}
```

## Implementation Phases

### Phase 1: Foundation (Start Here)
1. Set up xcodegen project structure
2. Create CLAUDE.md files for each module
3. Implement data models
4. Build QuestionService to load JSON
5. Create basic Quiz flow (QuizView → QuestionCardView → Results)
6. Massachusetts questions only (50-75 questions to start)

### Phase 2: Polish & Persistence
1. Implement SwiftData for progress tracking
2. Add Progress dashboard
3. Build Study Mode with flashcards
4. Add animations and haptic feedback
5. Implement all quiz modes

### Phase 3: Multi-State Expansion
1. Add California and Texas question banks
2. Implement state-specific test formats
3. Handle split-test states (Illinois, Ohio)
4. Add remaining priority states

### Phase 4: Monetization & Launch
1. Implement free tier limitations (100-150 questions)
2. Add StoreKit 2 for in-app purchases
3. Build paywall UI
4. Add required disclaimers
5. Prepare App Store assets

## Required Disclaimers (Must Include)

Add to Settings/About and App Store description:

> "PermitReady is not affiliated with, endorsed by, or sponsored by any Department of Motor Vehicles or government agency. Practice questions are created for educational purposes based on publicly available state driver manuals. This app does not guarantee passing the official permit exam. Always refer to your state's official driver handbook for the most current information."

## Build Commands

When building, always use the `--quiet` flag to prevent context overflow:

```bash
xcodebuild -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 16' build --quiet
```

## Getting Started

Begin by:
1. Creating the xcodegen `project.yml` file
2. Setting up the folder structure
3. Creating the root `CLAUDE.md` with build instructions
4. Implementing the Question and StateInfo models
5. Building a basic QuestionService that loads from bundled JSON
6. Creating a simple QuizView that displays questions and tracks score

Focus on getting a working quiz flow for Massachusetts before expanding. Prioritize clean architecture that scales to multiple states.

---

## Notes for Claude Code

- Use XcodeBuildMCP for building and simulator interaction
- Always regenerate project with `xcodegen generate` after modifying project.yml
- Keep .xcodeproj in .gitignore
- Test on iPhone 16 simulator by default
- Capture screenshots after significant UI changes for review
