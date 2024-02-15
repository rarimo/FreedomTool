import Foundation

class StorageUtils {
    static let introFinishedKey = "org.freedomtool.isIntroFinished"
    
    static func setIsIntroFinished(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.introFinishedKey)
    }
    
    static func getIsIntroFinished() -> Bool {
        UserDefaults.standard.bool(forKey: Self.introFinishedKey)
    }
}
