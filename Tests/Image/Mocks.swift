//
//  Mocks.swift
//  QuickHatchCore
//
//  Created by Daniel Koster on 5/26/26.
//
import Foundation
import Testing
@testable import QuickHatchCore
import PelicanProtocols

public actor MockCache: Cache {
    // MARK: - Stubbed Properties
    private var cachedItems: [String: CacheData] = [:]
    private var errorToThrow: Error? = nil
    
    // MARK: - Tracking Properties (Spies)
    public private(set) var saveCalledCount = 0
    public private(set) var lastSavedData: CacheData? = nil
    
    public private(set) var removeCalledCount = 0
    public private(set) var lastRemovedData: CacheData? = nil
    
    public private(set) var findCalledCount = 0
    public private(set) var lastSearchedName: String? = nil
    
    public private(set) var removeAllCalledCount = 0
    
    public init() {}
    
    // MARK: - Protocol Implementation
    public func save(_ data: CacheData) async throws {
        if let error = errorToThrow { throw error }
        saveCalledCount += 1
        lastSavedData = data
        cachedItems[data.name] = data
    }
    
    public func remove(_ data: CacheData) async throws {
        if let error = errorToThrow { throw error }
        removeCalledCount += 1
        lastRemovedData = data
        cachedItems.removeValue(forKey: data.name)
    }
    
    public func find(_ byName: String) async -> CacheData? {
        findCalledCount += 1
        lastSearchedName = byName
        return cachedItems[byName]
    }
    
    public func removeAll() async throws {
        if let error = errorToThrow { throw error }
        removeAllCalledCount += 1
        cachedItems.removeAll()
    }
    
    // MARK: - Test Configuration Helpers
    /// Pre-populates the mock cache with data for a test scenario
    public func stubCacheItem(_ data: CacheData) {
        cachedItems[data.name] = data
    }
    
    /// Configures the mock to throw a specific error on throwing methods
    public func stubError(_ error: Error?) {
        self.errorToThrow = error
    }
}


public actor MockImageAPI: ImageAPI {
    var resultToReturn: Result<Data, Error> = .failure(URLError(.badURL))
    var getCalledCount = 0
    var lastRequestedURL: String?
    
    public func get(url: String) async throws -> Data {
        getCalledCount += 1
        lastRequestedURL = url
        return try resultToReturn.get()
    }
}
