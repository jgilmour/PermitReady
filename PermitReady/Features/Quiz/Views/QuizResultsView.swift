import SwiftUI

struct QuizResultsView: View {
    let quizAttempt: QuizAttempt
    let stateInfo: StateInfo
    let onRetakeQuiz: () -> Void
    let onReviewMissed: () -> Void
    let onFinish: () -> Void

    @State private var showShareSheet = false
    @State private var showCelebration = false

    private var passed: Bool {
        quizAttempt.passed(for: stateInfo)
    }

    private var scoreColor: Color {
        passed ? .green : .red
    }

    private var isTestMode: Bool {
        quizAttempt.mode == "test mode"
    }

    private var resultMessage: String {
        if passed {
            if isTestMode {
                return "Congratulations! You've passed the practice test. You're ready for the real permit test!"
            } else {
                return "Great job! You're ready for the real test."
            }
        } else {
            if isTestMode {
                return "Keep studying and try again when you're ready."
            } else {
                return "Don't worry, practice makes perfect!"
            }
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                // Result header - more compact
                VStack(spacing: 12) {
                    Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(scoreColor)

                    Text(passed ? "You Passed!" : (isTestMode ? "Not Quite" : "Keep Practicing"))
                        .font(.title)
                        .fontWeight(.bold)

                    Text(resultMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Score card - more compact
                VStack(spacing: 20) {
                    // Score percentage
                    VStack(spacing: 6) {
                        Text("\(Int(quizAttempt.score))%")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(scoreColor)

                        Text("Your Score")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Score breakdown
                    HStack(spacing: 40) {
                        ScoreStatView(
                            icon: "checkmark.circle.fill",
                            value: "\(quizAttempt.correctAnswers)",
                            label: "Correct",
                            color: .green
                        )

                        ScoreStatView(
                            icon: "xmark.circle.fill",
                            value: "\(quizAttempt.totalQuestions - quizAttempt.correctAnswers)",
                            label: "Incorrect",
                            color: .red
                        )

                        ScoreStatView(
                            icon: "clock.fill",
                            value: formatTime(quizAttempt.timeSpentSeconds),
                            label: "Time",
                            color: .blue
                        )
                    }

                    Divider()

                    // State requirements comparison
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(stateInfo.name) Requirements")
                            .font(.headline)

                        HStack {
                            Text("Passing Score:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(stateInfo.passingPercentage)%")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Your Score:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(quizAttempt.score))%")
                                .fontWeight(.semibold)
                                .foregroundStyle(scoreColor)
                        }

                        HStack {
                            Text("Questions on Real Test:")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(stateInfo.testQuestionCount)")
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Incorrect questions summary
                if !quizAttempt.incorrectQuestionIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                            Text("Questions Missed")
                                .font(.headline)
                        }

                        Text("You missed \(quizAttempt.incorrectQuestionIDs.count) question\(quizAttempt.incorrectQuestionIDs.count == 1 ? "" : "s"). Keep practicing to improve!")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Action buttons
                VStack(spacing: 12) {
                    // Share button (only for passing scores)
                    if passed {
                        Button(action: {
                            HapticManager.impact()
                            showShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Your Score")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Show review missed questions button if there are any incorrect answers
                    if !quizAttempt.incorrectQuestionIDs.isEmpty {
                        Button(action: {
                            HapticManager.impact()
                            onReviewMissed()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Review Missed Questions")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Only show retake button in practice mode
                    if !isTestMode {
                        Button(action: {
                            HapticManager.impact()
                            onRetakeQuiz()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retake Quiz")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button(action: {
                        HapticManager.impact()
                        onFinish()
                    }) {
                        Text("Finish")
                            .font(.headline)
                            .foregroundStyle(isTestMode ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTestMode ? Color.blue : Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                }
                .padding()
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [shareMessage])
            }

            // Celebration overlay
            if showCelebration {
                PassCelebrationView()
                    .transition(.opacity)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showCelebration = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            if passed {
                showCelebration = true
            }
        }
    }

    private var shareMessage: String {
        let quizType: String
        if let category = quizAttempt.category {
            quizType = "\(category) practice quiz"
        } else if isTestMode {
            quizType = "permit practice test"
        } else {
            quizType = "permit practice quiz"
        }

        return "I just scored \(Int(quizAttempt.score))% on my \(stateInfo.name) \(quizType) with PermitReady! 🚗\n\nDownload PermitReady: https://apps.apple.com/app/permitready"
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct ScoreStatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        QuizResultsView(
            quizAttempt: QuizAttempt(
                stateCode: "MA",
                category: nil,
                totalQuestions: 25,
                correctAnswers: 20,
                incorrectQuestionIDs: [UUID(), UUID(), UUID(), UUID(), UUID()],
                timeSpentSeconds: 543
            ),
            stateInfo: StateInfo.preview,
            onRetakeQuiz: {},
            onReviewMissed: {},
            onFinish: {}
        )
    }
}
