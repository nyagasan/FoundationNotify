// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FoundationNotify",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "SmartNotifications",
            targets: ["SmartNotifications"]
        )
    ],
    targets: [
        .target(
            name: "SmartNotifications",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SmartNotificationsTests",
            dependencies: ["SmartNotifications"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
