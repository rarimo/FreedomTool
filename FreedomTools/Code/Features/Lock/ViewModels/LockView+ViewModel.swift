import LocalAuthentication

extension LockView {
    class ViewModel: ObservableObject {
        let passcode = StorageUtils.getPasscode()
    }
}
