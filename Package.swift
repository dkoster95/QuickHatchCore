// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickHatchCore",
    platforms: [.iOS(.v17),
                .watchOS(.v7),
                .macOS(.v14),
                .tvOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QuickHatchCore",
            targets: ["QuickHatchCore"]),
    ],
    dependencies: [.package(url: "https://github.com/dkoster95/PelicanSwift.git", from: "3.1.1")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "QuickHatchCore",
            dependencies: [.product(name: "PelicanProtocols", package: "PelicanSwift")]),
        .testTarget(
            name: "QuickHatchCoreTests",
            dependencies: ["QuickHatchCore"]
        ),
    ]
)
