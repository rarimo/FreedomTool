import Web3
import Foundation
import KeychainAccess

class KeychainUtils {
    static let service = "org.freedomtool"
    
    static let nfcModelkey = "nfcModel"
    static let nationalityKey = "nationality"
    static let birthdayKey = "birthday"
    static let privateKeyKey = "privateKey"
    
    static func saveNfcModelData(_ data: Data) {
        let keychain = Keychain(service: KeychainUtils.service)
        
        try! keychain.set(data.base64EncodedString(), key: KeychainUtils.nfcModelkey)
    }
    
    static func saveNationality(_ nationality: String) {
        let keychain = Keychain(service: KeychainUtils.service)
        
        try! keychain.set(nationality, key: nationalityKey)
    }
    
    static func saveBirthday(_ birthday: Date) {
        let keychain = Keychain(service: KeychainUtils.service)
        
        try! keychain.set(birthday.ISO8601Format(), key: birthdayKey)
    }
    
    static func getNfcModelData() -> String? {
        let keychain = Keychain(service: KeychainUtils.service)
        
        return try! keychain.get(KeychainUtils.nfcModelkey)
    }
    
    static func getNationality() -> String? {
        let keychain = Keychain(service: KeychainUtils.service)
        
        return try! keychain.get(KeychainUtils.nationalityKey)
    }
    
    static func getBirthday() -> Date? {
        let keychain = Keychain(service: KeychainUtils.service)
        
        guard let rawbirthday = try! keychain.get(KeychainUtils.birthdayKey) else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        return dateFormatter.date(from: rawbirthday)
    }
    
    static func eraceData() {
        let keychain = Keychain(service: KeychainUtils.service)
        
        try! keychain.remove(KeychainUtils.nfcModelkey)
        try! keychain.remove(KeychainUtils.nationalityKey)
        try! keychain.remove(KeychainUtils.birthdayKey)
//        try! keychain.remove(KeychainUtils.privateKeyKey)
    }
    
    static func getPrivateKey() -> String? {
        let keychain = Keychain(service: KeychainUtils.service)
                
        if let rawPrivateKey = try? keychain.get(KeychainUtils.privateKeyKey) {
            return rawPrivateKey
        }
        
        guard let privateKey = try? EthereumPrivateKey() else {
            return nil
        }
        
        let newPrivateKey = privateKey.hex()
        
        try! keychain.set(newPrivateKey, key: KeychainUtils.privateKeyKey)
        
        return newPrivateKey
    }
}
