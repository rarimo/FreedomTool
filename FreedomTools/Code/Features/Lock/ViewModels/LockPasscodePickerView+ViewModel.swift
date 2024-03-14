import SwiftUI

extension LockPasscodePickerView {
    class ViewModel: ObservableObject {
        static let MAX_PASSPORT_LENGTH = 4
        
        @Published var isFull = false
        @Published var passcode: [Int] = []
        
        var onFull: ([Int]) -> Void = { _ in}
        
        func setOnFull(_ onFull: @escaping ([Int]) -> Void) {
            self.onFull = onFull
        }
        
        func push(_ number: Int) {
            if self.isFull {
                return
            }
            
            self.passcode.append(number)
            
            if self.passcode.count >= Self.MAX_PASSPORT_LENGTH {
                self.isFull = true
                self.onFull(self.passcode)
            }
        }
        
        func removeLast() {
            if !self.passcode.isEmpty {
                self.passcode.removeLast()
            }
        }
    }
}
