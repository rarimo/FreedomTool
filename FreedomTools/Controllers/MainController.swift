import SwiftUI

class MainController: ObservableObject {    
    let polls = Poll.sampleData
    
    func getPoll(_ id: UUID) -> Poll? {
        return polls.first { $0.id == id }
    }
}
