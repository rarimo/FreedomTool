//
//  LockStatus.swift
//  FreedomTools
//
//  Created by Ivan Lele on 14.03.2024.
//

import Foundation

class LockStatus: ObservableObject {
    static let MAX_FAILED_ATTEMPS = 3
    static let BLOCK_TIME = 60 * 5 // 5 minutes
    
    var failedAttempts: Int = 0
    var lastFailedAttemptTimestamp: Int = 0
    @Published var blockTo: Int = 0
    
    var isBlocked: Bool {
        return Int(Date().timeIntervalSince1970) < blockTo
    }
    
    init() {}
    
    init(failedAttempts: Int, lastFailedAttemptTimestamp: Int, blockTo: Int) {
        self.failedAttempts = failedAttempts
        self.lastFailedAttemptTimestamp = lastFailedAttemptTimestamp
        self.blockTo = blockTo
    }
    
    func recordFailedAttempt() {
        let timeNow = Int(Date().timeIntervalSince1970)
        
        if self.isBlocked {
            return
        }
        
        if self.lastFailedAttemptTimestamp != 0 && self.lastFailedAttemptTimestamp + Self.BLOCK_TIME < timeNow  {
            self.lastFailedAttemptTimestamp = 0
            self.failedAttempts = 1
            self.store()
            
            return
        }
        
        self.failedAttempts += 1
        
        if self.failedAttempts >= Self.MAX_FAILED_ATTEMPS {
            self.blockTo = timeNow + Self.BLOCK_TIME
            self.failedAttempts = 0
            self.lastFailedAttemptTimestamp = 0
        }
        
        self.lastFailedAttemptTimestamp = timeNow
        self.store()
    }
    
    func unblock() {
        if self.isBlocked {
            return
        }
        
        self.failedAttempts = 0
        self.lastFailedAttemptTimestamp = 0
        self.blockTo = 0
        
        self.store()
    }
}

extension LockStatus {
    static let STORING_KEY = "org.freedomtool.lock_status"
    
    struct Storable: Codable {
        let failedAttempts: Int
        let lastFailedAttemptTimestamp: Int
        let blockTo: Int
    }
    
    var storable: Storable {
        return Storable(
            failedAttempts: self.failedAttempts,
            lastFailedAttemptTimestamp: self.lastFailedAttemptTimestamp,
            blockTo: self.blockTo
        )
    }
    
    static func load() -> LockStatus {
        guard let storableJson = UserDefaults.standard.data(forKey: Self.STORING_KEY) else {
            return LockStatus()
        }
        
        guard let storable = try? JSONDecoder().decode(Storable.self, from: storableJson) else {
            return LockStatus()
        }
        
        return LockStatus(
            failedAttempts: storable.failedAttempts,
            lastFailedAttemptTimestamp: storable.lastFailedAttemptTimestamp,
            blockTo: storable.blockTo
        )
    }
    
    func store() {
        guard let storableJson = try? JSONEncoder().encode(self.storable) else {
            return
        }
        
        UserDefaults.standard.set(storableJson, forKey: Self.STORING_KEY)
    }
}

extension LockStatus {
    static let sample = LockStatus(
        failedAttempts: 0,
        lastFailedAttemptTimestamp: 0,
        blockTo: Int(Date().timeIntervalSince1970) + LockStatus.BLOCK_TIME
    )
}
