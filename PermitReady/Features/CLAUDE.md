# Features Module

## Purpose
Contains all feature-specific UI and business logic organized by functionality.

## Feature Organization
Each feature follows the same structure:
- **Views/**: SwiftUI view components
- **ViewModels/**: Observable view models following MVVM pattern

## Features

### Onboarding/
First-time user experience and app introduction

### StateSelection/
State picker and state-specific requirement display

### Quiz/
Core quiz functionality:
- QuizView: Main quiz coordinator
- QuestionCardView: Individual question display
- AnswerButtonView: Answer selection buttons
- QuizResultsView: Score and results display
- QuizViewModel: Quiz state management

### Progress/
Progress tracking dashboard and statistics

### StudyMode/
Flashcard-style study mode with spaced repetition

### Settings/
App settings and state switching

## MVVM Architecture
- Views are declarative SwiftUI
- ViewModels are @Observable classes (Swift 6)
- ViewModels depend on Core services via protocol injection
