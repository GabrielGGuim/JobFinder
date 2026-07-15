// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]
        ),
        .library(
            name: "ViewModifiers",
            targets: ["ViewModifiers"]
        ),
        .library(
            name: "Extensions",
            targets: ["Extensions"]
        ),
        .library(
            name: "FirebaseData",
            targets: ["FirebaseData"]
        ),
        .library(
            name: "Settings",
            targets: ["Settings"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.29.0")
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                "ViewModifiers"
            ]
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]
        ),
        .target(
            name: "ViewModifiers",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ViewModifiersTests",
            dependencies: ["ViewModifiers"]
        ),
        .target(
            name: "Extensions"
        ),
        
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]
        ),
        .target(
            name: "FirebaseData",
            dependencies: [
                .product(
                    name: "FirebaseFirestore",
                    package: "firebase-ios-sdk"
                ),
                "Settings"
            ]
        ),
        .target(
            name: "Settings"
        )
    ]
)
