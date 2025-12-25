// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TurboList",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TurboList",
            targets: ["TurboList"]
        ),
    ],
    targets: [
        .target(
            name: "TurboList"
        ),
        .testTarget(
            name: "TurboListTests",
            dependencies: ["TurboList"]
        ),
    ]
)
