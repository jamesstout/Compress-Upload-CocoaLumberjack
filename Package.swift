// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Compress-Upload-CocoaLumberjack",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Compress-Upload-CocoaLumberjack",
            targets: ["Compress-Upload-CocoaLumberjack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Compress-Upload-CocoaLumberjack",
            dependencies: ["CocoaLumberjack"],
            path: "/Classes",
            publicHeadersPath: "."),
    ]
)