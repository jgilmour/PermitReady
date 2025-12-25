import Foundation
import SwiftData

@Model
class QuestionResponse {
    var questionID: UUID
    var questionText: String
    var questionCategory: String
    var questionImageAssetName: String?
    var questionExplanation: String
    var answers: [String]              // All answer texts in order
    var correctAnswerIndex: Int        // Which answer is correct
    var userAnswerIndex: Int?          // Which answer user selected (nil if unanswered/timed out)
    var isCorrect: Bool

    init(
        questionID: UUID,
        questionText: String,
        questionCategory: String,
        questionImageAssetName: String? = nil,
        questionExplanation: String,
        answers: [String],
        correctAnswerIndex: Int,
        userAnswerIndex: Int?,
        isCorrect: Bool
    ) {
        self.questionID = questionID
        self.questionText = questionText
        self.questionCategory = questionCategory
        self.questionImageAssetName = questionImageAssetName
        self.questionExplanation = questionExplanation
        self.answers = answers
        self.correctAnswerIndex = correctAnswerIndex
        self.userAnswerIndex = userAnswerIndex
        self.isCorrect = isCorrect
    }

    // Convenience initializer from Question and user's choice
    convenience init(from question: Question, userAnswerIndex: Int?) {
        let isCorrect: Bool
        if let userIndex = userAnswerIndex {
            isCorrect = question.isCorrectAnswer(userIndex)
        } else {
            isCorrect = false  // No answer = incorrect
        }

        self.init(
            questionID: question.id,
            questionText: question.questionText,
            questionCategory: question.category.rawValue,
            questionImageAssetName: question.imageAssetName,
            questionExplanation: question.explanation,
            answers: question.answers.map { $0.text },
            correctAnswerIndex: question.correctAnswerIndex,
            userAnswerIndex: userAnswerIndex,
            isCorrect: isCorrect
        )
    }
}
