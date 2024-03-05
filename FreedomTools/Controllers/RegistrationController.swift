//
//  RegistrationController.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import Foundation

class RegistrationController: ObservableObject {
    @Published var nfcScannerController = NFCScannerController()
    @Published var mrzScannerController = MRZScannerController()
    
    @Published var currentStep: Step = .sign
    
    @Published var isAlreadyRegistered: Bool? = nil
    
    init() {
        mrzScannerController.setOnScanned {
            self.currentStep = .nfc
        }
        
        nfcScannerController.setOnScanned {
            self.currentStep = .waiting
        }
        
        nfcScannerController.setOnError {
            self.currentStep = .mrz
        }
    }
    
    enum Step {
        case sign
        case verification
        case mrz
        case nfc
        case confirm
        case waiting
        case submitted
    }
}
