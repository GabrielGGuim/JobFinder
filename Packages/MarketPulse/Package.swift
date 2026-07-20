// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarketPulse",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MarketPulseModule",
            targets: ["MarketPulseModule"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/Components"),
        .package(path: "../Packages/NetworkLayer")
    ],
    targets: [
        .target(
            name: "MarketPulseModule",
            dependencies: [
                .product(
                    name: "Components",
                    package: "Components"
                ),
                .product(
                    name: "ViewModifiers",
                    package: "Components"
                ),
                .product(
                    name: "Extensions",
                    package: "Components"
                ),
                .product(
                    name: "NetworkLayer",
                    package: "NetworkLayer"
                ),
                .product(
                    name: "FirebaseData",
                    package: "Components"
                )
            ]
        ),
        .testTarget(
            name: "MarketPulseModuleTests",
            dependencies: ["MarketPulseModule"]
        )
    ]
)
