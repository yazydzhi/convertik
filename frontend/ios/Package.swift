// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Convertik",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Convertik",
            targets: ["Convertik"]
        ),
    ],
    dependencies: [
        // No external dependencies - keeping it lightweight
    ],
    targets: [
        .target(
            name: "Convertik",
            dependencies: []
        ),
        .testTarget(
            name: "ConvertikTests",
            dependencies: ["Convertik"]
        ),
    ]
)