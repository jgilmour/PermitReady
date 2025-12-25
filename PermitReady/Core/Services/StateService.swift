import Foundation

actor StateService {
    private var stateCache: [String: StateInfo] = [:]
    private var allStatesCache: [StateInfo]?
    
    private let stateFileNames: [String: String] = [
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
    
    func loadStateInfo(for stateCode: String, questionService: QuestionService) async throws -> StateInfo {
        // Return cached if available
        if let cached = stateCache[stateCode] {
            return cached
        }
        
        guard let fileName = stateFileNames[stateCode.uppercased()] else {
            throw StateServiceError.stateNotFound(stateCode)
        }
        
        guard let fileUrl = Bundle.main.url(
            forResource: fileName,
            withExtension: "json",
            subdirectory: "QuestionBanks"
        ) ?? Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw StateServiceError.fileNotFound(stateCode)
        }
        
        let data = try Data(contentsOf: fileUrl)
        let decoder = JSONDecoder()
        
        do {
            let questionBank = try decoder.decode(QuestionBank.self, from: data)
            let stateInfo = StateInfo(from: questionBank)
            
            stateCache[stateCode] = stateInfo
            return stateInfo
        } catch {
            print("Failed to decode state info for \(stateCode): \(error)")
            throw StateServiceError.invalidJSON(stateCode)
        }
    }
    
    func loadAllStates(questionService: QuestionService) async throws -> [StateInfo] {
        if let cached = allStatesCache {
            return cached
        }
        
        var states: [StateInfo] = []
        
        for stateCode in stateFileNames.keys {
            do {
                let stateInfo = try await loadStateInfo(for: stateCode, questionService: questionService)
                states.append(stateInfo)
            } catch {
                print("Warning: Failed to load state \(stateCode): \(error)")
            }
        }
        
        // Sort by name
        states.sort { $0.name < $1.name }
        
        allStatesCache = states
        return states
    }
    
    func clearCache() {
        stateCache.removeAll()
        allStatesCache = nil
    }
}

enum StateServiceError: LocalizedError {
    case stateNotFound(String)
    case fileNotFound(String)
    case invalidJSON(String)
    
    var errorDescription: String? {
        switch self {
        case .stateNotFound(let state):
            return "State not found: \(state)"
        case .fileNotFound(let state):
            return "State file not found: \(state)"
        case .invalidJSON(let state):
            return "Invalid JSON for state: \(state)"
        }
    }
}



