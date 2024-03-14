import SwiftUI

class IntroController: ObservableObject {
    @Published var currentStep: Step = StorageUtils.getIsIntroFinished() ? .off : .zero
    @Published var currentStepIndex = 0
    
    enum Step: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case off = 4
        
        var title: String {
            switch self {
            case .zero:
                return "Freedom Tool"
            case .one:
                return "Step1"
            case .two:
                return "Step2"
            case .three:
                return "Step3"
            case .off:
                return "Undefined"
            }
        }
        
        var description: String {
            switch self {
            case .zero:
                return "IntroZeroDescription"
            case .one:
                return "IntroOneDescription"
            case .two:
                return "IntroTwoDescription"
            case .three:
                return "IntroThreeDescription"
            case .off:
                return "Undefined"
            }
        }
        
        var imageName: String {
            switch self {
            case .zero:
                return "IntroPeople"
            case .one:
                return "Passport"
            case .two:
                return "IntroAnon"
            case .three:
                return "IntroDoc"
            case .off:
                return "Undefined"
            }
        }
        
        var imageResolution: (width: CGFloat, height: CGFloat) {
            switch self {
            case .zero:
                return (width: 400, height: 400)
            case .one:
                return (width: 150, height: 200)
            case .two:
                return (width: 200, height: 200)
            case .three:
                return (width: 150, height: 200)
            case .off:
                return (width: 0, height: 0)
            }
        }
        
        var subDescription: String {
            switch self {
            case .zero:
                return ""
            case .one:
                return "IntroOneSubDescription"
            case .two:
                return "IntroTwoSubDescription"
            case .three:
                return "IntroThreeSubDescription"
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
        currentStepIndex = nextRawValue
    }
    
    func setStep(_ step: Step) {
        currentStep = step
    }
    
    func finish() {
        currentStep = .off
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
