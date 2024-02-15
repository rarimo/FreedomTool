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
    
    var body: some View {
        HStack {
            Button(action: createIdentity) {
                ZStack {
                    Circle()
                        .foregroundStyle(isOneFinished ? .borderGray : .second)
                    Text("Create Identity")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                }
            }
            .frame(width: 75, height: 75)
            .buttonStyle(.plain)
            Button(action: createCredential) {
                ZStack {
                    Circle()
                        .foregroundStyle(isTwoFinished ? .borderGray : .second)
                    Text("Create Credential")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                }
            }
            .frame(width: 75, height: 75)
            .buttonStyle(.plain)
            Button(action: getVSs) {
                ZStack {
                    Circle()
                        .foregroundStyle(isThreeFinished ? .borderGray : .second)
                    Text("Get VSs")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                }
            }
            .frame(width: 75, height: 75)
            .buttonStyle(.plain)
            Button(action: verify) {
                ZStack {
                    Circle()
                        .foregroundStyle(isFourFinished ? .borderGray : .second)
                    Text("Verify")
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                }
            }
            .frame(width: 75, height: 75)
            .buttonStyle(.plain)
        }
    }
    
    func createIdentity() {
        defer {
            isOneFinished = true
        }
        
        identityManager = try! IdentityManager(password: "test")
        
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
            let claimOffer = try! await IssuerConnector.claimOffer(issuerDid: IssuerDid!, claimId: claimId!)
            
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
    }
}

#Preview {
    TestView(nfcScannerController: NFCScannerController())
}
