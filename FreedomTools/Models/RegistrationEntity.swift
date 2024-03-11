import Web3
import Web3PromiseKit
import Web3ContractABI
import SwiftUI
import Alamofire

struct RegistrationEntity {
    let address: String
    let info: RegistrationInfo
    let remark: RegistrationRemark
    let issuingAuthorityWhitelist: [BigUInt]
    
    func isEnded() -> Bool {
        return BigUInt(Date().timeIntervalSince1970) > info.values.commitmentEndTime
    }
    
    static func fromRegistryLast() async throws -> Self {
        let evmRPC = Bundle.main.object(forInfoDictionaryKey: "EVMRPC") as! String
        
        let web3 = Web3(rpcURL: evmRPC)
        
        let lastPool = try await Self.getLastRegisryEntity(web3)
        
        let registerVerifier = try await Self.getRegisterVerifier(web3, lastPool: lastPool)
        
        let issuingAuthorityWhitelist = try await Self.getIssuingAuthorityWhitelist(web3, registerVerifier: registerVerifier)
        
        let info = try await Self.getRegistrationInfo(web3, lastPool: lastPool)
        
        let remark = try await RegistrationRemark.fromURL(url: info.remark)
        
        return Self(
            address: lastPool.hex(eip55: false),
            info: info,
            remark: remark,
            issuingAuthorityWhitelist: issuingAuthorityWhitelist
        )
    }
    
    static func getRegisterVerifier(_ web3: Web3, lastPool: EthereumAddress) async throws -> EthereumAddress {
        let registrationJson = NSDataAsset(name: "Registration.json")!.data
        
        let registrationContract = try web3.eth.Contract(json: registrationJson, abiKey: nil, address: lastPool)
        
        let registerVerifierMethod = registrationContract["registerVerifier"]!
        
        let result = try registerVerifierMethod().call().wait()
        
        guard let resultValue = result[""] else {
            throw "unable to get result value"
        }
        
        guard let registerVerifier = resultValue as? EthereumAddress else {
            throw "resultValue is not EthereumAddress"
        }
        
        return registerVerifier
    }
    
    static func getIssuingAuthorityWhitelist(_ web3: Web3, registerVerifier: EthereumAddress) async throws -> [BigUInt] {
        let registerVerifierJson = NSDataAsset(name: "IRegisterVerifier.json")!.data
        
        let registerVerifierContract = try web3.eth.Contract(
            json: registerVerifierJson,
            abiKey: nil,
            address: registerVerifier
        )
        
        let countIssuingAuthorityWhitelist = try await Self.countIssuingAuthorityWhitelist(registerVerifierContract)
        if countIssuingAuthorityWhitelist == 0 {
            return []
        }
        
        let listIssuingAuthorityWhitelist = try await Self.listIssuingAuthorityWhitelist(
            registerVerifierContract,
            offset: 0,
            limit: countIssuingAuthorityWhitelist
        )
        
        return listIssuingAuthorityWhitelist
    }
    
    static func countIssuingAuthorityWhitelist(
        _ contract: DynamicContract
    ) async throws -> BigUInt {
        let countIssuingAuthorityWhitelistMethod = contract["countIssuingAuthorityWhitelist"]!
        
        let result = try countIssuingAuthorityWhitelistMethod().call().wait()
        
        guard let resultValue = result[""] else {
            throw "unable to get result value"
        }
        
        guard let countIssuingAuthorityWhitelist = resultValue as? BigUInt else {
            throw "resultValue is not Int"
        }
        
        return countIssuingAuthorityWhitelist
    }
    
    static func listIssuingAuthorityWhitelist(
        _ contract: DynamicContract,
        offset: BigUInt,
        limit: BigUInt
    ) async throws -> [BigUInt] {
        let listIssuingAuthorityWhitelistMethod = contract["listIssuingAuthorityWhitelist"]!
        
        let result = try listIssuingAuthorityWhitelistMethod(offset, limit).call().wait()
        
        guard let resultValue = result[""] else {
            throw "unable to get result value"
        }
        
        guard let listIssuingAuthorityWhitelist = resultValue as? [BigUInt] else {
            throw "resultValue is not [Int]"
        }
        
        return listIssuingAuthorityWhitelist
    }
    
    static func getRegistrationInfo(_ web3: Web3, lastPool: EthereumAddress) async throws -> RegistrationInfo {
        let registrationJson = NSDataAsset(name: "Registration.json")!.data
        
        let registrationContract = try web3.eth.Contract(json: registrationJson, abiKey: nil, address: lastPool)
        
        let getRegistrationInfoMethod = registrationContract["getRegistrationInfo"]!
        
        let result = try getRegistrationInfoMethod().call().wait()
        
        return try RegistrationInfo(result)
    }
    
