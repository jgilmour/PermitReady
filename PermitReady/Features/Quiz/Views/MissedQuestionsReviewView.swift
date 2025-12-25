import SwiftUI

struct MissedQuestionsReviewView: View {
    @Environment(\.dismiss) private var dismiss
    let responses: [QuestionResponse]
    let stateInfo: StateInfo

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    contentView
                }
                .padding()
            }
            .navigationTitle(stateInfo.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Review Missed Questions")
                .font(.title2)
                .fontWeight(.bold)

            Text("Study these \(responses.count) question\(responses.count == 1 ? "" : "s") you got wrong")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    @ViewBuilder
    private var contentView: some View {
        if responses.isEmpty {
            emptyStateView
        } else {
            questionsListView
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("No Questions to Review")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Perfect score! You didn't miss any questions.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var questionsListView: some View {
        ForEach(Array(responses.enumerated()), id: \.element.questionID) { index, response in
            MissedQuestionCard(
                response: response,
                number: index + 1
            )
        }
    }
}

struct MissedQuestionCard: View {
    let response: QuestionResponse
    let number: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            questionHeader
            questionText
            questionImage
            answerOptions
            explanation
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var questionHeader: some View {
        HStack {
            Text("Question \(number)")
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            categoryBadge
        }
    }

    @ViewBuilder
    private var categoryBadge: some View {
        if let category = Question.QuestionCategory(rawValue: response.questionCategory) {
            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        }
    }

    private var questionText: some View {
        Text(response.questionText)
            .font(.body)
            .fontWeight(.semibold)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var questionImage: some View {
        if let imageAssetName = response.questionImageAssetName,
           UIImage(named: imageAssetName) != nil {
            Image(imageAssetName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var answerOptions: some View {
        VStack(spacing: 8) {
            ForEach(Array(response.answers.enumerated()), id: \.offset) { index, answerText in
                AnswerRow(
                    answerText: answerText,
                    index: index,
                    response: response
                )
            }
        }
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Explanation")
                    .font(.headline)
            }

            Text(response.questionExplanation)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AnswerRow: View {
    let answerText: String
    let index: Int
    let response: QuestionResponse

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            answerIcon

            Text(answerText)
                .font(.subheadline)
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }

    @ViewBuilder
    private var answerIcon: some View {
        if index == response.userAnswerIndex {
            Image(systemName: response.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(response.isCorrect ? .green : .red)
                .font(.title3)
        } else if index == response.correctAnswerIndex {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
        } else {
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }

    private var textColor: Color {
        index == response.correctAnswerIndex ? .primary : .secondary
    }

    private var backgroundColor: Color {
        if index == response.correctAnswerIndex {
            return Color.green.opacity(0.1)
        } else if index == response.userAnswerIndex {
            return Color.red.opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private var borderColor: Color {
        if index == response.correctAnswerIndex {
            return .green
        } else if index == response.userAnswerIndex {
            return .red
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private var borderWidth: CGFloat {
        (index == response.correctAnswerIndex || index == response.userAnswerIndex) ? 2 : 1
    }
}

#Preview {
    let sampleResponse = QuestionResponse(
        questionID: UUID(),
        questionText: "What does a red octagonal sign mean?",
        questionCategory: "roadSigns",
        questionImageAssetName: nil,
        questionExplanation: "A red octagonal (8-sided) sign always means STOP. You must come to a complete stop at the stop line, crosswalk, or before entering the intersection.",
        answers: [
            "Stop completely before proceeding",
            "Slow down and proceed with caution",
            "Yield to oncoming traffic",
            "Road work ahead"
        ],
        correctAnswerIndex: 0,
        userAnswerIndex: 2,
        isCorrect: false
    )

    return MissedQuestionsReviewView(
        responses: [sampleResponse],
        stateInfo: StateInfo.preview
    )
}
