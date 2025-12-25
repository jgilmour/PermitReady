import Foundation

protocol QuestionServiceProtocol: Sendable {
    func loadQuestions(for stateCode: String) async throws -> [Question]
    func getQuestions(for stateCode: String, category: Question.QuestionCategory?) async throws -> [Question]
    func getRandomQuestions(for stateCode: String, count: Int, category: Question.QuestionCategory?) async throws -> [Question]
    func getAvailableCategories(for stateCode: String) async throws -> [Question.QuestionCategory]
}

enum QuestionServiceError: LocalizedError {
    case fileNotFound(String)
    case invalidJSON(String)
    case noQuestionsAvailable

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let state):
            return "Question bank not found for state: \(state)"
        case .invalidJSON(let state):
            return "Invalid question data for state: \(state)"
        case .noQuestionsAvailable:
            return "No questions available for the selected criteria"
        }
    }
}

struct QuestionBank: Codable {
    let stateCode: String
    let stateName: String
    let version: String
    let lastUpdated: String
    let testInfo: TestInfo
    let questions: [Question]
}

struct TestInfo: Codable {
    let questionCount: Int
    let passingPercentage: Int
    let passingScore: Int?
    let minimumPermitAge: Double
    let hasSplitTest: Bool
    let timeLimit: Int?  // In minutes, null if no limit
    let uniqueRequirements: [String]
    let splitTestInfo: SplitTestInfo?  // Uses SplitTestInfo from State.swift
}

actor QuestionService: QuestionServiceProtocol {
    private var questionCache: [String: [Question]] = [:]
    private var questionBankCache: [String: QuestionBank] = [:]

    func loadQuestionBank(for stateCode: String) async throws -> QuestionBank {
        // Return cached if available
        if let cached = questionBankCache[stateCode] {
            return cached
        }

        // Map state codes to file names
        let stateFileNames: [String: String] = [
            "MA": "massachusetts",
            "CA": "california",
            "TX": "texas",
            "FL": "florida",
            "NY": "newyork",
            "PA": "pennsylvania",
            "IL": "illinois",
            "OH": "ohio",
            "NC": "northcarolina",
            "MI": "michigan",
            "GA": "georgia",
            "NJ": "newjersey",
            "VA": "virginia"
        ]

        guard let fileName = stateFileNames[stateCode.uppercased()] else {
            throw QuestionServiceError.fileNotFound(stateCode)
        }

        // Try loading from different locations
        var url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "QuestionBanks")

        if url == nil {
            // Try without subdirectory
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }

        guard let fileUrl = url else {
            print("ERROR: Could not find \(fileName).json in bundle")
            throw QuestionServiceError.fileNotFound(stateCode)
        }

        let data = try Data(contentsOf: fileUrl)
        let decoder = JSONDecoder()

        do {
            let questionBank = try decoder.decode(QuestionBank.self, from: data)
            questionBankCache[stateCode] = questionBank
            return questionBank
        } catch {
            print("JSON decode error: \(error)")
            throw QuestionServiceError.invalidJSON(stateCode)
        }
    }

    func loadQuestions(for stateCode: String) async throws -> [Question] {
        // Return cached questions if available
        if let cached = questionCache[stateCode] {
            return cached
        }

        let questionBank = try await loadQuestionBank(for: stateCode)

        // Set state code on all questions
        let questionsWithStateCode = questionBank.questions.map { question in
            question.withStateCode(stateCode)
        }

        questionCache[stateCode] = questionsWithStateCode
        print("Successfully loaded \(questionsWithStateCode.count) questions for \(stateCode)")
        return questionsWithStateCode
    }

    func getQuestions(for stateCode: String, category: Question.QuestionCategory? = nil) async throws -> [Question] {
        let allQuestions = try await loadQuestions(for: stateCode)

        // Shuffle answers to randomize correct answer positions
        let shuffledQuestions = allQuestions.map { $0.withShuffledAnswers() }

        if let category = category {
            return shuffledQuestions.filter { $0.category == category }
        }

        return shuffledQuestions
    }

    func getRandomQuestions(
        for stateCode: String,
        count: Int,
        category: Question.QuestionCategory? = nil
    ) async throws -> [Question] {
        let questions = try await getQuestions(for: stateCode, category: category)

        guard !questions.isEmpty else {
            throw QuestionServiceError.noQuestionsAvailable
        }

        return Array(questions.shuffled().prefix(count))
    }

    func getAvailableCategories(for stateCode: String) async throws -> [Question.QuestionCategory] {
        let allQuestions = try await loadQuestions(for: stateCode)

        // Get unique categories from questions
        let categories = Set(allQuestions.map { $0.category })

        // Sort alphabetically by display name
        return categories.sorted { $0.displayName < $1.displayName }
    }

    func clearCache() {
        questionCache.removeAll()
        questionBankCache.removeAll()
    }
}
