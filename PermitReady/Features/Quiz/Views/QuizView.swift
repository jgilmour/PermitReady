import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: QuizViewModel
    @State private var showResults = false
    @State private var showMissedReview = false

    let stateInfo: StateInfo
    let category: Question.QuestionCategory?
    let mode: QuizMode

    init(
        stateInfo: StateInfo,
        category: Question.QuestionCategory? = nil,
        mode: QuizMode = .practice,
        questionService: QuestionServiceProtocol = QuestionService(),
        missedQuestionIDs: [UUID]? = nil
    ) {
        self.stateInfo = stateInfo
        self.category = category
        self.mode = mode
        
        // Use state-specific test question count for test mode, otherwise use 25 for practice quizzes
        let questionCount = mode == .test ? stateInfo.testQuestionCount : 25
        
        // Use state-specific time limit for test mode (convert minutes to seconds)
        // Default to 30 minutes (1800 seconds) if timeLimitMinutes is nil
        let timeLimit: TimeInterval? = mode == .test ? (stateInfo.timeLimitMinutes.map { TimeInterval($0 * 60) } ?? 1800) : nil
        
        _viewModel = State(initialValue: QuizViewModel(
            questionService: questionService,
            stateCode: stateInfo.id,
            category: category,
            questionCount: questionCount,
            mode: mode,
            missedQuestionIDs: missedQuestionIDs,
            timeLimit: timeLimit
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if showResults {
                    QuizResultsView(
                        quizAttempt: viewModel.createQuizAttempt(),
                        stateInfo: stateInfo,
                        onRetakeQuiz: retakeQuiz,
                        onReviewMissed: reviewMissedQuestions,
                        onFinish: { dismiss() }
                    )
                } else if let question = viewModel.currentQuestion {
                    VStack(spacing: 0) {
                        // Timer (Test Mode only)
                        if mode.isTimed {
                            timerHeader
                        }

                        // Progress bar
                        ProgressView(value: viewModel.progress)
                            .tint(.blue)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // Question card
                        ScrollView {
                            QuestionCardView(
                                question: question,
                                questionNumber: viewModel.currentQuestionIndex + 1,
                                totalQuestions: viewModel.questions.count,
                                selectedAnswerIndex: viewModel.selectedAnswerIndex,
                                hasAnswered: viewModel.hasAnswered,
                                showExplanation: mode.showExplanationsDuringQuiz,
                                onSelectAnswer: { index in
                                    viewModel.selectAnswer(index)
                                }
                            )
                        }

                        // Action button
                        actionButton
                            .padding()
                            .background(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
                            .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: viewModel.currentQuestionIndex)
                    }
                    .confetti(isActive: Binding(
                        get: { viewModel.showConfetti },
                        set: { _ in }
                    ))
                }
            }
            .navigationTitle(category?.displayName ?? stateInfo.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !showResults {
                        Button("Exit") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                // Reset state when view appears to ensure fresh quiz
                showResults = false
                // Preload interstitial ad for smoother experience
                InterstitialAdManager.shared.loadAd()
            }
            .task {
                await viewModel.loadQuestions()
            }
            .onChange(of: viewModel.isComplete) { _, isComplete in
                if isComplete {
                    saveQuizAttempt()

                    // Track completion for ad frequency
                    InterstitialAdManager.shared.trackCompletion()

                    // Show interstitial ad before results (if eligible)
                    InterstitialAdManager.shared.showAdIfNeeded {
                        // Show results after ad is dismissed (or skipped)
                        showResults = true
                    }
                }
            }
            .sheet(isPresented: $showMissedReview) {
                MissedQuestionsReviewView(
                    responses: viewModel.createQuizAttempt().missedResponses,
                    stateInfo: stateInfo
                )
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 24) {
            PulsingAppIcon()

            Text("Loading questions...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await viewModel.loadQuestions()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if !viewModel.hasAnswered {
            // Submit button
            Button(action: {
                HapticManager.impact()
                viewModel.submitAnswer()
            }) {
                Text("Submit Answer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedAnswerIndex != nil ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.selectedAnswerIndex == nil)
        } else {
            // Next button
            Button(action: {
                HapticManager.impact()
                viewModel.nextQuestion()
            }) {
                HStack {
                    Text(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "Next Question" : "See Results")
                        .font(.headline)

                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Methods

    private func saveQuizAttempt() {
        let attempt = viewModel.createQuizAttempt()
        modelContext.insert(attempt)

        do {
            try modelContext.save()

            // Update user progress
            let progressService = ProgressService()
            try? progressService.updateUserProgress(
                for: stateInfo.id,
                attempt: attempt,
                modelContext: modelContext
            )
        } catch {
            print("Failed to save quiz attempt: \(error)")
        }
    }

    private func retakeQuiz() {
        showResults = false
        viewModel.reset()
        Task {
            await viewModel.loadQuestions()
        }
    }

    private func reviewMissedQuestions() {
        // Simply show the review sheet - all data is in viewModel.responses
        showMissedReview = true
    }

    private var timerHeader: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundStyle(viewModel.timeRemaining < 300 ? .red : .blue)

            Text(formatTime(viewModel.timeRemaining))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.timeRemaining < 300 ? .red : .primary)
                .monospacedDigit()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    QuizView(
        stateInfo: StateInfo.preview
    )
    .modelContainer(for: [QuizAttempt.self, UserProgress.self])
}
