import SwiftUI
import SwiftData

struct UserProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProgressViewModel
    @State private var selectedAttempt: QuizAttempt?
    @State private var showMissedReview = false
    @State private var missedResponses: [QuestionResponse] = []
    @State private var isLoadingLegacyQuestions = false
    @State private var sheetID = UUID() // Force sheet to rebuild

    let stateInfo: StateInfo
    let questionService: QuestionServiceProtocol

    init(stateInfo: StateInfo, modelContext: ModelContext, progressService: ProgressServiceProtocol = ProgressService(), questionService: QuestionServiceProtocol = QuestionService()) {
        self.stateInfo = stateInfo
        self.questionService = questionService
        _viewModel = State(initialValue: ProgressViewModel(
            progressService: progressService,
            stateCode: stateInfo.id,
            modelContext: modelContext
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.userProgress == nil {
                    emptyStateView
                } else {
                    VStack(spacing: 24) {
                        // Overall stats
                        overallStatsSection

                        // Study streak
                        studyStreakSection

                        // Category breakdown
                        categoryBreakdownSection

                        // Recent quizzes
                        recentQuizzesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("\(stateInfo.name) Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadProgress()
            }
            .sheet(isPresented: $showMissedReview) {
                if isLoadingLegacyQuestions {
                    ProgressView("Loading questions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    MissedQuestionsReviewView(
                        responses: missedResponses,
                        stateInfo: stateInfo
                    )
                }
            }
            .id(sheetID)
        }
    }

    private func loadMissedQuestions(for attempt: QuizAttempt) {
        selectedAttempt = attempt

        // Check if this is a new attempt with responses stored
        if !attempt.responses.isEmpty && !attempt.missedResponses.isEmpty {
            // New format with actual missed responses - use stored responses
            missedResponses = attempt.missedResponses
            // Force sheet to rebuild with new data
            sheetID = UUID()
            // Delay showing sheet to ensure state is updated
            DispatchQueue.main.async {
                showMissedReview = true
            }
        } else if !attempt.incorrectQuestionIDs.isEmpty {
            // Legacy format - need to load questions and create responses
            loadLegacyMissedQuestions(for: attempt)
        } else {
            // No missed questions
            missedResponses = []
            showMissedReview = true
        }
    }

    private func loadLegacyMissedQuestions(for attempt: QuizAttempt) {
        isLoadingLegacyQuestions = true
        showMissedReview = true

        Task {
            do {
                // Load all questions for this state
                let allQuestions = try await questionService.getQuestions(for: stateInfo.id, category: nil)

                // Filter to only the missed questions
                let missedQuestions = allQuestions.filter { question in
                    attempt.incorrectQuestionIDs.contains(question.id)
                }

                // Convert to QuestionResponse format (without user's actual choice, since we don't have it)
                await MainActor.run {
                    missedResponses = missedQuestions.map { question in
                        QuestionResponse(
                            questionID: question.id,
                            questionText: question.questionText,
                            questionCategory: question.category.rawValue,
                            questionImageAssetName: question.imageAssetName,
                            questionExplanation: question.explanation,
                            answers: question.answers.map { $0.text },
                            correctAnswerIndex: question.correctAnswerIndex,
                            userAnswerIndex: nil, // We don't know what they chose in legacy attempts
                            isCorrect: false
                        )
                    }
                    isLoadingLegacyQuestions = false
                }
            } catch {
                await MainActor.run {
                    missedResponses = []
                    isLoadingLegacyQuestions = false
                }
            }
        }
    }

    private func hasMissedQuestions(_ attempt: QuizAttempt) -> Bool {
        // Check new format first, then fall back to legacy format
        !attempt.missedResponses.isEmpty || !attempt.incorrectQuestionIDs.isEmpty
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading progress...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Failed to load progress")
                .font(.title2)
                .fontWeight(.bold)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("No Progress Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Complete your first quiz to start tracking your progress!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var overallStatsSection: some View {
        VStack(spacing: 16) {
            Text("Overall Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatCard(
                    title: "Mastery",
                    value: String(format: "%.0f%%", viewModel.overallMasteryPercentage),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                StatCard(
                    title: "Quizzes",
                    value: "\(viewModel.userProgress?.totalQuizzesTaken ?? 0)",
                    icon: "list.clipboard.fill",
                    color: .green
                )

                StatCard(
                    title: "Best Score",
                    value: String(format: "%.0f%%", viewModel.userProgress?.bestScore ?? 0),
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }

    private var studyStreakSection: some View {
        VStack(spacing: 12) {
            Text("Study Streak")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                VStack {
                    Text("\(viewModel.userProgress?.currentStreak ?? 0)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.orange)

                    Text("Current Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Text("\(viewModel.userProgress?.longestStreak ?? 0)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.purple)

                    Text("Longest Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var categoryBreakdownSection: some View {
        VStack(spacing: 12) {
            Text("Category Mastery")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.categoryBreakdown.isEmpty {
                Text("Complete category quizzes to see category breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.categoryBreakdown, id: \.category) { item in
                        CategoryMasteryRow(
                            category: item.category,
                            mastery: item.mastery
                        )
                    }
                }
            }
        }
    }

    private var recentQuizzesSection: some View {
        VStack(spacing: 12) {
            Text("Recent Quizzes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.recentQuizzes.isEmpty {
                Text("No quizzes completed yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentQuizzes) { attempt in
                        Button(action: {
                            loadMissedQuestions(for: attempt)
                        }) {
                            QuizHistoryRow(attempt: attempt)
                        }
                        .buttonStyle(.plain)
                        .disabled(!hasMissedQuestions(attempt))
                        .opacity(hasMissedQuestions(attempt) ? 1.0 : 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryMasteryRow: View {
    let category: Question.QuestionCategory
    let mastery: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(String(format: "%.0f%%", mastery))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(masteryColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(masteryColor)
                        .frame(width: geometry.size.width * (mastery / 100))
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var masteryColor: Color {
        if mastery >= 80 {
            return .green
        } else if mastery >= 60 {
            return .yellow
        } else {
            return .orange
        }
    }
}

struct QuizHistoryRow: View {
    let attempt: QuizAttempt

    var scorePercentage: Double {
        Double(attempt.correctAnswers) / Double(attempt.totalQuestions) * 100
    }

    var passed: Bool {
        scorePercentage >= 80
    }

    var hasMissedQuestions: Bool {
        // Check both new and legacy formats
        !attempt.missedResponses.isEmpty || !attempt.incorrectQuestionIDs.isEmpty
    }

    var missedQuestionsCount: Int {
        // Prefer new format count, fall back to legacy
        if !attempt.missedResponses.isEmpty {
            return attempt.missedResponses.count
        } else {
            return attempt.incorrectQuestionIDs.count
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let category = attempt.category {
                        Text(Question.QuestionCategory(rawValue: category)?.displayName ?? "General")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else if attempt.mode == "test mode" {
                        Text("Practice Test")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Text("Practice Quiz")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    if passed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                HStack(spacing: 4) {
                    Text(attempt.completedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if hasMissedQuestions {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Tap to review")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f%%", scorePercentage))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(passed ? .green : .orange)

                if hasMissedQuestions {
                    Text("\(missedQuestionsCount) missed")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("\(attempt.correctAnswers)/\(attempt.totalQuestions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(hasMissedQuestions ? Color.red.opacity(0.05) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    UserProgressView(
        stateInfo: StateInfo.preview,
        modelContext: ModelContext(
            try! ModelContainer(for: QuizAttempt.self, UserProgress.self)
        )
    )
}
