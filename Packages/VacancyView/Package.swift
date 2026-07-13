// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VacancyModule",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "VacancyModule",
            targets: ["VacancyModule"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/Components"),
        .package(path: "../Packages/ReduxCore"),
        .package(path: "../Packages/NetworkLayer")
    ],
    targets: [
        .target(
            name: "VacancyModule",
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
                    name: "ReduxCore",
                    package: "ReduxCore"
                ),
                .product(
                    name: "FirebaseData",
                    package: "Components"
                )
            ]
        ),
        .testTarget(
            name: "VacancyModuleTests",
            dependencies: ["VacancyModule"]
        )
    ]
)
