# Core Module

## Purpose
The Core module contains shared data models, services, and utilities used across all features.

## Structure

### Data/
- **Models/**: Swift data models (Question, QuizAttempt, UserProgress, State)
- **QuestionBanks/**: JSON files containing questions for each state

### Services/
- **QuestionService**: Loads and manages question banks from bundled JSON files
- **ProgressService**: Manages user progress tracking with SwiftData
- **ContentUpdateService**: Handles future question bank updates

### Extensions/
Common Swift extensions used throughout the app

## Key Design Decisions
- Questions are bundled as JSON to enable offline usage
- SwiftData models (@Model) are used for persistent user data
- Codable structs for immutable reference data (questions, states)
- Services follow protocol-based design for testability
