import SwiftUI
import Identity
import Web3
import Web3ContractABI
import Web3PromiseKit

import KeychainAccess
import NFCPassportReader
import Alamofire

class IdentityManager {
    let web3: Web3
    
    let stateProvider = StateProvider()
    
    let identity: IdentityIdentity
    
    init() throws {
        var identityCreationError: NSError?
//        let newIdentityResult = IdentityNewIdentity(
//            stateProvider,
//            &identityCreationError
//        )
        let newIdentityResult = IdentityNewIdentityWithData(
            "597fdce5f4d976dfb80dd62d618d8a5f14753b64acec0dc5bc1e92eb38033023",
            "e1fc8bcc04dd03cf9f2177a6ce54391b7a425908fefffd1af811c3f3eaae6a",
            "47b15ac5203b7aab1e62650dcefda0df0a20885408609e361a53f05c5913a9",
            stateProvider,
            &identityCreationError
        )
        if let error = identityCreationError {
            throw error
        }
        
        guard let newIdentity = newIdentityResult else {
            throw "Identity wasn't initialized"
        }
        
        print("secretKeyHex: \(newIdentity.getSecretKeyHex())")
        print("secretHex: \(newIdentity.getSecretHex())")
        print("nullifierHex: \(newIdentity.getNullifierHex())")
//
        let vcsJSON = NSDataAsset(name: "VCYaroslav")!.data
//        
        try newIdentity.setVCsJSON(vcsJSON)
        
        guard let evmRPC = Bundle.main.object(forInfoDictionaryKey: "EVMRPC") as? String else {
            throw "EVMRPC is not defined"
        }
        
        web3 = Web3(rpcURL: evmRPC)
        
        identity = newIdentity
    }
    
