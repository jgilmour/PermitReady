import Foundation
import SwiftData

@Model
class UserProgress {
    var id: UUID
    var stateCode: String
    var lastStudyDate: Date?
    var currentStreak: Int
    var longestStreak: Int
    var totalQuizzesTaken: Int
    var totalQuestionsAnswered: Int
    var totalCorrectAnswers: Int
    var bestScore: Double
    var categoryMastery: [String: Double]

    init(
        id: UUID = UUID(),
        stateCode: String,
        lastStudyDate: Date? = nil,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalQuizzesTaken: Int = 0,
        totalQuestionsAnswered: Int = 0,
        totalCorrectAnswers: Int = 0,
        bestScore: Double = 0,
        categoryMastery: [String: Double] = [:]
    ) {
        self.id = id
        self.stateCode = stateCode
        self.lastStudyDate = lastStudyDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalQuizzesTaken = totalQuizzesTaken
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.totalCorrectAnswers = totalCorrectAnswers
        self.bestScore = bestScore
        self.categoryMastery = categoryMastery
    }

    var overallMasteryPercentage: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
    }
}

struct CategoryProgress: Codable {
    var attempted: Int
    var correct: Int

    var masteryPercentage: Double {
        guard attempted > 0 else { return 0 }
        return Double(correct) / Double(attempted) * 100
    }
}
