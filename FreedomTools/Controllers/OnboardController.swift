import SwiftUI

class OnboardController: ObservableObject {
    @Published var currentStep: Step = .zero
    
    @Published var mrzScannerController = MRZScannerController()
    @Published var nfcScannerController = NFCScannerController()
    
    init() {
        mrzScannerController.setOnScanned {
            self.nextStep()
        }
        
        nfcScannerController.setOnScanned {
            self.nextStep()
        }
        
        nfcScannerController.setOnError {
            self.cancel()
        }
    }
    
    enum Step: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case off = 4
        
        var title: String {
            switch self {
            case .zero:
                return "Participate"
            case .one:
                return "ScanDoc"
            case .two:
                return "ScanNFC"
            case .three:
                return "AnonData"
            case .off:
                return "Undefined"
            }
        }
        
        var description: String {
            switch self {
            case .zero:
                return "ParticipateSub"
            case .one:
                return "ScanDocSub"
            case .two:
                return "ScanNFCSub"
            case .three:
                return "AnonDataSub"
            case .off:
                return "Undefined"
            }
        }
    }
    
    func nextStep() {
        var nextRawValue = currentStep.rawValue + 1
        if nextRawValue > Step.off.rawValue {
            nextRawValue = 0
        }
        
        currentStep = Step(rawValue: nextRawValue)!
    }
    
    func cancel() {
        currentStep = .zero
    }
    
    var isZero: Bool {
        return currentStep == .zero
    }
    
    var isOne: Bool {
        return currentStep == .one
    }
    
    var isTwo: Bool {
        return currentStep == .two
    }
    
    var isThree: Bool {
        return currentStep == .three
    }
    
    var isOff: Bool {
        return currentStep == .off
    }
}
