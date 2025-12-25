import SwiftUI

struct AnswerButtonView: View {
    let answer: Answer
    let index: Int
    let isSelected: Bool
    let hasAnswered: Bool
    let isCorrect: Bool
    let action: () -> Void

    private var buttonColor: Color {
        if !hasAnswered {
            return isSelected ? .blue : .gray.opacity(0.2)
        }

        if isCorrect {
            return .green
        } else if isSelected {
            return .red
        } else {
            return .gray.opacity(0.2)
        }
    }

    private var textColor: Color {
        if !hasAnswered {
            return isSelected ? .white : .primary
        }

        if isCorrect || isSelected {
            return .white
        } else {
            return .secondary
        }
    }

    private var icon: String? {
        guard hasAnswered else { return nil }

        if isCorrect {
            return "checkmark.circle.fill"
        } else if isSelected {
            return "xmark.circle.fill"
        }
        return nil
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Answer letter (A, B, C, D)
                Text(answerLetter)
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())

                // Answer text
                Text(answer.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Status icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
            }
            .foregroundStyle(textColor)
            .padding()
            .background(buttonColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected && !hasAnswered ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .disabled(hasAnswered)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: hasAnswered)
    }

    private var answerLetter: String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return letters[min(index, letters.count - 1)]
    }
}

#Preview {
    VStack(spacing: 16) {
        // Not answered, not selected
        AnswerButtonView(
            answer: Answer(id: UUID(), text: "Stop completely"),
            index: 0,
            isSelected: false,
            hasAnswered: false,
            isCorrect: false,
            action: {}
        )

        // Not answered, selected
        AnswerButtonView(
            answer: Answer(id: UUID(), text: "Slow down and proceed with caution"),
            index: 1,
            isSelected: true,
            hasAnswered: false,
            isCorrect: false,
            action: {}
        )

        // Answered, correct
        AnswerButtonView(
            answer: Answer(id: UUID(), text: "Yield to oncoming traffic"),
            index: 2,
            isSelected: true,
            hasAnswered: true,
            isCorrect: true,
            action: {}
        )

        // Answered, incorrect (selected)
        AnswerButtonView(
            answer: Answer(id: UUID(), text: "Speed up to clear the intersection"),
            index: 3,
            isSelected: true,
            hasAnswered: true,
            isCorrect: false,
            action: {}
        )
    }
    .padding()
}
