import SwiftUI

struct QuestionCardView: View {
    let question: Question
    let questionNumber: Int
    let totalQuestions: Int
    let selectedAnswerIndex: Int?
    let hasAnswered: Bool
    let showExplanation: Bool
    let onSelectAnswer: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Question header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Question \(questionNumber) of \(totalQuestions)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Category badge
                    Text(question.category.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                // Difficulty indicator
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index < difficultyLevel ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    Text(question.difficulty.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Question text
            Text(question.questionText)
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            // Image (if available) - only show if image exists in assets
            if let imageAssetName = question.imageAssetName,
               UIImage(named: imageAssetName) != nil {
                Image(imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 8)
            }

            // Answer options
            VStack(spacing: 12) {
                ForEach(Array(question.answers.enumerated()), id: \.offset) { index, answer in
                    AnswerButtonView(
                        answer: answer,
                        index: index,
                        isSelected: selectedAnswerIndex == index,
                        hasAnswered: hasAnswered,
                        isCorrect: question.isCorrectAnswer(index),
                        action: { onSelectAnswer(index) }
                    )
                }
            }
            .id(question.id)

            // Explanation (shown after answering in practice mode only)
            if hasAnswered && showExplanation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("Explanation")
                            .font(.headline)
                    }

                    Text(question.explanation)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
    }

    private var difficultyLevel: Int {
        switch question.difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

#Preview {
    QuestionCardView(
        question: Question(
            id: UUID(),
            stateCode: "MA",
            category: .roadSigns,
            questionText: "What does a yellow diamond-shaped sign indicate?",
            answers: [
                Answer(id: UUID(), text: "A warning about road conditions ahead"),
                Answer(id: UUID(), text: "A regulatory requirement you must follow"),
                Answer(id: UUID(), text: "Information about services nearby"),
                Answer(id: UUID(), text: "A route marker")
            ],
            correctAnswerIndex: 0,
            explanation: "Yellow diamond-shaped signs are warning signs that alert drivers to potential hazards or changes in road conditions ahead.",
            imageAssetName: nil,
            difficulty: .easy
        ),
        questionNumber: 1,
        totalQuestions: 25,
        selectedAnswerIndex: 0,
        hasAnswered: true,
        showExplanation: true,
        onSelectAnswer: { _ in }
    )
}
