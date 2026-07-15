// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReduxCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ReduxCore",
            targets: ["ReduxCore"]
        )
    ],
    targets: [
        .target(
            name: "ReduxCore"
        ),
        .testTarget(
            name: "ReduxCoreTests",
            dependencies: ["ReduxCore"]
        )
    ]
)
