import Foundation
import CommonCrypto
import KeychainAccess

class UserStorage {
    static let keychain = Keychain(service: "org.freedomtool.userstorage")
    
    static func getUserByID(id: String) throws -> User {
        guard let json = try keychain.get(id) else {
            throw "User does not exist"
        }
        
        let user = try JSONDecoder().decode(User.self, from: Data(json.bytes))
        
        return user
    }
    
    static func setUser(user: User) throws {
        let jsonData = try JSONEncoder().encode(user)
        
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw "jsonData is not string"
        }
        
        try keychain.set(user.id, key: json)
    }
    
    struct User: Codable {
        let id: String
        let secretKeyHex: String
        let secretHex: String
        let nullifier: String
        let issuingAuthority: String
        let isAdult: Bool
        let isCredPublished: Bool
        let isRegistered: Bool
        let vcsJSON: Data?
    }
}

extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
}


extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    func hexStringEncoded() -> String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }
}

extension String: Error {}
