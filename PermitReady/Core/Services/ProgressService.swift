import Foundation
import SwiftData

protocol ProgressServiceProtocol {
    func getQuizHistory(for stateCode: String, modelContext: ModelContext) throws -> [QuizAttempt]
    func getUserProgress(for stateCode: String, modelContext: ModelContext) throws -> UserProgress?
    func getOrCreateUserProgress(for stateCode: String, modelContext: ModelContext) throws -> UserProgress
    func updateUserProgress(for stateCode: String, attempt: QuizAttempt, modelContext: ModelContext) throws
    func getMissedQuestionIDs(for stateCode: String, modelContext: ModelContext) throws -> [UUID]
}

class ProgressService: ProgressServiceProtocol {
    func getQuizHistory(for stateCode: String, modelContext: ModelContext) throws -> [QuizAttempt] {
        let predicate = #Predicate<QuizAttempt> { attempt in
            attempt.stateCode == stateCode
        }

        let descriptor = FetchDescriptor<QuizAttempt>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func getUserProgress(for stateCode: String, modelContext: ModelContext) throws -> UserProgress? {
        let predicate = #Predicate<UserProgress> { progress in
            progress.stateCode == stateCode
        }

        let descriptor = FetchDescriptor<UserProgress>(predicate: predicate)
        let results = try modelContext.fetch(descriptor)

        return results.first
    }

    func getOrCreateUserProgress(for stateCode: String, modelContext: ModelContext) throws -> UserProgress {
        if let existing = try getUserProgress(for: stateCode, modelContext: modelContext) {
            return existing
        }

        let newProgress = UserProgress(stateCode: stateCode)
        modelContext.insert(newProgress)
        try modelContext.save()

        return newProgress
    }

    func updateUserProgress(for stateCode: String, attempt: QuizAttempt, modelContext: ModelContext) throws {
        let progress = try getOrCreateUserProgress(for: stateCode, modelContext: modelContext)

        // Update total stats
        progress.totalQuizzesTaken += 1
        progress.totalQuestionsAnswered += attempt.totalQuestions
        progress.totalCorrectAnswers += attempt.correctAnswers

        // Update best score if this is better
        let scorePercentage = Double(attempt.correctAnswers) / Double(attempt.totalQuestions) * 100
        if scorePercentage > progress.bestScore {
            progress.bestScore = scorePercentage
        }

        // Update category mastery
        if let categoryName = attempt.category {
            let categoryScore = Double(attempt.correctAnswers) / Double(attempt.totalQuestions) * 100
            progress.categoryMastery[categoryName] = max(
                progress.categoryMastery[categoryName] ?? 0,
                categoryScore
            )
        }

        // Update study streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastStudyDate = progress.lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastStudyDate)
            let daysBetween = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0

            if daysBetween == 0 {
                // Same day, streak continues
            } else if daysBetween == 1 {
                // Consecutive day, increment streak
                progress.currentStreak += 1
                progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
            } else {
                // Streak broken, reset to 1
                progress.currentStreak = 1
            }
        } else {
            // First quiz ever
            progress.currentStreak = 1
            progress.longestStreak = 1
        }

        progress.lastStudyDate = Date()

        try modelContext.save()
    }

    func getMissedQuestionIDs(for stateCode: String, modelContext: ModelContext) throws -> [UUID] {
        let attempts = try getQuizHistory(for: stateCode, modelContext: modelContext)

        // Collect all incorrect question IDs from all quiz attempts
        var missedIDs = Set<UUID>()
        for attempt in attempts {
            missedIDs.formUnion(attempt.incorrectQuestionIDs)
        }

        return Array(missedIDs)
    }
}
