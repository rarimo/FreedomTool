import Foundation

class StorageUtils {
    static let introFinishedKey = "org.freedomtool.isIntroFinished"
    static let passcodeKey = "org.freedomtool.passcodeKey"
    static let faceIDChoiceKey = "org.freedomtool.faceIDChoice"
    static let isFirstLaunch = "org.freedomtool.isFirstLaunch"
    
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
    
    static func setFaceIDChoice(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.faceIDChoiceKey)
    }
    
    static func getFaceIDChoice() -> Bool {
        UserDefaults.standard.bool(forKey: Self.faceIDChoiceKey)
    }
    
    static func getIsFirstLaunch() -> Bool {
        UserDefaults.standard.bool(forKey: Self.isFirstLaunch)
    }
    
    static func setIsFirstLaunch(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.isFirstLaunch)
    }
}
