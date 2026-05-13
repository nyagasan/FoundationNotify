// swift-tools-version: 6.2

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
            name: "FoundationNotify",
            targets: ["FoundationNotify"]
        )
    ],
    targets: [
        .target(
            name: "FoundationNotify",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "FoundationNotifyTests",
            dependencies: ["FoundationNotify"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
