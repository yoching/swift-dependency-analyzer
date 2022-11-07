// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "project-analysis-swift",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", branch: "0.50600.1"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-format", branch: "release/5.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "project-analysis-swift",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                .product(name: "Files", package: "Files")
            ]
        ),
        .testTarget(
            name: "project-analysis-swiftTests",
            dependencies: ["project-analysis-swift"]
        ),
    ]
)
