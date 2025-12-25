// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TurboList",
    // 添加以下代码来限制平台版本
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TurboList",
            targets: ["TurboList"]
        ),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "TurboList",
            dependencies: []
        ),
        .testTarget(
            name: "TurboListTests",
            dependencies: ["TurboList"]
        ),
    ]
)
