import SwiftUI

class ZKUtils {
    
    static public func calcWtnsPassportVerificationSHA1(inputsJson: Data) throws -> Data {
        let dat = NSDataAsset(name: "passportVerificationSHA1.dat")!.data
        return try _calcWtnsPassportVerificationSHA1(dat: dat, jsonData: inputsJson)
    }
    
    static private func _calcWtnsPassportVerificationSHA1(dat: Data, jsonData: Data) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let datSize = UInt(dat.count)
        let jsonDataSize = UInt(jsonData.count)

        let errorSize = UInt(256);
        
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1));
        wtnsSize.initialize(to: UInt(100 * 1024 * 1024 ))
        
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: (100 * 1024 * 1024))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(errorSize))
        
        let result = witnesscalc_passportVerificationSHA1(
            (dat as NSData).bytes, datSize,
            (jsonData as NSData).bytes, jsonDataSize,
            wtnsBuffer, wtnsSize,
            errorBuffer, errorSize
        )
        
        if result == WITNESSCALC_ERROR {
            throw String(bytes: Data(bytes: errorBuffer, count: Int(errorSize)), encoding: .utf8)!
                .replacingOccurrences(of: "\0", with: "")
        }
        
        if result == WITNESSCALC_ERROR_SHORT_BUFFER {
            throw String("Buffer to short, should be at least: \(wtnsSize.pointee)")
        }
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    static public func calcWtnsPassportVerificationSHA256(inputsJson: Data) throws -> Data {
        let dat = NSDataAsset(name: "passportVerificationSHA256.dat")!.data
        return try _calcWtnsPassportVerificationSHA256(dat: dat, jsonData: inputsJson)
    }
    
    static private func _calcWtnsPassportVerificationSHA256(dat: Data, jsonData: Data) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let datSize = UInt(dat.count)
        let jsonDataSize = UInt(jsonData.count)

        let errorSize = UInt(256);
        
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1));
        wtnsSize.initialize(to: UInt(100 * 1024 * 1024 ))
        
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: (100 * 1024 * 1024))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(errorSize))
        
        let result = witnesscalc_passportVerificationSHA256(
            (dat as NSData).bytes, datSize,
            (jsonData as NSData).bytes, jsonDataSize,
            wtnsBuffer, wtnsSize,
            errorBuffer, errorSize
        )
        
        if result == WITNESSCALC_ERROR {
            throw String(bytes: Data(bytes: errorBuffer, count: Int(errorSize)), encoding: .utf8)!
                .replacingOccurrences(of: "\0", with: "")
        }
        
        if result == WITNESSCALC_ERROR_SHORT_BUFFER {
            throw String("Buffer to short, should be at least: \(wtnsSize.pointee)")
        }
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    static public func groth16PassportVerificationSHA1Prover(wtns: Data) throws -> (proof: Data, publicInputs: Data) {
        return try _groth16Prover(zkey: NSDataAsset(name: "passportVerificationSHA1.zkey")!.data, wtns: wtns)
    }
    
    static public func groth16PassportVerificationSHA256Prover(wtns: Data) throws -> (proof: Data, publicInputs: Data) {
        return try _groth16Prover(zkey: NSDataAsset(name: "passportVerificationSHA256.zkey")!.data, wtns: wtns)
    }

    static private func _groth16Prover(zkey: Data, wtns: Data) throws -> (proof: Data, publicInputs: Data) {
#if targetEnvironment(simulator)
        return (Data(), Data())
#else
        let zkeySize = zkey.count
        let wtnsSize = wtns.count
        
        var proofSize: UInt = 4 * 1024 * 1024
        var publicSize: UInt = 4 * 1024 * 1024
        
        let proofBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(proofSize))
        let publicBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(publicSize))
        
        let errorBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
        let errorMaxSize: UInt = 256
        
        let result = groth16_prover(
            (zkey as NSData).bytes, UInt(zkeySize),
            (wtns as NSData).bytes, UInt(wtnsSize),
            proofBuffer, &proofSize,
            publicBuffer, &publicSize,
            errorBuffer, errorMaxSize
        )
        
        if result == PROVER_ERROR {
            throw String(bytes: Data(bytes: errorBuffer, count: Int(errorMaxSize)), encoding: .utf8)!
                .replacingOccurrences(of: "\0", with: "")
        }
        
        if result == PROVER_ERROR_SHORT_BUFFER {
            throw "Proof or public inpurs buffer is too short"
        }
        
        var proof = Data(bytes: proofBuffer, count: Int(proofSize))
        var publicInputs = Data(bytes: publicBuffer, count: Int(publicSize))
        
        let proofNullIndex = proof.firstIndex(of: 0x00)!
        let publicInputsNullIndex = publicInputs.firstIndex(of: 0x00)!
        
        proof = proof[0..<proofNullIndex]
        publicInputs = publicInputs[0..<publicInputsNullIndex]
        
        
        return (proof: proof, publicInputs: publicInputs)
#endif
    }
}

extension String: Error {}
