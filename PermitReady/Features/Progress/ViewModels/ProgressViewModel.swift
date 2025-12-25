import Foundation
import SwiftData

@Observable
class ProgressViewModel {
    private let progressService: ProgressServiceProtocol
    private let stateCode: String
    private let modelContext: ModelContext

    private(set) var quizHistory: [QuizAttempt] = []
    private(set) var userProgress: UserProgress?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    var overallMasteryPercentage: Double {
        guard let progress = userProgress,
              progress.totalQuestionsAnswered > 0 else {
            return 0
        }
        return Double(progress.totalCorrectAnswers) / Double(progress.totalQuestionsAnswered) * 100
    }

    var recentQuizzes: [QuizAttempt] {
        Array(quizHistory.prefix(5))
    }

    var categoryBreakdown: [(category: Question.QuestionCategory, mastery: Double)] {
        guard let progress = userProgress else { return [] }

        return Question.QuestionCategory.allCases.compactMap { category in
            if let mastery = progress.categoryMastery[category.rawValue] {
                return (category, mastery)
            }
            return nil
        }.sorted { $0.mastery > $1.mastery }
    }

    init(
        progressService: ProgressServiceProtocol,
        stateCode: String,
        modelContext: ModelContext
    ) {
        self.progressService = progressService
        self.stateCode = stateCode
        self.modelContext = modelContext
    }

    @MainActor
    func loadProgress() {
        isLoading = true
        error = nil

        do {
            quizHistory = try progressService.getQuizHistory(
                for: stateCode,
                modelContext: modelContext
            )
            userProgress = try progressService.getUserProgress(
                for: stateCode,
                modelContext: modelContext
            )
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