    static func getLastRegisryEntity(_ web3: Web3) async throws -> EthereumAddress {
        let votingRegistryAddressStr = Bundle.main.object(forInfoDictionaryKey: "VotingRegistryAddress") as! String
        let votingRegistryJson = NSDataAsset(name: "VotingRegistry.json")!.data
        let registryPollType = Bundle.main.object(forInfoDictionaryKey: "RegistryPollType") as! String
        let votingProposer = Bundle.main.object(forInfoDictionaryKey: "VotingProposer") as! String
        
        let votingProposerAddress = try EthereumAddress(hex: votingProposer, eip55: false)
        let votingRegistryAddress = try EthereumAddress(hex: votingRegistryAddressStr, eip55: false)
        let votingRegistryContract = try web3.eth.Contract(json: votingRegistryJson, abiKey: nil, address: votingRegistryAddress)
        
        let poolCount = try await Self.poolCountByProposerAndType(
            votingRegistryContract,
            proposer: votingProposerAddress,
            type: registryPollType
        )
        
        return try await Self.lastPoolByProposerAndType(
            votingRegistryContract,
            proposer: votingProposerAddress,
            type: registryPollType,
            poolCount: poolCount
        )
    }
    
    static func poolCountByProposerAndType(
        _ contract: DynamicContract,
        proposer: EthereumAddress,
        type: String
    ) async throws -> BigUInt {
        let poolCountByProposerAndTypeMethod = contract["poolCountByProposerAndType"]!
        
        let result = try poolCountByProposerAndTypeMethod(proposer, type).call().wait()
        guard let resultValue = result[""] else {
            throw "unable to get result value"
        }
        
        guard let poolCount = resultValue as? BigUInt else {
            throw "resultValue is not Int"
        }
    
        return poolCount
    }
    
    static func lastPoolByProposerAndType(
        _ contract: DynamicContract,
        proposer: EthereumAddress,
        type: String,
        poolCount: BigUInt
    ) async throws -> EthereumAddress {
        let listPoolsByProposerAndTypeMethod = contract["listPoolsByProposerAndType"]!
        
        let result = try listPoolsByProposerAndTypeMethod(proposer, type, poolCount-2, 1).call().wait()
        guard let resultValue = result["pools_"] else {
            throw "unable to get result value"
        }
        
        guard let polls = resultValue as? [EthereumAddress] else {
            throw "resultValue is not [EthereumAddress]"
        }
        
        if polls.isEmpty {
            throw "No registration entities exist"
        }
        
        return polls.last!
    }
    
    static let sample = Self(
        address: "0x0000000000000000000000000000000000000000",
        info: RegistrationInfo(
            counters: RegistrationInfoCounters(totalRegistrations: 500),
            remark: "https://example.com",
            values: RegistrationInfoValues(
                commitmentStartTime: BigUInt(1709230004),
                commitmentEndTime: BigUInt(1711728404)
            )
        ),
        remark: RegistrationRemark(
            chainID: "1",
            contractAddress: "0x0000000000000000000000000000000000000000",
            name: "Cool Poll",
            description: "Some cool description",
            excerpt: "Short description",
            externalURL: "https://example.com",
            isActive: nil
        ),
        issuingAuthorityWhitelist: ["4903594"]
    )
}

struct RegistrationRemark: Codable {
    let chainID, contractAddress, name, description: String
    let excerpt: String
    let externalURL: String
    let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case chainID = "chain_id"
        case contractAddress = "contract_address"
        case name, description, excerpt
        case externalURL = "external_url"
        case isActive
    }
    
    static func fromURL(url: String) async throws -> Self {
        return try await AF.request(url)
            .serializingDecodable(Self.self)
            .result
            .get()
    }
}

struct RegistrationInfo {
    let counters: RegistrationInfoCounters
    let remark: String
    let values: RegistrationInfoValues
    
    
    init(counters: RegistrationInfoCounters, remark: String, values: RegistrationInfoValues) {
        self.counters = counters
        self.remark = remark
        self.values = values
    }
    
    init(_ rawData: [String: Any]) throws {
        guard let data = rawData[""] as? [String: Any] else {
            throw "unable to get data"
        }
        
        guard let counters = data["counters"] as? [String: Any] else {
            throw "unable to get counters"
        }
        
        guard let totalRegistrations = counters["totalRegistrations"] as? BigUInt else {
            throw "unable to get totalRegistration"
        }
        
        guard let remark = data["remark"] as? String else {
            throw "unable to get remark"
        }
        
        guard let values = data["values"] as? [String: Any] else {
            throw "unable to get values"
        }
        
        guard let commitmentStartTime = values["commitmentStartTime"] as? BigUInt else {
            throw "unable to get commitmentStartTime"
        }
        
        guard let commitmentEndTime = values["commitmentEndTime"] as? BigUInt else {
            throw "unable to get commitmentEndTime"
        }
        
        self.counters = RegistrationInfoCounters(totalRegistrations: totalRegistrations)
        self.remark = remark
        self.values = RegistrationInfoValues(commitmentStartTime: commitmentStartTime, commitmentEndTime: commitmentEndTime)
    }
}

struct RegistrationInfoCounters {
    let totalRegistrations: BigUInt
}

struct RegistrationInfoValues {
    let commitmentStartTime: BigUInt
    let commitmentEndTime: BigUInt
}
