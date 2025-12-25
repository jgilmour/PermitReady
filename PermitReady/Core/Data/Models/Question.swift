import Foundation

struct Question: Codable, Identifiable, Hashable {
    let id: UUID
    let stateCode: String           // "MA", "CA", "TX", etc.
    let category: QuestionCategory
    let questionText: String
    let answers: [Answer]
    let correctAnswerIndex: Int
    let explanation: String
    let imageAssetName: String?     // For road sign questions
    let difficulty: Difficulty

    enum QuestionCategory: String, Codable, CaseIterable {
        case roadSigns
        case rightOfWay
        case speedLimits
        case parking
        case safeDriving
        case alcoholDrugs
        case emergencies
        case stateSpecific
        case trafficLaws
        case finesAndLimits

        var displayName: String {
            switch self {
            case .roadSigns: return "Road Signs"
            case .rightOfWay: return "Right of Way"
            case .speedLimits: return "Speed Limits"
            case .parking: return "Parking"
            case .safeDriving: return "Safe Driving"
            case .alcoholDrugs: return "Alcohol & Drugs"
            case .emergencies: return "Emergencies"
            case .stateSpecific: return "State Specific"
            case .trafficLaws: return "Traffic Laws"
            case .finesAndLimits: return "Fines & Limits"
            }
        }
    }

    enum Difficulty: String, Codable {
        case easy, medium, hard
    }

    var isCorrectAnswer: (Int) -> Bool {
        { answerIndex in
            answerIndex == correctAnswerIndex
        }
    }

    // Memberwise initializer for creating questions programmatically
    init(
        id: UUID,
        stateCode: String,
        category: QuestionCategory,
        questionText: String,
        answers: [Answer],
        correctAnswerIndex: Int,
        explanation: String,
        imageAssetName: String?,
        difficulty: Difficulty
    ) {
        self.id = id
        self.stateCode = stateCode
        self.category = category
        self.questionText = questionText
        self.answers = answers
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.imageAssetName = imageAssetName
        self.difficulty = difficulty
    }

    // Custom coding to handle string IDs from JSON
    enum CodingKeys: String, CodingKey {
        case id, stateCode, category, questionText, answers
        case correctAnswerIndex, explanation, imageAssetName, difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle string ID by creating a deterministic UUID from it
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", abs(idString.hashValue % 1000000000000)))") ?? UUID()

        // stateCode is optional in JSON (will be set by QuestionService)
        self.stateCode = try container.decodeIfPresent(String.self, forKey: .stateCode) ?? ""
        self.category = try container.decode(QuestionCategory.self, forKey: .category)
        self.questionText = try container.decode(String.self, forKey: .questionText)
        self.answers = try container.decode([Answer].self, forKey: .answers)
        self.correctAnswerIndex = try container.decode(Int.self, forKey: .correctAnswerIndex)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.imageAssetName = try container.decodeIfPresent(String.self, forKey: .imageAssetName)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
    }

    // Helper to create a copy with a different state code
    func withStateCode(_ code: String) -> Question {
        Question(
            id: id,
            stateCode: code,
            category: category,
            questionText: questionText,
            answers: answers,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            imageAssetName: imageAssetName,
            difficulty: difficulty
        )
    }

    // Shuffle answers to randomize correct answer position
    func withShuffledAnswers() -> Question {
        // Create array of (index, answer) pairs
        let indexedAnswers = answers.enumerated().map { ($0.offset, $0.element) }

        // Shuffle the pairs
        let shuffledPairs = indexedAnswers.shuffled()

        // Find new position of the correct answer
        guard let newCorrectIndex = shuffledPairs.firstIndex(where: { $0.0 == correctAnswerIndex }) else {
            // Fallback if something goes wrong
            return self
        }

        // Extract just the shuffled answers
        let shuffledAnswers = shuffledPairs.map { $0.1 }

        return Question(
            id: id,
            stateCode: stateCode,
            category: category,
            questionText: questionText,
            answers: shuffledAnswers,
            correctAnswerIndex: newCorrectIndex,
            explanation: explanation,
            imageAssetName: imageAssetName,
            difficulty: difficulty
        )
    }
}

struct Answer: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String

    enum CodingKeys: String, CodingKey {
        case id, text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle string ID by creating a deterministic UUID from it
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", abs(idString.hashValue % 1000000000000)))") ?? UUID()

        self.text = try container.decode(String.self, forKey: .text)
    }

    init(id: UUID, text: String) {
        self.id = id
        self.text = text
    }
}
