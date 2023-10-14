// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComposableAuthorizationProvider",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v15),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ComposableAuthorizationProvider",
            targets: ["ComposableAuthorizationProvider"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-overture",
            from: "0.5.0"
        ),
    ],
    targets: [
        .target(
            name: "ComposableAuthorizationProvider",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "ComposableAuthorizationProviderTests",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "Overture",
                    package: "swift-overture"
                ),
                "ComposableAuthorizationProvider",
            ]
        ),
    ]
)
