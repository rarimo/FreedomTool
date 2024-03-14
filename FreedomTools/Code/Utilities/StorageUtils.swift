import Foundation

class StorageUtils {
    static let introFinishedKey = "org.freedomtool.isIntroFinished"
    static let passcodeKey = "org.freedomtool.passcodeKey"
    
    static func setIsIntroFinished(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.introFinishedKey)
    }
    
    static func getIsIntroFinished() -> Bool {
        UserDefaults.standard.bool(forKey: Self.introFinishedKey)
    }
    
    static func setPasscode(_ value: String) {
        UserDefaults.standard.set(value, forKey: Self.passcodeKey)
    }
    
    static func getPasscode() -> String? {
        UserDefaults.standard.string(forKey: Self.passcodeKey)
    }
}
