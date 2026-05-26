# QuickHatchCore

`QuickHatchCore` is a reusable, high-performance core engine designed to handle shared business logic across multiple applications. It abstracts common networking, caching, and data delivery patterns behind a standardized, highly testable **DataProvider** pattern using modern Swift concurrency.

---

## 🚀 Key Features

* **Unified Data Pattern**: Standardizes all operations (disk operations, API requests, data mapping) via the `DataProvider` protocol.
* **Built-in Thread Safety**: Completely data-race free, leveraging Swift 6 concurrency models (`Sendable`, `async/await`, and `actor` testing suites).
* **Plug-and-Play Extensibility**: Decouples heavy components like image fetching or caching from individual app logic.

---

## 📐 Architecture Overview

Every shared use case inside `QuickHatchCore` is built as a **DataProvider**. A `DataProvider` wraps your dependencies (such as APIs, database wrappers, or caches) and exposes a single execution pipeline:

```swift
public protocol DataProvider<Input, Result>: Sendable {
    associatedtype Input: Sendable
    associatedtype Result: Sendable
    
    func execute(_ input: Input) async throws -> Result
}
```

---

## 📦 Core Components

### 1. Protocols
* **`DataProvider`**: The foundation for all single-responsibility use cases.

### 2. Implementations
* **`FindImageDataProvider`**: A production-ready instance of `FindImageDataProvidable`. It seamlessly coordinates looking up structural assets inside the cache layer before defaulting to a fallback network request.

---

## 🛠 Quick Start

### Fetching an Image (Example Use Case)

Initialize your concrete dependencies and inject them into the required `DataProvider`.

```swift
import QuickHatchCore
import Foundation

// 1. Initialize your custom implementations or mock strategies
let webService = MyImageNetworkService() // Conforms to ImageAPI
let diskCache = MyDiskCacheManager()    // Conforms to Cache

// 2. Build the reusable Data Provider
let imageProvider = FindImageDataProvider(webAPI: webService, cache: diskCache)

// 3. Execute the operation anywhere across your apps
Task {
    do {
        let imageUrl = "https://example.com"
        let imageData = try await imageProvider.execute(imageUrl)
        
        // Use the returned Data to populate your UI components
    } catch {
        print("Failed to resolve image asset: \(error)")
    }
}
```

---

## 🧩 Designing a New Use Case

To extend `QuickHatchCore` with a new reusable feature, adhere to the domain boundary constraints:

1. **Define a context-specific protocol** extending `DataProvider`:
    ```swift
    public protocol FetchUserPreferencesProvidable: DataProvider<String, UserPreferences> {}
    ```
2. **Implement the struct** containing your low-level orchestration logic:
    ```swift
    public struct FetchUserPreferencesProvider: FetchUserPreferencesProvidable {
        public init() {}
        
        public func execute(_ input: String) async throws -> UserPreferences {
            // Your business rules, validation, or persistence mapping here
        }
    }
    ```

---


## 💾 Installation

Add this utility framework to your `Package.swift` file under package dependencies:

```swift
dependencies: [
    .package(url: "https://your-repository.git", from: "1.0.0")
]
```

