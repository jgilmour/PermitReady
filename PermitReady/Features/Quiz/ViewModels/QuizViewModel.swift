import Foundation
import SwiftData
import UIKit

@Observable
class QuizViewModel {
    // MARK: - Properties
    private let questionService: QuestionServiceProtocol
    private let stateCode: String
    private let category: Question.QuestionCategory?
    private let questionCount: Int
    private let mode: QuizMode
    private let missedQuestionIDs: [UUID]?
    private let initialTimeLimit: TimeInterval  // Add this property
    private var timer: Timer?

    private(set) var questions: [Question] = []
    private(set) var currentQuestionIndex: Int = 0
    private(set) var selectedAnswerIndex: Int?
    private(set) var hasAnswered: Bool = false
    private(set) var correctAnswers: Int = 0
    private(set) var incorrectQuestionIDs: [UUID] = []
    private(set) var responses: [QuestionResponse] = []  // NEW: Track all responses
    private(set) var startTime: Date?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var isComplete: Bool = false
    private(set) var showConfetti: Bool = false
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var isTimedOut: Bool = false

    // MARK: - Computed Properties
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var timeElapsed: Int {
        guard let startTime = startTime else { return 0 }
        return Int(Date().timeIntervalSince(startTime))
    }

    var scorePercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(correctAnswers) / Double(questions.count) * 100
    }

    var isAnswerCorrect: Bool {
        guard let selectedIndex = selectedAnswerIndex,
              let question = currentQuestion else {
            return false
        }
        return question.isCorrectAnswer(selectedIndex)
    }

    var quizMode: QuizMode {
        mode
    }

    // MARK: - Initialization
    init(
        questionService: QuestionServiceProtocol,
        stateCode: String,
        category: Question.QuestionCategory? = nil,
        questionCount: Int = 25,
        mode: QuizMode = .practice,
        missedQuestionIDs: [UUID]? = nil,
        timeLimit: TimeInterval? = nil
    ) {
        self.questionService = questionService
        self.stateCode = stateCode
        self.category = category
        self.questionCount = questionCount
        self.mode = mode
        self.missedQuestionIDs = missedQuestionIDs
        
        // Use provided time limit, or fall back to mode's default (30 minutes for test, 0 for practice)
        self.initialTimeLimit = timeLimit ?? mode.timeLimit
        self.timeRemaining = initialTimeLimit
    }

    // MARK: - Methods
    @MainActor
    func loadQuestions() async {
        isLoading = true
        error = nil

        do {
            // If we have specific question IDs (missed questions mode), load only those
            if let missedIDs = missedQuestionIDs, !missedIDs.isEmpty {
                let allQuestions = try await questionService.getQuestions(
                    for: stateCode,
                    category: category
                )
                // Filter to only the missed questions and shuffle them
                questions = allQuestions
                    .filter { missedIDs.contains($0.id) }
                    .shuffled()
                    .prefix(min(questionCount, missedIDs.count))
                    .map { $0 }
            } else {
                // Normal random questions
                questions = try await questionService.getRandomQuestions(
                    for: stateCode,
                    count: questionCount,
                    category: category
                )
            }

            startTime = Date()
            isLoading = false

            // Start timer for test mode
            if mode.isTimed {
                startTimer()
            }
        } catch {
            self.error = error
            isLoading = false
        }
    }

    @MainActor
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateTimer()
            }
        }
    }

    @MainActor
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timer?.invalidate()
            timer = nil
            isTimedOut = true
            isComplete = true
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func selectAnswer(_ index: Int) {
        guard !hasAnswered else { return }
        selectedAnswerIndex = index
    }

    func submitAnswer() {
        guard !hasAnswered,
              let selectedIndex = selectedAnswerIndex,
              let question = currentQuestion else {
            return
        }

        hasAnswered = true

        // Create response record
        let response = QuestionResponse(from: question, userAnswerIndex: selectedIndex)
        responses.append(response)

        if question.isCorrectAnswer(selectedIndex) {
            correctAnswers += 1
            // Only show confetti in practice mode
            if mode == .practice {
                showConfetti = true
            }
            // Success haptic
            Task { @MainActor in
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        } else {
            incorrectQuestionIDs.append(question.id)
            // Error haptic
            Task { @MainActor in
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }

    func nextQuestion() {
        guard hasAnswered else { return }

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            hasAnswered = false
            showConfetti = false
        } else {
            stopTimer()
            isComplete = true
        }
    }

    func reset() {
        stopTimer()
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        hasAnswered = false
        correctAnswers = 0
        incorrectQuestionIDs = []
        responses = []  // NEW: Clear responses
        startTime = nil
        isComplete = false
        questions = []
        showConfetti = false
        timeRemaining = initialTimeLimit
        isTimedOut = false
    }

    func createQuizAttempt() -> QuizAttempt {
        QuizAttempt(
            stateCode: stateCode,
            category: category?.rawValue,
            mode: mode.displayName.lowercased(),
            totalQuestions: questions.count,
            correctAnswers: correctAnswers,
            incorrectQuestionIDs: incorrectQuestionIDs,
            responses: responses,  // NEW: Include responses
            completedAt: Date(),
            timeSpentSeconds: timeElapsed
        )
    }
}
