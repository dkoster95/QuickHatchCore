//
//  FindImageDataProvider.swift
//  QuickHatchCore
//
//  Created by Daniel Koster on 5/26/26.
//

import Foundation
import os
import PelicanProtocols

public protocol ImageAPI: Sendable {
    func get(url: String) async throws -> Data
}

public protocol DataProvider<Input, Result>: Sendable {
    associatedtype Input: Sendable
    associatedtype Result: Sendable
    func execute(_ input: Input) async throws -> Result
}

public protocol FindImageDataProvidable: DataProvider<String, Data> {}

public struct FindImageDataProvider: FindImageDataProvidable {
    private let webAPI: ImageAPI
    private let cache: Cache
    private let logger = Logger(subsystem: "QuickHatch.Core", category: "FindImageDataProvider")
    
    public init(webAPI: ImageAPI,
                cache: Cache) {
        self.webAPI = webAPI
        self.cache = cache
    }
    
    public func execute(_ input: String) async throws -> Data {
        logger.debug("Checking cache first for image")
        if let cachedImage = await findCache(input: input) {
            logger.debug("Image found in cache!")
            return cachedImage
        }
        do {
            logger.debug("Fetching Image from API")
            let image = try await webAPI.get(url: input)
            try await saveToCache(input: input, data: image)
            return image
        } catch let error {
            logger.error("Error thrown when getting image\(error)")
            throw error
        }
    }
    
    private func findCache(input: String) async -> Data? {
        if let findCacheRecord = await cache.find(input) {
            return findCacheRecord.content
        }
        return nil
    }
    
    private func saveToCache(input: String, data: Data) async throws {
        let cacheData = CacheData(content: data, name: input)
        try await cache.save(cacheData)
        logger.debug("Image saved to cache")
    }
    
    
}
