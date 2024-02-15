import Foundation
import Identity
import web3
import KeychainAccess
import NFCPassportReader
import Alamofire

class IdentityManager {
    let keyStorage = EthereumKeychainStorage()
    
    let stateProvider = StateProvider()
    
    let account: EthereumAccount
    
    let identity: IdentityIdentity
    
    init(password: String) throws {
        if keyStorage.isPrivateKeyExist() {
            account = try EthereumAccount(keyStorage: keyStorage)
        } else {
            account = try EthereumAccount.create(replacing: keyStorage, keystorePassword: password)
        }
        
        let privateKeyHex = keyStorage.privateKeyData.hexStringEncoded()
        
        var identityCreationError: NSError?
        let newIdentityResult = IdentityNewIdentity(
            privateKeyHex,
            stateProvider,
            &identityCreationError
        )
        if let error = identityCreationError {
            throw error
        }
        
        guard let newIdentity = newIdentityResult else {
            throw "Identity wasn't initialized"
        }
        
        identity = newIdentity
    }
    
    func issueIdentity(_ model: NFCPassportModel) async throws -> CreateIdentityResponse {
        guard let identityProviderNodeURLRawObj = Bundle.main.object(forInfoDictionaryKey: "IdentityProviderNodeURL") else {
            throw "IdentityProviderNodeURL is not defined"
        }
        
        guard var identityProviderNodeURLRaw = identityProviderNodeURLRawObj as? String else {
            throw "IdentityProviderNodeURL is not string"
        }
        
        identityProviderNodeURLRaw += String(format: "/integrations/identity-provider-service/v1/create-identity")
        
        guard let identityProviderNodeURL = URL(string: identityProviderNodeURLRaw) else {
            throw "IdentityProviderNodeURL is not URL"
        }
        
        
        let payload = try preparePayloadForCreateIdentity(model)
        
        var request = URLRequest(url: identityProviderNodeURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        
        print("Payload: \(String(data: payload, encoding: .utf8)!)")
        
        let response = await AF.request(request)
            .serializingDecodable(CreateIdentityResponse.self)
            .result

        if case .failure(let failure) = response {
            throw failure.localizedDescription
        }

        switch response {
        case .success(let response):
            return response
        case .failure(let failure):
            throw failure.localizedDescription
        }
    }
    
    func preparePayloadForCreateIdentity(_ model: NFCPassportModel) throws -> Data {
        guard
            let sod = model.getDataGroup(.SOD) as? SOD,
            let dg1 = model.getDataGroup(.DG1)
        else {
            throw "Invalid data groups"
        }
        
        let certs = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.body))
        
        guard let cert = certs.first else {
            throw "Certificates were not found"
        }
        
        var signatureAlgorithm = try sod.getSignatureAlgorithm()
        if signatureAlgorithm == "sha256WithRSAEncryption" {
            signatureAlgorithm = "SHA256withRSA"
        }
        
        let signedAttributes = try sod.getSignedAttributes().hexStringEncoded()
        let signature = try sod.getSignature().hexStringEncoded()
        let encapsulatedContent = try sod.getEncapsulatedContent().hexStringEncoded()
        
        let digestAlgorithm = try sod.getEncapsulatedContentDigestAlgorithm()
        
        let inputs = try prepareInputs(Data(dg1.data))
        
        let (proofRaw, pubSignalsRaw) = try generatePassportVerification(inputs, digestAlgorithm: digestAlgorithm)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofRaw)
        let pubSignals = try JSONDecoder().decode([String].self, from: pubSignalsRaw)
        
        let zkproof = Zkproof(
            proof: proof,
            pubSignals: pubSignals
        )
        
        let documentSod = DocumentSod(
            signedAttributes: signedAttributes,
            algorithm: signatureAlgorithm,
            signature: signature,
            pemFile: cert.certToPEM(),
            encapsulatedContent: encapsulatedContent
        )
        
        let request = CreateIdentityRequest(
            data: CreateIdentityRequestDataClass(
                id: identity.getDID(),
                documentSod: documentSod,
                zkproof: zkproof
            )
        )
    
        return try JSONEncoder().encode(request)
    }
    
    func prepareInputs(_ dg1: Data) throws -> Data {
        let currentYear = Calendar.current.component(.year, from: Date())-2000
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        
        let inputs = PassportInput(
            inKey: dg1.toCircuitInput(),
            currDateYear: currentYear,
            currDateMonth: currentMonth,
            currDateDay: currentDay,
            credValidYear: currentYear+1,
            credValidMonth: currentMonth,
            credValidDay: currentDay,
            ageLowerbound: 18
        )
        
        return try JSONEncoder().encode(inputs)
    }
    
    func generatePassportVerification(_ inputs: Data, digestAlgorithm: String) throws -> (proof: Data, pubSignals: Data) {        
        if digestAlgorithm == "sha256" {
            let witness = try ZKUtils.calcWtnsPassportVerificationSHA256(inputsJson: inputs)
            let (proof, pubSignals) = try ZKUtils.groth16PassportVerificationSHA256Prover(wtns: witness)
            
            return (proof, pubSignals)
        }
        
        if digestAlgorithm == "sha1" {
            let witness = try! ZKUtils.calcWtnsPassportVerificationSHA256(inputsJson: inputs)
            let (proof, pubSignals) = try! ZKUtils.groth16PassportVerificationSHA256Prover(wtns: witness)
            
            return (proof, pubSignals)
        }
        
        throw "Unsupported digest algorithm"
    }

}

