import Foundation
import NFCPassportReader

struct Poll: Identifiable {
    let id = UUID()
    
    let title: String
    let desc: String
    let status: Status
    
    enum Status {
        case pending(till: Date, criterias: [String])
        case voting(till: Date, candidates: [String])
        case ended(at: Date, winners: [(candidat: String, persent: Int)])
    }
    
    var isPending: Bool {
        if case .pending(_, _) = status {
            return true
        }
        
        return false
    }
    
    var isVoting: Bool {
        if case .voting(_, _) = status {
            return true
        }
        
        return false
    }
    
    var isEnded: Bool {
        if case .ended(_, _) = status {
            return true
        }
        
        return false
    }
    
    static let sampleData: [Self] = [
        Self(
            title: "Poll1",
            desc: "Poll1Desc",
            status: .pending(
                till: Date(timeIntervalSinceNow: 36000),
                criterias: []
            )
        ),
    ]
}
