import Foundation
import SwiftData

@Model
class QuizAttempt {
    var id: UUID
    var stateCode: String
    var category: String?           // nil for full practice test
    var mode: String?               // "practice mode" or "test mode", nil for legacy attempts
    var totalQuestions: Int
    var correctAnswers: Int
    var incorrectQuestionIDs: [UUID]  // Keep for backwards compatibility
    var responses: [QuestionResponse] // NEW: Store all question responses
    var completedAt: Date
    var timeSpentSeconds: Int

    init(
        id: UUID = UUID(),
        stateCode: String,
        category: String? = nil,
        mode: String? = "practice mode",
        totalQuestions: Int,
        correctAnswers: Int,
        incorrectQuestionIDs: [UUID] = [],  // Default to empty for new attempts
        responses: [QuestionResponse] = [],  // NEW
        completedAt: Date = Date(),
        timeSpentSeconds: Int
    ) {
        self.id = id
        self.stateCode = stateCode
        self.category = category
        self.mode = mode
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.incorrectQuestionIDs = incorrectQuestionIDs
        self.responses = responses
        self.completedAt = completedAt
        self.timeSpentSeconds = timeSpentSeconds
    }

    // Computed property to get missed questions from responses
    var missedResponses: [QuestionResponse] {
        responses.filter { !$0.isCorrect }
    }

    var score: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }

    func passed(for state: StateInfo) -> Bool {
        let percentage = Int(score)
        return percentage >= state.passingPercentage
    }
}
