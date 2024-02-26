import SwiftUI
import NFCPassportReader

struct TestView: View {
    var nfcScannerController: NFCScannerController
    @State var identityManager: IdentityManager? = nil
    @State var claimId: String? = nil
    @State var IssuerDid: String? = nil
        
    @State private var isOneFinished = false
    @State private var isTwoFinished = false
    @State private var isThreeFinished = false
    @State private var isFourFinished = false
    @State private var isFifthFinished = false
    
    var body: some View {
        HStack {
            Button(action: createIdentity) {
                ZStack {
                    Circle()
                        .foregroundStyle(isOneFinished ? .borderGray : .second)
                    Text("Create Identity")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
            Button(action: createCredential) {
                ZStack {
                    Circle()
                        .foregroundStyle(isTwoFinished ? .borderGray : .second)
                    Text("Create Cred")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
            Button(action: getVSs) {
                ZStack {
                    Circle()
                        .foregroundStyle(isThreeFinished ? .borderGray : .second)
                    Text("Get VCs")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
            Button(action: verify) {
                ZStack {
                    Circle()
                        .foregroundStyle(isFourFinished ? .borderGray : .second)
                    Text("Verify")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
            Button(action: vote) {
                ZStack {
                    Circle()
                        .foregroundStyle(isFifthFinished ? .borderGray : .second)
                    Text("Vote")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
        }
    }
    
    func createIdentity() {
        defer {
            isOneFinished = true
        }
        
        identityManager = try! IdentityManager()
        
        var error: NSError?
        
        print("Identity DID: \(identityManager!.identity.getDID())")
        print("Identity ID: \(identityManager!.identity.getID(&error))")
    }
    
    func createCredential() {
        defer {
            isTwoFinished = true
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            let response = try! await identityManager!.issueIdentity(nfcScannerController.nfcModel!)
            
            claimId = response.data.attributes.claimID
            IssuerDid = response.data.attributes.issuerDid
            
            print("Claim ID: \(response.data.attributes.claimID)")
            print("Issuer DID: \(response.data.attributes.issuerDid)")
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    func getVSs() {
        defer {
            isThreeFinished = true
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            let claimOffer = try! await IssuerConnector.claimOffer(issuerDid: identityManager!.identity.getDID())
            
            let claimOfferData = try! JSONEncoder().encode(claimOffer)
            
            try identityManager!.identity.initVerifiableCredentials(claimOfferData)
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    func verify() {
        defer {
            isFourFinished = true
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                var error: NSError?
                let issuerIDHash = identityManager!.identity.did(toIDHex: IssuerDid!, error: &error)
                if error != nil {
                    fatalError(error!.localizedDescription)
                }
                
                let coreStateHash = try await identityManager!.getCoreStateHash(issuerIdHex: issuerIDHash)
                
                let votingAddress = try IdentityManager.getStringFromInfoPlist(key: "VotingAddress")
                
                let schemaJson = NSDataAsset(name: "VotingCredential.jsonld")!.data
                
                let inputs = try identityManager!.identity.prepareQueryInputs(
                    coreStateHash,
                    votingAddress: votingAddress,
                    schemaJson: schemaJson
                )
                
                print("Inputs: \(String(data: inputs, encoding: .utf8)!)")
                
                let wtns = try ZKUtils.calcWtnscredentialAtomicQueryMTPV2OnChainVoting(inputsJson: inputs)
                
                let (proof, pubSignals) = try ZKUtils.groth16credentialAtomicQueryMTPV2OnChainVoting(wtns: wtns)
                
                print("Proof: \(String(data: proof, encoding: .utf8)!)")
                print("PubSignals: \(String(data: pubSignals, encoding: .utf8)!)")
                
            } catch let error {
                print(error)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    func vote() {
        defer {
            isFifthFinished = true
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        Task {            
            do {
                let votingInputs = try await identityManager!.getVotingInputs(vote: "1")
                
                print("voting inputs: \(String(data: votingInputs, encoding: .utf8)!)")
                
                let wtns = try ZKUtils.calcWtnsvoteSMT(inputsJson: votingInputs)
                
                let (proof, pubSignals) = try ZKUtils.groth16voteSMT(wtns: wtns)
                
                print("Vote proof: \(String(data: proof, encoding: .utf8)!)")
                print("Vote pubSignals: \(String(data: pubSignals, encoding: .utf8)!)")
                
            } catch let error {
                print("vote error: \(error)")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}

#Preview {
    TestView(nfcScannerController: NFCScannerController())
}
