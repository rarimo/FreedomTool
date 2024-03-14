import LocalAuthentication

extension LockView {
    class ViewModel: ObservableObject {
        let passcode = StorageUtils.getPasscode()
        
        var onSuccess: () -> Void = {}
        
        func setOnSeccess(_ onSuccess: @escaping () -> Void) {
            self.onSuccess = onSuccess
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
                    self.onSuccess()
                }
            }
        }
    }
}
