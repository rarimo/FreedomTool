import SwiftUI
import Identity
import Web3
import Web3ContractABI
import Web3PromiseKit

import KeychainAccess
import NFCPassportReader
import Alamofire

class IdentityManager {
    let stateProvider = StateProvider()
    
    let identity: IdentityIdentity
    
    init() throws {
        var identityCreationError: NSError?
        let newIdentityResult = IdentityNewIdentity(
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
    
    init(secretKeyHex: String, secretHex: String, nullifierHex: String) throws {
        var identityCreationError: NSError?
        
        let newIdentityResult = IdentityNewIdentityWithData(
            secretKeyHex,
            secretHex,
            nullifierHex,
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
        guard var identityProviderNodeURLRaw = Bundle.main.object(forInfoDictionaryKey: "IdentityProviderNodeURL") as? String else {
            throw "IdentityProviderNodeURL is not defined"
        }
        
        identityProviderNodeURLRaw += "/integrations/identity-provider-service/v1/create-identity"
        
        guard let identityProviderNodeURL = URL(string: identityProviderNodeURLRaw) else {
            throw "IdentityProviderNodeURL is not URL"
        }
        
        let payload = try preparePayloadForCreateIdentity(model)
        
        var request = URLRequest(url: identityProviderNodeURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        
        let response = await AF.request(request)
            .serializingDecodable(CreateIdentityResponse.self)
            .response
        
        if response.response?.statusCode == 429 {
            throw "ErrorTooManyRequest"
        }
        
        return try response.result.get()
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
    
    func register(
        issuerDid: String,
        votingAddress: String,
        issuingAuthorityCode: String,
        stateInfo: StateInfo
    ) async throws -> String {
        let calldata = try identity.register(
            Self.getRarimoCoreURL(),
            issuerDid: issuerDid,
            votingAddress: votingAddress,
            schemaJsonLd: NSDataAsset(name: "VotingCredential.jsonld")!.data,
            issuingAuthorityCode: issuingAuthorityCode,
            stateInfoJSON: try JSONEncoder().encode(stateInfo)
        )
        
        return try await sendCalldata(calldata)
    }
    
    func sendCalldata(_ calldata: Data) async throws -> String {
        guard var proofVerificationRelayerURL = Bundle.main.object(forInfoDictionaryKey: "ProofVerificationRelayerURL") as? String else {
            throw "ProofVerificationRelayerURL is not defined"
        }
        
        proofVerificationRelayerURL += "/integrations/proof-verification-relayer/v1/register"
        
        let calldataRequest = SendCalldataRequest(data: SendCalldataRequestData(txData: "0x" + calldata.toHexString()))
        
        let relayerResponse = try await AF.request(
            proofVerificationRelayerURL,
            method: .post,
            parameters: calldataRequest,
            encoder: JSONParameterEncoder()
        )
            .serializingDecodable(RelayerResponse.self)
            .result
            .get()
        
        return relayerResponse.attributes.txHash
    }
    
    static func getIssuerProviderNodeURL() throws -> String {
        return try getStringFromInfoPlist(key: "IdentityProviderNodeURL")
    }
    
    static func getRarimoCoreURL() throws -> String {
        return try getStringFromInfoPlist(key: "RarimoCoreURL")
    }
    
    static func getStringFromInfoPlist(key: String) throws -> String {
        guard let identityProviderNodeURLRawObj = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw "\(key) is not defined"
        }
        
        guard let identityProviderNodeURLRaw = identityProviderNodeURLRawObj as? String else {
            throw "\(key) is not string"
        }
        
        return identityProviderNodeURLRaw
    }
}

class StateProvider: NSObject, IdentityStateProviderProtocol {
    func isUserRegistered(_ contract: String?, documentNullifier: Data?, ret0_: UnsafeMutablePointer<ObjCBool>?) throws {
        guard
            let contract = contract,
            let documentNullifier = documentNullifier,
            let returnPointer = ret0_
        else {
            throw "contract, returnPointer, and/or documentNullifier are empty"
        }
        
        let documentNullifierBigUInt = BigUInt(documentNullifier)
        
        let evmRPC = Bundle.main.object(forInfoDictionaryKey: "EVMRPC") as! String
        let web3 = Web3(rpcURL: evmRPC)
        
        let registrationJson = NSDataAsset(name: "Registration.json")!.data
        
        let contractAddress = try EthereumAddress(hex: contract, eip55: false)
        let registrationContract = try web3.eth.Contract(json: registrationJson, abiKey: nil, address: contractAddress)
        
        let isUserRegisteredMethod = registrationContract["isUserRegistered"]!
        
        let result = try isUserRegisteredMethod(documentNullifierBigUInt).call().wait()
        
        guard let resultValue = result[""] else {
            throw "unable to get result value"
        }
        
        guard let isUserRegistered = resultValue as? Bool else {
            throw "resultValue is not Bool"
        }
        
        returnPointer.initialize(to: ObjCBool(isUserRegistered))
    }
    
    func proveCredentialAtomicQueryMTPV2(onChainVoting inputs: Data?) throws -> Data {
        guard let inputs = inputs else {
            throw "inputs is not presented"
        }
        
        let wtns = try ZKUtils.calcWtnscredentialAtomicQueryMTPV2OnChainVoting(inputsJson: inputs)
        
        let (proofRaw, pubSignalsRaw) = try ZKUtils.groth16credentialAtomicQueryMTPV2OnChainVoting(wtns: wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofRaw)
        let pubSignals = try JSONDecoder().decode([String].self, from: pubSignalsRaw)
        
        let zkproof = Zkproof(proof: proof, pubSignals: pubSignals)
        
        return try JSONEncoder().encode(zkproof)
    }
    
    var lastRetrivedData = Data()
    var error: Error? = nil
    
    func localPrinter(_ msg: String?) {
        print(msg!)
    }
    
    func fetch(_ url: String?, method: String?, body: Data?, headerKey: String?, headerValue: String?) throws -> Data {
        guard
            let urlRaw = url,
            let method = method,
            let headerKey = headerKey,
            let headerValue = headerValue
        else {
            throw "url/method/headerKey/headerValue is invalid"
        }
        
        print(urlRaw)
        
        guard let url = URL(string: urlRaw) else {
            throw "invalid url format"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            if !body.isEmpty {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
            }
        }
        
        if !headerKey.isEmpty && !headerValue.isEmpty {
            request.setValue(headerKey, forHTTPHeaderField: headerValue)
        }
        
        let finishedRequest = request
        
        defer {
            lastRetrivedData = Data()
            error = nil
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                lastRetrivedData = try await AF.request(finishedRequest).serializingData().result.get()
            } catch let err {
                error = err
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
        return lastRetrivedData
    }
    
    func getGISTProof(_ userId: String?) throws -> Data {
        guard let userId = userId else {
            throw "userId is not "
        }
        
        guard let identityProviderNodeURLRawObj = Bundle.main.object(forInfoDictionaryKey: "IdentityProviderNodeURL") else {
            throw "IdentityProviderNodeURL is not defined"
        }
        
        guard var identityProviderNodeURLRaw = identityProviderNodeURLRawObj as? String else {
            throw "IdentityProviderNodeURL is not string"
        }
        
        identityProviderNodeURLRaw += "/integrations/identity-provider-service/v1/gist-data"
        identityProviderNodeURLRaw += "?user_did=\(userId)"
        
        guard let identityProviderNodeURL = URL(string: identityProviderNodeURLRaw) else {
            throw "IdentityProviderNodeURL is not URL"
        }
        
        defer {
            lastRetrivedData = Data()
            error = nil
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                lastRetrivedData = try await AF.request(identityProviderNodeURL, method: .get).serializingData().result.get()
            } catch let err {
                error = err
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
        let response = try JSONDecoder().decode(GISTResponse.self, from: lastRetrivedData)
        
        return try JSONEncoder().encode(response.data.attributes.gistProof)
    }
    
    func proveAuthV2(_ inputs: Data?) throws -> Data {
        guard let inputs = inputs else {
            throw "inputs is not valid"
        }
        
        let wtns = try! ZKUtils.calcWtnsAuthV2(inputsJson: inputs)
        
        let (proofRaw, pubSignalsRaw) = try ZKUtils.groth16AuthV2(wtns: wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofRaw)
        let pubSignals = try JSONDecoder().decode([String].self, from: pubSignalsRaw)
        
        let zkproof = Zkproof(proof: proof, pubSignals: pubSignals)
        
        return try JSONEncoder().encode(zkproof)
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
    let attributes: CreateIdentityResponseDataClassAttributes
}

// MARK: - Attributes
struct CreateIdentityResponseDataClassAttributes: Codable {
    let claimID, issuerDid: String

    enum CodingKeys: String, CodingKey {
        case claimID = "claim_id"
        case issuerDid = "issuer_did"
    }
}

// MARK: - DocumentNullifierResponse
struct DocumentNullifierResponse: Codable {
    let data: DocumentNullifierResponseDataClass
}

// MARK: - DocumentNullifierResponseDataClass
struct DocumentNullifierResponseDataClass: Codable {
    let id, type: String
    let attributes: DocumentNullifierResponseDataClassAttributes
}

// MARK: - Attributes
struct DocumentNullifierResponseDataClassAttributes: Codable {
    let documentNullifierHash: String
    
    enum CodingKeys: String, CodingKey {
        case documentNullifierHash = "document_nullifier_hash"
    }
}

// MARK: - GISTResponse
struct GISTResponse: Codable {
    let data: GISTResponseDataClass
}

// MARK: - DataClass
struct GISTResponseDataClass: Codable {
    let id, type: String
    let attributes: GISTResponseDataClassAttributes
}

// MARK: - Attributes
struct GISTResponseDataClassAttributes: Codable {
    let gistProof: GistProof
    let gistRoot: String

    enum CodingKeys: String, CodingKey {
        case gistProof = "gist_proof"
        case gistRoot = "gist_root"
    }
}

// MARK: - GistProof
struct GistProof: Codable {
    let auxExistence: Bool
    let auxIndex, auxValue: String
    let existence: Bool
    let root: String
    let siblings: [String]
    let value: String
    let index: String

    enum CodingKeys: String, CodingKey {
        case auxExistence = "aux_existence"
        case auxIndex = "aux_index"
        case auxValue = "aux_value"
        case existence, root, siblings, value, index
    }
}

struct StateInfo: Codable {
    let index: String
    let hash: String
    let createdAtTimestamp: String
    let createdAtBlock: String
    let lastUpdateOperationIndex: String
}

struct GetStateInfoResponse: Codable {
    let state: StateInfo
}

struct VotingInputs: Codable {
    let root, vote, votingAddress, secret: String
    let nullifier: String
    let siblings: [String]
}

struct StatesMerkleData: Codable {
    let issuerId: String
    let issuerState: String
    let createdAtTimestamp: String
    let merkleProof: [Data]
}

struct ProveIdentityParams: Codable {
    let statesMerkleData: StatesMerkleData
    let inputs: [String]
    let a: [String]
    let b: [[String]]
    let c: [String]
}

struct TransitStateParams: Codable {
    let newIdentitiesStatesRoot: Data
    let gistData: GistRootData
    let proof: Data
}

struct GistRootData: Codable {
    let root: String
    let createdAtTimestamp: String
}

struct RegisterProofParams: Codable {
    let issuingAuthority: String
    let documentNullifier: String
    let commitment: Data
}

struct RegisterInputs {
    let proveIdentityParams: ProveIdentityParams
    let transitStateParams: TransitStateParams
    let registerProofParams: RegisterProofParams
}

struct AtomicQueryMTPV2OnChainVotingCircuitInputs: Codable {
    let gistRoot: String
    let timestamp: Int
}

struct CoreMTP: Codable {
    let proof: [String]
}

struct Operation: Codable {
    let index: String
    let operationType: String
    let details: OperationDetails
    let status: String
    let creator: String
    let timestamp: String
}

struct OperationDetails: Codable {
    let type: String
    let contract: String
    let chain: String
    let GISTHash: String
    let stateRootHash: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case contract, chain, GISTHash, stateRootHash, timestamp
    }
}

struct OperationResponse: Codable {
    let operation: Operation
}

struct OperationProof: Codable {
    let path: [String]
    let signature: String
}

struct SendCalldataRequest: Codable {
    let data: SendCalldataRequestData
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct SendCalldataRequestData: Codable {
    let txData: String
    
    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
    }
}

struct RelayerResponse: Codable {
    let id, type: String
    let attributes: RelayerResponseAttributes
}

// MARK: - Attributes
struct RelayerResponseAttributes: Codable {
    let txHash: String

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
    }
}

struct FinalizedResponse: Codable {
    let isFinalized: Bool
    let stateInfo: StateInfo
}
