// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VYRIS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VYRIS",
            targets: ["VYRIS"]
        )
    ],
    targets: [
        .target(
            name: "VYRIS",
            path: "VYRIS",
            resources: [
                .process("Resources"),
                .process("Localization")
            ]
        )
    ]
)
