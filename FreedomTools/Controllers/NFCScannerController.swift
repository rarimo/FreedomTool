import SwiftUI
import NFCPassportReader
import OpenSSL

class NFCScannerController: ObservableObject {
    var nfcModel: NFCPassportModel?
    
    var onScanned: () -> Void = {}
    var onError: () -> Void = {}
    
    func setOnScanned(newOnScanned: @escaping () -> Void) {
        onScanned = newOnScanned
    }
    
    func setOnError(newOnError: @escaping () -> Void) {
        onError = newOnError
    }
    
    func read(_ mrzKey: String)  {
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                try await self._read(mrzKey)
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.onError()
                }
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    private func _read(_ mrzKey: String) async throws {
        let masterListURL = Bundle.main.url(forResource: "masterList", withExtension: ".pem")!
                
        nfcModel = try await PassportReader(masterListURL: masterListURL).readPassport(mrzKey: mrzKey, tags: [.DG1, .DG2, .DG7, .DG11, .SOD])
        
        
        if nfcModel != nil {
            KeychainUtils.saveNfcModelData(nfcModel!.getDataGroupsRead())
            KeychainUtils.saveNationality(nfcModel!.issuingAuthority)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.onScanned()
        }
    }
}

extension String {
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
}

extension NFCPassportModel {
    func getDataGroupsRead() -> Data {
        var data: [DataGroupIdOuter: DataGroupOuter] = [:]
        
        for (k, v) in self.dataGroupsRead {
            data[k.toOuter()] = v.toOuter()
        }
        
        return try! JSONEncoder().encode(data)
    }
}

extension DataGroup {
    func toOuter() -> DataGroupOuter {
        DataGroupOuter(body: self.body, data: self.data)
    }
}

struct DataGroupOuter: Codable {
    var body: [UInt8]
    var data: [UInt8]
}

extension DataGroupId {
    func toOuter() -> DataGroupIdOuter {
        return DataGroupIdOuter(rawValue: self.rawValue)!
    }
}

public enum DataGroupIdOuter: Int, CaseIterable, Codable {
    case COM = 0x60
    case DG1 = 0x61
    case DG2 = 0x75
    case DG3 = 0x63
    case DG4 = 0x76
    case DG5 = 0x65
    case DG6 = 0x66
    case DG7 = 0x67
    case DG8 = 0x68
    case DG9 = 0x69
    case DG10 = 0x6A
    case DG11 = 0x6B
    case DG12 = 0x6C
    case DG13 = 0x6D
    case DG14 = 0x6E
    case DG15 = 0x6F
    case DG16 = 0x70
    case SOD = 0x77
    case Unknown = 0x00
    
    func toInner() -> DataGroupId {
        DataGroupId(rawValue: self.rawValue)!
    }
}

extension Data {
    func toCircuitInput() -> [UInt8] {
        var circuitInput = Data()
        
        for byte in self {
            circuitInput.append(contentsOf: byte.bits())
        }
        
        return [UInt8](circuitInput)
    }
}

extension UInt8 {
    func bits() -> [UInt8] {
        var byte = self
        var bits = [UInt8](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = 1
            }

            byte >>= 1
        }

        return bits.reversed()
    }
}

struct PassportInput: Codable {
    let inKey: [UInt8]
    let currDateYear: Int
    let currDateMonth: Int
    let currDateDay: Int
    let credValidYear: Int
    let credValidMonth: Int
    let credValidDay: Int
    let ageLowerbound: Int
    
    private enum CodingKeys: String, CodingKey {
        case inKey = "in", currDateYear, currDateMonth, currDateDay, credValidYear, credValidMonth, credValidDay, ageLowerbound
    }
}
