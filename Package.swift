// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrailBlazer",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TrailBlazer",
            targets: ["TrailBlazer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/ErrNo", from: "0.4.1"),
        .package(url: "https://github.com/Ponyboy47/Cdirent", from: "0.1.0"),
        .package(url: "https://github.com/Ponyboy47/Cglob", from: "0.1.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "4.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TrailBlazer",
            dependencies: ["ErrNo", "Cdirent", "Cglob"],
            exclude: ["Utilities/Autoclose"]),
        .testTarget(
            name: "TrailBlazerTests",
            dependencies: ["TrailBlazer", "SwiftShell"]),
    ]
)
