// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Atlas",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Atlas",
            targets: ["Atlas"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Atlas",
            dependencies: [],
            path: "Sources"
        )
    ]
)
