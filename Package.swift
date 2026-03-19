// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-calc",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "CoreCalculator", targets: ["CoreCalculator"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "ViewModels", targets: ["ViewModels"]),
    ],
    targets: [
        .executableTarget(
            name: "TitleRedactedCalcApp",
            dependencies: ["ViewModels", "CoreCalculator", "Utilities"],
            path: "Sources/swift-calc"
        ),
        .target(
            name: "CoreCalculator",
            dependencies: ["Utilities"]
        ),
        .target(
            name: "Utilities"
        ),
        .target(
            name: "ViewModels",
            dependencies: ["CoreCalculator", "Utilities"]
        ),
        .testTarget(
            name: "CalculatorTests",
            dependencies: ["CoreCalculator", "ViewModels", "Utilities"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
