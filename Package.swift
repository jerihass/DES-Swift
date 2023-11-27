// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "des",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "Swift DES",
            targets: ["Swift DES"]),
        .library(
            name: "des",
            targets: ["des"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "des"),
        .executableTarget(
            name: "Swift DES",
        dependencies: ["des"]),
        .testTarget(
            name: "desTests",
            dependencies: ["des"]),
    ]
)
