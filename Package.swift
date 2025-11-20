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
        .library(
            name: "CPU",
            targets: ["CPU"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "CPU",
            swiftSettings: [.unsafeFlags(["-strict-concurrency=complete", "-warnings-as-errors"])]
        ),
        .macro(
            name: "CPUMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "CPUMacroDecls",
            dependencies: ["CPUMacros"]
        ),
        .testTarget(
            name: "CPUTests",
            dependencies: ["CPU"], // removed "CPUMacroDecls",
            swiftSettings: [.unsafeFlags(["-strict-concurrency=complete", "-warnings-as-errors"])]
        )
    ]
)
