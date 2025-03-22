// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "unpluggedCS",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "unpluggedCS",
            targets: ["unpluggedCS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "unpluggedCS",
            dependencies: [
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI")
            ],
            path: "unpluggedCS"),
        .testTarget(
            name: "unpluggedCSTests",
            dependencies: ["unpluggedCS"],
            path: "unpluggedCSTests"),
        .testTarget(
            name: "unpluggedCSUITests",
            dependencies: ["unpluggedCS"],
            path: "unpluggedCSUITests")
    ]
)
