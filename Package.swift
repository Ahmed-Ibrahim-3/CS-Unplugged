// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "unpluggedCS",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v11) 
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
            path: "unpluggedCS",
            exclude: ["Info.plist"]),
            
        .testTarget(
            name: "unpluggedCSTests",
            dependencies: ["unpluggedCS"],
            path: "unpluggedCSTests",
            exclude: ["Info.plist"]),
            
        .testTarget(
            name: "unpluggedCSUITests",
            dependencies: ["unpluggedCS"],
            path: "unpluggedCSUITests",
            exclude: ["Info.plist"])
    ]
)