class EthereumKeychainStorage: EthereumSingleKeyStorageProtocol {
    static let service = "FreedomTool.Ethereum"
    
    static let storageKey = "PrivateKey"
    
    let keychain = Keychain(service: EthereumKeychainStorage.service)
    
    var privateKeyData: Data = Data()

    func storePrivateKey(key: Data) throws {
        privateKeyData = key
        
        try keychain.set(key, key: Self.storageKey)
    }
    
    func loadPrivateKey() throws -> Data {
        guard let privateKey = try keychain.getData(Self.storageKey) else {
            throw "Private key wasn't stored"
        }
        
        privateKeyData = privateKey
        
        return privateKey
    }
    
    func isPrivateKeyExist() -> Bool {
        guard let isPrivateKeyExist = try? keychain.contains(Self.storageKey) else {
            return false
        }
        
        return isPrivateKeyExist
    }
    
    func createIdentity() async throws {
        
    }
}

class StateProvider: NSObject, IdentityStateProviderProtocol {
    func fetchW3Credentials(_ url: String?, method: String?, body: String?) throws -> Data {
        guard
            let urlRaw = url,
            let method = method,
            let body = body
        else {
            throw "url/method/body is invalid"
        }
        
        guard let url = URL(string: urlRaw) else {
            throw "invalid url format"
        }
        
        guard let bodyRaw = body.data(using: .utf8) else {
            throw "invalid body"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyRaw
        
        let finishedRequest = request
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            let response = await AF.request(finishedRequest).serializingData()
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return Data()
    }
    
    func getGISTProof(_ userId: String?) throws -> Data {
        return Data()
    }
    
    func getChainInfo() throws -> Data {
        return Data()
    }
    
    func proveAuthV2(_ inputs: Data?) throws -> Data {
        return Data()
    }
    
}

public extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    func hexStringEncoded() -> String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }
}


// MARK: - CreateIdentityRequest
struct CreateIdentityRequest: Codable {
    let data: CreateIdentityRequestDataClass
}

// MARK: - CreateIdentityRequestDataClass
struct CreateIdentityRequestDataClass: Codable {
    let id: String
    let documentSod: DocumentSod
    let zkproof: Zkproof

    enum CodingKeys: String, CodingKey {
        case id
        case documentSod = "document_sod"
        case zkproof
    }
}

// MARK: - DocumentSod
struct DocumentSod: Codable {
    let signedAttributes, algorithm, signature, pemFile: String
    let encapsulatedContent: String

    enum CodingKeys: String, CodingKey {
        case signedAttributes = "signed_attributes"
        case algorithm, signature
        case pemFile = "pem_file"
        case encapsulatedContent = "encapsulated_content"
    }
}

// MARK: - Zkproof
struct Zkproof: Codable {
    let proof: Proof
    let pubSignals: [String]

    enum CodingKeys: String, CodingKey {
        case proof
        case pubSignals = "pub_signals"
    }
}

// MARK: - Proof
struct Proof: Codable {
    let piA: [String]
    let piB: [[String]]
    let piC: [String]
    let proofProtocol: String

    enum CodingKeys: String, CodingKey {
        case piA = "pi_a"
        case piB = "pi_b"
        case piC = "pi_c"
        case proofProtocol = "protocol"
    }
}

// MARK: - CreateIdentityResponse
struct CreateIdentityResponse: Codable {
    let data: CreateIdentityResponseDataClass
}

// MARK: - CreateIdentityResponseDataClass
struct CreateIdentityResponseDataClass: Codable {
    let id, type: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable {
    let claimID, issuerDid: String

    enum CodingKeys: String, CodingKey {
        case claimID = "claim_id"
        case issuerDid = "issuer_did"
    }
}
