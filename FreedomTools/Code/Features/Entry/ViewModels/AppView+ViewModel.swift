import Web3
import Web3PromiseKit
import Web3ContractABI
import SwiftUI
import NFCPassportReader
import Alamofire

extension AppView {
    class ViewModel: ObservableObject {
        @Published var user: UserStorage.User?
        @Published var identityManager: IdentityManager?
        
        @Published var isIntroFinished = StorageUtils.getIsIntroFinished()
        
        @Published var isLocked = true
        
#if DEBUG
        @Published var isDepraceted = false
#else
        @Published var isDepraceted = true
#endif
        
        @Published var localization: String
        
        init() {
            self.user = nil
            self.identityManager = nil
            self.localization = Locale.current.identifier == "ru_US" ? "ru" : "en"
            
#if !DEBUG
            let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
            self.isDepraceted = !isTestFlight
#endif
            
            guard let activeUserId = UserStorage.getActiveUserId() else {
                return
            }
            
            guard let user = try? UserStorage.getUserByID(id: activeUserId) else {
                UserStorage.eraceActiveUserId()
            
                return
            }
            
            guard let identityManager = try? IdentityManager(
                secretKeyHex: user.secretKeyHex,
                secretHex: user.secretHex,
                nullifierHex: user.nullifierHex
            ) else {
                UserStorage.eraceActiveUserId()
                
                return
            }
            
            self.user = user
            self.identityManager = identityManager
        }
        
        func isUpdateAvailable() async throws -> Bool {
            guard
                let info = Bundle.main.infoDictionary,
                let currentVersion = info["CFBundleShortVersionString"] as? String,
                let identifier = info["CFBundleIdentifier"] as? String
            else {
                throw "Invalid bundle info"
            }
            
            let response = try await AF.request("https://itunes.apple.com/lookup?bundleId=\(identifier)")
                .serializingDecodable(ITunesLookupResponse.self)
                .result
                .get()            
            
            guard let firstResult = response.results.first else {
                throw "response are empty"
            }
                
            return firstResult.version != currentVersion
        }
        
        func loadUser(userId: String) throws {
            let user = try UserStorage.getUserByID(id: userId)
            let identityManager = try? IdentityManager(
                secretKeyHex: user.secretKeyHex,
                secretHex: user.secretHex,
                nullifierHex: user.nullifierHex
            )
            
            UserStorage.setActiveUserId(id: userId)
            
            self.user = user
            self.identityManager = identityManager
        }
        
        func eraceUser() throws {
            guard let userId = user?.id else {
                throw "failed to get user id"
            }
            
            UserStorage.eraceActiveUserId()
            try UserStorage.eraceUser(id: userId)
        }
        
        func newUser(_ model: NFCPassportModel) async throws {
            let newIdentityManager = try IdentityManager()
            
            let issueResponse = try await newIdentityManager.issueIdentity(model)
            let newUser = UserStorage.User(
                id: try model.getIdentidier(),
                issuingAuthority: model.issuingAuthority,
                isAdult: true,
                claimId: issueResponse.data.attributes.claimID,
                issuerDid: issueResponse.data.attributes.issuerDid,
                secretKeyHex: newIdentityManager.identity.getSecretKeyHex(),
                secretHex: newIdentityManager.identity.getSecretHex(),
                nullifierHex: newIdentityManager.identity.getNullifierHex(),
                creationTimestamp: Int64(Date().timeIntervalSince1970),
                requestedIn: []
            )
            
            UserStorage.setActiveUserId(id: newUser.id)
            try UserStorage.setUser(user: newUser)
            
            await MainActor.run {
                self.user = newUser
                self.identityManager = newIdentityManager
            }
        }
        
        func updateUserIdentity(model: NFCPassportModel) async throws {
            guard
                let identityManager = self.identityManager,
                var updatedUser = self.user
            else {
                throw "identity manager/user is not initialized"
            }
            
            let issueResponse = try await identityManager.issueIdentity(model)
            
            updatedUser.claimId = issueResponse.data.attributes.claimID
            updatedUser.issuerDid = issueResponse.data.attributes.issuerDid
            
            UserStorage.setActiveUserId(id: updatedUser.id)
            try UserStorage.setUser(user: updatedUser)
            
            let blockedUser = updatedUser
            
            await MainActor.run {
                self.user = blockedUser
                self.identityManager = identityManager
            }
        }
        
        func updateUser(_ user: UserStorage.User) throws {
            try UserStorage.setUser(user: user)
            UserStorage.setActiveUserId(id: user.id)
            
            self.user = user
        }
        
        func isUserFinalized() throws -> Bool {
            guard let user = self.user else {
                throw "user does not exist"
            }
            
            guard let identityManager = self.identityManager else {
                throw "user does not have identity"
            }
            
            let rarimoCoreURL = try IdentityManager.getRarimoCoreURL()
            
            var isFinalized: ObjCBool = false
            try identityManager.identity.isFinalized(
                rarimoCoreURL,
                issuerDid: user.issuerDid,
                creationTimestamp: user.creationTimestamp,
                ret0_: &isFinalized
            )
            
            return isFinalized.boolValue
        }
        
        func isUserRegistered(address: String) async throws -> Bool {
            let evmRPC = Bundle.main.object(forInfoDictionaryKey: "EVMRPC") as! String
            
            let web3 = Web3(rpcURL: evmRPC)
            
            let registrationJson = NSDataAsset(name: "Registration.json")!.data
            
            let contractAddress = try EthereumAddress(hex: address, eip55: false)
            
            let registrationContract = try web3.eth.Contract(json: registrationJson, abiKey: nil, address: contractAddress)
            
            guard let identityManager = identityManager else {
                throw "user does not have identity"
            }
            
            guard let commitment = identityManager.identity.getCommitment() else {
                throw "user commitment does not exist"
            }
            
            let commitmentsMethod = registrationContract["commitments"]!
            
            let result = try commitmentsMethod(commitment).call().wait()
            
            guard let resultValue = result[""] else {
                throw "unable to get result value"
            }
            
            guard let isRegistered = resultValue as? Bool else {
                throw "resultValue is not Int"
            }
            
            return isRegistered
        }
        
        func register(address: String) async throws -> String {
            guard let identityManager = identityManager else {
                throw "identity manager is not initialized"
            }
            
            guard let user = user else {
                throw "user is not initialized"
            }
            
            let claimOffer = try! await IssuerConnector.claimOffer(
                issuerDid: user.issuerDid,
                claimId: user.claimId
            )
            
            let claimOfferData = try! JSONEncoder().encode(claimOffer)
            
            try identityManager.identity.initVerifiableCredentials(claimOfferData)
            
            let calldata = try await identityManager.register(
                issuerDid: user.issuerDid,
                votingAddress: address,
                issuingAuthorityCode: user.getIssuingAuthorityCode()
            )
            
            return calldata
        }
        
        func switchLocalization() {
            switch self.localization {
            case "ru":
                self.localization = "en"
            case "en":
                self.localization = "ru"
            default:
                self.localization = "ru"
            }
        }
        
        func finishIntro() {
            StorageUtils.setIsIntroFinished(true)
            isIntroFinished = true
        }
    }
}
