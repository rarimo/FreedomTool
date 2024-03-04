import Foundation
import CommonCrypto
import KeychainAccess

class UserStorage {
    static let keychain = Keychain(service: "org.freedomtool.userstorage")
    static let activeUserIdKey = "org.freedomtool.userstorage.active_user_id_key"
    
    static func getActiveUserId() -> String? {        
        return UserDefaults.standard.string(forKey: activeUserIdKey)
    }
    
    static func setActiveUserId(id: String) {        
        UserDefaults.standard.set(id, forKey: activeUserIdKey)
    }
    
    static func eraceActiveUserId() {
        UserDefaults.standard.removeObject(forKey: activeUserIdKey)
    }
    
    static func isUserExist(id: String) throws -> Bool {
        return try keychain.contains(id)
    }
    
    static func getUserByID(id: String) throws -> User {
        guard let json = try keychain.get(id) else {
            throw "User does not exist"
        }
        
        return try JSONDecoder().decode(User.self, from: Data(json.bytes))
    }
    
    static func eraceUser(id: String) throws {
        try keychain.remove(id)
    }
    
    static func setUser(user: User) throws {        
        let jsonData = try JSONEncoder().encode(user)
        
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw "jsonData is not string"
        }
        
        try keychain.set(json, key: user.id)
    }
    
    struct User: Codable {
        let id: String
        let issuingAuthority: String
        let isAdult: Bool
        let claimId: String
        let issuerDid: String
        let secretKeyHex: String
        let secretHex: String
        let nullifierHex: String
        let creationTimestamp: Int64
        var requestedIn: [String]
        
        func getIssuingAuthorityCode() -> String {
            switch self.issuingAuthority {
            case "UKR":
                return "4903594"
            case "RUS":
                return "13281866"
            case "GEO":
                return "15901410"
            default:
                return "0"
            }
        }
        
        static let sample = User(
            id: "1",
            issuingAuthority: "USA",
            isAdult: true,
            claimId: "4940ae5d-d198-11ee-b1f8-220bd8de42d4",
            issuerDid: "did:iden3:readonly:tLd8sbb1xTSvi2wtRF4TUVcfDUr8ppYMohLqjhGQT",
            secretKeyHex: "0",
            secretHex: "0",
            nullifierHex: "0",
            creationTimestamp: 1709319521,
            requestedIn: []
        )
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

extension String {
    var hex: Data {
        return Data(convertHex(self.unicodeScalars, i: self.unicodeScalars.startIndex, appendTo: []))
    }
}

fileprivate func convertHex(_ s: String.UnicodeScalarView, i: String.UnicodeScalarIndex, appendTo d: [UInt8]) -> [UInt8] {

    let skipChars = CharacterSet.whitespacesAndNewlines

    guard i != s.endIndex else { return d }

    let next1 = s.index(after: i)
    
    if skipChars.contains(s[i]) {
        return convertHex(s, i: next1, appendTo: d)
    } else {
        guard next1 != s.endIndex else { return d }
        let next2 = s.index(after: next1)

        let sub = String(s[i..<next2])
        
        guard let v = UInt8(sub, radix: 16) else { return d }
        
        return convertHex(s, i: next2, appendTo: d + [ v ])
    }
}

extension String {
    func parsableDateToPretty() -> String {
        let partYearStartIndex = self.startIndex
        let partYearEndIndex = self.index(self.startIndex, offsetBy: 2)
        
        let partYear = self[partYearStartIndex..<partYearEndIndex]
        
        let year = Int(partYear, radix: 10)! <= 34 ? "20" + partYear : "19" + partYear
        
        let monthStartIndex = self.index(self.startIndex, offsetBy: 2)
        let monthEndIndex = self.index(self.startIndex, offsetBy: 4)
        
        let month = self[monthStartIndex..<monthEndIndex]
        
        let dayStartIndex = self.index(self.startIndex, offsetBy: 4)
        let dayEndIndex = self.index(self.startIndex, offsetBy: 6)
        
        let day = self[dayStartIndex..<dayEndIndex]
        
        return "\(year).\(month).\(day)"
    }
}

extension String {
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
}

extension String {
    func parsableDateToDate() -> Date {
        let partYearStartIndex = self.startIndex
        let partYearEndIndex = self.index(self.startIndex, offsetBy: 2)
        
        let partYear = self[partYearStartIndex..<partYearEndIndex]
        
        let year = Int(partYear, radix: 10)! <= 34 ? "20" + partYear : "19" + partYear
        
        let monthStartIndex = self.index(self.startIndex, offsetBy: 2)
        let monthEndIndex = self.index(self.startIndex, offsetBy: 4)
        
        let month = self[monthStartIndex..<monthEndIndex]
        
        let dayStartIndex = self.index(self.startIndex, offsetBy: 4)
        let dayEndIndex = self.index(self.startIndex, offsetBy: 6)
        
        let day = self[dayStartIndex..<dayEndIndex]

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "yyyy-MM-dd"
         
        let rawDate = dateFormatter.date(from: "\(year)-\(month)-\(day)") ?? Date()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: rawDate)
        
        return calendar.date(from:components) ?? Date()
    }
}

extension Date {
    func age() -> Int {
        let calendar = Calendar.current
        let calcAge = calendar.dateComponents([.year], from: self, to: Date())
        
        return calcAge.year ?? 0
    }
}
