// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Desktopie",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Desktopie",
            targets: ["Desktopie"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Desktopie",
            dependencies: [],
            path: "Sources"
        )
    ]
)
