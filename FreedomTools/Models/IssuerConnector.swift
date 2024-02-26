import Foundation
import Alamofire

// MARK: - ClaimOfferResponse
struct ClaimOfferResponse: Codable {
    let body: ClaimOfferResponseBody
    let from, id, threadID, to: String
    let typ: String
    let type: String
}

// MARK: - Body
struct ClaimOfferResponseBody: Codable {
    let credentials: [Credential]
    let url: String

    enum CodingKeys: String, CodingKey {
        case credentials = "Credentials"
        case url
    }
}

// MARK: - Credential
struct Credential: Codable {
    let description, id: String
}

class IssuerConnector {
    static func claimOffer(issuerDid: String) async throws -> ClaimOfferResponse {
        guard let votingCredentialType = Bundle.main.object(forInfoDictionaryKey: "VotingCredentialType") as? String else {
            throw "VotingCredentialType is not set"
        }
        
        guard var issuerNodeURL = Bundle.main.object(forInfoDictionaryKey: "IssuerNodeURL") as? String else {
            throw "IssuerNodeURL is not set"
        }
                
        issuerNodeURL += "/v1/credentials/\(issuerDid)/\(votingCredentialType)"
        
        let response = await AF.request(issuerNodeURL, method: .get)
            .serializingDecodable(ClaimOfferResponse.self)
            .result
        
        switch response {
        case .success(let response):
            return response
        case .failure(let failure):
            throw failure.localizedDescription
        }
    }
}
