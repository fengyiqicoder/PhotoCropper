// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoCropper",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PhotoCropper",
            targets: ["PhotoCropper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "PhotoCropper",
            dependencies: ["SnapKit"],
            resources: [.copy("PhotoCropper/Sources/PhotoCropper.storyboard")]
            path: "PhotoCropper/Sources")
    ]
)
