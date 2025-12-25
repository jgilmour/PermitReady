import Foundation

enum QuizMode {
    case practice
    case test

    var showExplanationsDuringQuiz: Bool {
        switch self {
        case .practice: return true
        case .test: return false
        }
    }

    var allowRetakes: Bool {
        switch self {
        case .practice: return true
        case .test: return false
        }
    }

    var isTimed: Bool {
        switch self {
        case .practice: return false
        case .test: return true
        }
    }

    var timeLimit: TimeInterval {
        switch self {
        case .practice: return 0
        case .test: return 1800 // 30 minutes (MA requirement)
        }
    }

    var displayName: String {
        switch self {
        case .practice: return "Practice Mode"
        case .test: return "Test Mode"
        }
    }
}
