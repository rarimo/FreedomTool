import Foundation
import Alamofire

struct CredentialRequest: Codable {
    let description: String
    let id: String
}

struct CredentialsRequestBody: Codable {
    let Credentials: [CredentialRequest]
    let url: String
}

struct ClaimOfferResponse: Codable {
    let id: String
    let typ: String
    let type: String
    let threadID: String
    let body: Data
    let from: String
    let to: String
}

class IssuerConnector {
    static func claimOffer(issuerDid: String, claimId: String) async throws -> ClaimOfferResponse {
        var issuerNodeURL = Bundle.main.object(forInfoDictionaryKey: "IssuerNodeURL")! as! String
        
        issuerNodeURL += String(format: "/v1/{}/claims/{}/offer", arguments: [issuerDid, claimId])
        
        let response = await AF.request(issuerNodeURL, method: .get)
            .serializingDecodable(ClaimOfferResponse.self)
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
}
