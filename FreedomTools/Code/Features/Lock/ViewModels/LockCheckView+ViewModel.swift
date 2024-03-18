//
//  LockCheckView+ViewModel.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI
import LocalAuthentication

extension LockCheckView {
    class ViewModel: ObservableObject {
        let faceIDChoise = StorageUtils.getFaceIDChoice()
        
        @Published var lockStatus = LockStatus.load()
        @Published var isInvalidPasscodeAlert = false
        
        var onSuccessFaceID: () -> Void = {}
        
        func setOnSeccessFaceID(_ onSuccess: @escaping () -> Void) {
            self.onSuccessFaceID = onSuccess
        }
        
        func authByFaceID() throws {
            let context = LAContext()
            
            var error: NSError?
            let canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            if let error = error {
                throw error
            }
            
            if !canEvaluatePolicy {
                return
            }
            
            let reason = "LockReason".localized
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    self.onSuccessFaceID()
                }
            }
        }
    }
}
