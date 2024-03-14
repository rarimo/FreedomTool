import Foundation
struct ITunesLookupResponse: Codable {
    let results: [ITunesLookupResponseResult]
}

struct ITunesLookupResponseResult: Codable {
    let version: String
}
