//
//  FindImageDataProviderTests.swift
//  QuickHatchCore
//
//  Created by Daniel Koster on 5/26/26.
//
import Foundation
import Testing
@testable import QuickHatchCore
import PelicanProtocols

@Suite("FindImageDataProvider Tests")
struct FindImageDataProviderTests {
    
    @Test("Returns cached image immediately and skips API call when item is in cache")
    func testExecute_whenImageInCache_returnsCachedData() async throws {
        // Arrange
        let mockAPI = MockImageAPI()
        let mockCache = MockCache()
        let expectedData = "cached_image_data".data(using: .utf8)!
        let targetURL = "https://example.com"
        
        try await mockCache.save(CacheData(content: expectedData, name: targetURL))
        // Reset count after initial setup save
        await { @MainActor in  }()
        
        let sut = FindImageDataProvider(webAPI: mockAPI, cache: mockCache)
        
        // Act
        let result = try await sut.execute(targetURL)
        
        // Assert
        #expect(result == expectedData)
        let apiCount = await mockAPI.getCalledCount
        #expect(apiCount == 0, "API should not be hit if item is cached.")
    }
    
    @Test("Fetches image from API and saves it to cache when cache is empty")
    func testExecute_whenCacheIsEmpty_fetchesFromAPIAndSavesToCache() async throws {
        // Arrange
        let mockAPI = MockImageAPI()
        let mockCache = MockCache()
        let expectedData = "downloaded_image_data".data(using: .utf8)!
        let targetURL = "https://example.com"
        
        await mockAPI.setResult(.success(expectedData))
        let sut = FindImageDataProvider(webAPI: mockAPI, cache: mockCache)
        
        // Act
        let result = try await sut.execute(targetURL)
        
        // Assert
        #expect(result == expectedData)
        
        let apiCount = await mockAPI.getCalledCount
        #expect(apiCount == 1)
        
        let lastURL = await mockAPI.lastRequestedURL
        #expect(lastURL == targetURL)
        
        // Verify it saved to cache
        let saveCount = await mockCache.saveCalledCount
        #expect(saveCount == 1)
        
        let savedData = await mockCache.lastSavedData
        #expect(savedData?.content == expectedData)
        #expect(savedData?.name == targetURL)
    }
    
    @Test("Propagates error up when API call fails")
    func testExecute_whenAPIFails_throwsError() async throws {
        // Arrange
        let mockAPI = MockImageAPI()
        let mockCache = MockCache()
        let expectedError = URLError(.notConnectedToInternet)
        let targetURL = "https://example.com"
        
        await mockAPI.setResult(.failure(expectedError))
        let sut = FindImageDataProvider(webAPI: mockAPI, cache: mockCache)
        
        // Act & Assert
        await #expect(throws: URLError.self) {
            try await sut.execute(targetURL)
        }
        
        // Verify cache save was never called
        let saveCount = await mockCache.saveCalledCount
        #expect(saveCount == 0)
    }
    
    @Test("Propagates error up when cache write fails after API success")
    func testExecute_whenCacheSaveFails_throwsError() async throws {
        // Arrange
        let mockAPI = MockImageAPI()
        let mockCache = MockCache()
        let expectedData = "downloaded_image_data".data(using: .utf8)!
        let targetURL = "https://example.com"
        
        await mockAPI.setResult(.success(expectedData))
        await mockCache.stubError(CacheError.sizeLimit)
        let sut = FindImageDataProvider(webAPI: mockAPI, cache: mockCache)
        
        // Act & Assert
        await #expect(throws: Error.self) {
            try await sut.execute(targetURL)
        }
    }
}

// MARK: - Actor Helpers to satisfy Swift Concurrency in tests
extension MockImageAPI {
    func setResult(_ result: Result<Data, Error>) {
        self.resultToReturn = result
    }
}

