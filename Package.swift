// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PathMan",
    products: [
        .library(
            name: "PathMan",
            targets: ["PathMan"])
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/ErrNo", from: "0.5.1"),
        .package(url: "https://github.com/Ponyboy47/Cdirent", from: "0.1.0"),
        .package(url: "https://github.com/Ponyboy47/Cglob", from: "0.1.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "PathMan",
            dependencies: ["ErrNo", "Cdirent", "Cglob"]),
        .testTarget(
            name: "PathManTests",
            dependencies: ["PathMan", "SwiftShell"])
    ],
    swiftLanguageVersions: [.v5]
)
