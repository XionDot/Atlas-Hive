// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PeakView",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PeakView",
            targets: ["PeakView"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PeakView",
            dependencies: [],
            path: "Sources"
        )
    ]
)