    func issueIdentity(_ model: NFCPassportModel) async throws -> CreateIdentityResponse {
        guard let identityProviderNodeURLRawObj = Bundle.main.object(forInfoDictionaryKey: "IdentityProviderNodeURL") else {
            throw "IdentityProviderNodeURL is not defined"
        }
        
        guard var identityProviderNodeURLRaw = identityProviderNodeURLRawObj as? String else {
            throw "IdentityProviderNodeURL is not string"
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
        
        return try await AF.request(request)
            .serializingDecodable(CreateIdentityResponse.self)
            .result
            .get()
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
    
    func getCoreStateHash(issuerIdHex: String) async throws -> String {
        var rarimoCoreURL = try Self.getRarimoCoreURL()
        rarimoCoreURL += "/rarimo/rarimo-core/identity/state/\(issuerIdHex)"
        
        let response = try await AF.request(rarimoCoreURL, method: .get)
            .serializingDecodable(GetStateInfoResponse.self)
            .result
            .get()
        
        return response.state.hash
    }
    
    func getVotingRoot() async throws -> Data {
        let registerContract = try getRegisterContract()
        
        let response = try registerContract["getRoot"]!().call().wait()
                
        guard let root = response[""] as? Data else {
            throw "Invalid root type"
        }
        
        return root
    }
    
    func getVotingSiblings() async throws -> [Data] {
        let registerContract = try getRegisterContract()
        
        let commitmentIndex = try identity.getCommitmentIndex()
        
        let response = try registerContract["getProof"]!(commitmentIndex).call().wait()
        
        guard let proof = response[""] as? [String: Any] else {
            throw "Proof is not hex"
        }
        
        guard let siblings = proof["siblings"] as? [Data] else {
            throw "Proof does not contain siblings"
        }
        
        return siblings
    }
    
    func getRegisterContract() throws -> DynamicContract {
        guard let registerAddressStr = Bundle.main.object(forInfoDictionaryKey: "RegisterAddress") as? String else {
            throw "RegisterAddress is not defined"
        }
        
        let registerAddress = try EthereumAddress(hex: registerAddressStr, eip55: false)
        
        let registrationJson = NSDataAsset(name: "Registration.json")!.data
        
        return try web3.eth.Contract(json: registrationJson, abiKey: nil, address: registerAddress)
    }
    
    func getVotingInputs(vote: String) async throws -> Data {
        guard let votingAddressStr = Bundle.main.object(forInfoDictionaryKey: "VotingAddress") as? String else {
            throw "VotingAddress is not defined"
        }
        
        let root = try await getVotingRoot()
        let siblingsData = try await getVotingSiblings()
        
        let secret = identity.getSecretIntStr()
        let nullifier = identity.getNullifierIntStr()
        
        var siblings = [String]()
        for siblingData in siblingsData {
            siblings.append("0x" + siblingData.hexStringEncoded())
        }
        
        let votingInputs = VotingInputs(
            root: "0x" + root.toHexString(),
            vote: vote,
            votingAddress: votingAddressStr,
            secret: secret,
            nullifier: nullifier,
            siblings: siblings
        )
        
        return try JSONEncoder().encode(votingInputs)
    }
    
    func register(issuerDid: String) async throws -> String {
        var error: NSError?
        let issuerIDHash = identity.did(toIDHex: issuerDid, error: &error)
        if let error = error {
            throw error
        }
        
        let issuerId = identity.did(toId: issuerDid, error: &error)
        if let error = error {
            throw error
        }
        
        let coreStateHash = try await getCoreStateHash(issuerIdHex: issuerIDHash)
        
        let votingAddress = try Self.getStringFromInfoPlist(key: "VotingAddress")
        
        let schemaJson = NSDataAsset(name: "VotingCredential.jsonld")!.data
        
        let inputs = try identity.prepareQueryInputs(
            coreStateHash,
            votingAddress: votingAddress,
            schemaJson: schemaJson
        )
        
        let wtns = try ZKUtils.calcWtnscredentialAtomicQueryMTPV2OnChainVoting(inputsJson: inputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16credentialAtomicQueryMTPV2OnChainVoting(wtns: wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode([String].self, from: pubSignalsJson)
        
        let issuerState = identity.getIssuerState(&error)
        if let error = error {
            throw error
        }
        
        let statesMerkleData = StatesMerkleData(
            issuerId: issuerId,
            issuerState: issuerState,
            createdAtTimestamp: Date().timeIntervalSince1970.description,
            merkleProof: []
        )
        
        let _proveIdentityParams = ProveIdentityParams(
            statesMerkleData: statesMerkleData,
            inputs: pubSignals,
            a: proof.piA,
            b: proof.piB,
            c: proof.piC
        )
        
        let _newIdentitiesStatesRoot = identity.newIdentitiesStatesRoot(
            statesMerkleData.issuerId,
            issuerState: statesMerkleData.issuerState,
            createdAtTimestamp: statesMerkleData.createdAtTimestamp,
            error: &error
        )
        if let error = error {
            throw error
        }
        
        let inputsData = try JSONDecoder().decode(AtomicQueryMTPV2OnChainVotingCircuitInputs.self, from: inputs)
        
        let _gistRootData = GistRootData(
            root: inputsData.gistRoot,
            createdAtTimestamp: inputsData.timestamp.description
        )
        
        // get Threshold signature
        
        
        
        return ""
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
    var lastRetrivedData = Data()
    var error: Error? = nil
    
    func localPrinter(_ msg: String?) {
        print(msg!)
    }
    
    func fetch(_ url: String?, method: String?, body: String?) throws -> Data {
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
        if body != "" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyRaw
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

struct StatesMerkleData {
    let issuerId: String
    let issuerState: String
    let createdAtTimestamp: String
    let merkleProof: [String]
}

struct ProveIdentityParams {
    let statesMerkleData: StatesMerkleData
    let inputs: [String]
    let a: [String]
    let b: [[String]]
    let c: [String]
}

struct TransitStateParams {
    let newIdentitiesStatesRoot: String
    let gistData: GistRootData
    let proof: String
}

struct GistRootData {
    let root: String
    let createdAtTimestamp: String
}

struct RegisterProofParams {
    let issuingAuthority: String
    let documentNullifier: String
    let commitment: String
}

struct AtomicQueryMTPV2OnChainVotingCircuitInputs: Codable {
    let gistRoot: String
    let timestamp: Int
}
