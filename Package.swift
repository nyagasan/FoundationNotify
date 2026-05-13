// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FoundationNotify",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "SmartNotifications",
            targets: ["SmartNotifications"]
        )
    ],
    targets: [
        .target(
            name: "SmartNotifications"
        ),
        .testTarget(
            name: "SmartNotificationsTests",
            dependencies: ["SmartNotifications"]
        )
    ]
)
