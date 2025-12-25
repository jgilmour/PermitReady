import Foundation

struct StateInfo: Codable, Identifiable, Hashable {
    let id: String                  // State code: "MA", "CA"
    let name: String
    let minimumPermitAge: Double
    let testQuestionCount: Int
    let passingPercentage: Int
    let hasSplitTest: Bool
    let splitTestInfo: SplitTestInfo?
    let uniqueRequirements: [String]
    let timeLimitMinutes: Int?      // Time limit in minutes, nil if no limit
    
    var passingScore: Int {
        Int(ceil(Double(testQuestionCount) * Double(passingPercentage) / 100.0))
    }
    
    // Initializer from QuestionBank
    init(from questionBank: QuestionBank) {
        self.id = questionBank.stateCode
        self.name = questionBank.stateName
        self.minimumPermitAge = questionBank.testInfo.minimumPermitAge
        self.testQuestionCount = questionBank.testInfo.questionCount
        self.passingPercentage = questionBank.testInfo.passingPercentage
        self.hasSplitTest = questionBank.testInfo.hasSplitTest
        // The splitTestInfo from TestInfo is already the correct type (SplitTestInfo from State.swift)
        self.splitTestInfo = questionBank.testInfo.splitTestInfo
        self.uniqueRequirements = questionBank.testInfo.uniqueRequirements
        self.timeLimitMinutes = questionBank.testInfo.timeLimit
    }
    
    // Keep the old initializer for Codable conformance
    init(
        id: String,
        name: String,
        minimumPermitAge: Double,
        testQuestionCount: Int,
        passingPercentage: Int,
        hasSplitTest: Bool,
        splitTestInfo: SplitTestInfo?,
        uniqueRequirements: [String],
        timeLimitMinutes: Int?
    ) {
        self.id = id
        self.name = name
        self.minimumPermitAge = minimumPermitAge
        self.testQuestionCount = testQuestionCount
        self.passingPercentage = passingPercentage
        self.hasSplitTest = hasSplitTest
        self.splitTestInfo = splitTestInfo
        self.uniqueRequirements = uniqueRequirements
        self.timeLimitMinutes = timeLimitMinutes
    }
    
    // Preview helper for SwiftUI previews
    static var preview: StateInfo {
        StateInfo(
            id: "MA",
            name: "Massachusetts",
            minimumPermitAge: 16.0,
            testQuestionCount: 25,
            passingPercentage: 72,
            hasSplitTest: false,
            splitTestInfo: nil,
            uniqueRequirements: ["Must be accompanied by licensed driver 21+ for first 6 months"],
            timeLimitMinutes: 25
        )
    }
}

struct SplitTestInfo: Codable, Hashable {
    let sections: [TestSection]
    
    // Regular initializer
    init(sections: [TestSection]) {
        self.sections = sections
    }
}

struct TestSection: Codable, Hashable {
    let name: String                // "Road Signs", "Traffic Rules"
    let questionCount: Int
    let passingPercentage: Int

    var passingScore: Int {
        Int(ceil(Double(questionCount) * Double(passingPercentage) / 100.0))
    }
}
