// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PathMan",
    products: [
        .library(
            name: "Pathman",
            targets: ["Pathman"])
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/ErrNo", from: "0.5.1"),
        .package(url: "https://github.com/Ponyboy47/Cdirent", from: "0.1.0"),
        .package(url: "https://github.com/Ponyboy47/Cglob", from: "0.1.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.1")
    ],
    targets: [
        .target(
            name: "Pathman",
            dependencies: ["ErrNo", "Cdirent", "Cglob"]),
        .testTarget(
            name: "PathmanTests",
            dependencies: ["Pathman", "SwiftShell"])
    ],
    swiftLanguageVersions: [.v5]
)
