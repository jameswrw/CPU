// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "CPU",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CPU",
            targets: ["CPU"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0")
    ],
    targets: [
        .macro(
            name: "CPUMacros",
            dependencies: [
                "CPU",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "CPU",
            swiftSettings: [.unsafeFlags(["-strict-concurrency=complete"])]
        ),
        .testTarget(
            name: "CPUTests",
            dependencies: ["CPU"]
        ),
    ]
)
