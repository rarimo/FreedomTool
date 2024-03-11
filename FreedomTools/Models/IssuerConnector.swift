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
    static func claimOffer(issuerDid: String, claimId: String) async throws -> ClaimOfferResponse {
        guard var apiRarimoURL = Bundle.main.object(forInfoDictionaryKey: "ApiRarimoURL") as? String else {
            throw "IssuerNodeURL is not set"
        }
        
        apiRarimoURL += "/v1/\(issuerDid)/claims/\(claimId)/offer"
        
        print(apiRarimoURL)
        
        let response = await AF.request(apiRarimoURL, method: .get)
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
