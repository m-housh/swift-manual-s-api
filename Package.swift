// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ManualSClient", targets: ["ManualSClient"]),
    .library(name: "ManualSClientLive", targets: ["ManualSClientLive"]),
    .library(name: "Router", targets: ["Router"]),
    .library(name: "UtilsClient", targets: ["UtilsClient"]),
    .library(name: "UtilsClientLive", targets: ["UtilsClientLive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.8.1")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.6.1")),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.4.0"),
  ],
  targets: [
    .target(
      name: "ManualSClient",
      dependencies: [
        "Models",
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]
    ),
    .target(
      name: "ManualSClientLive",
      dependencies: [
        "ManualSClient",
        "UtilsClient"
      ]
    ),
    .testTarget(
      name: "ManualSClientTests",
      dependencies: [
        "ManualSClientLive",
        "UtilsClientLive",
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .target(
      name: "Models",
      dependencies: []
    ),
    .target(
      name: "Router",
      dependencies: [
        "ManualSClient",
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
    .testTarget(
      name: "RouterTests",
      dependencies: [
        "Router",
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .target(
      name: "UtilsClient",
      dependencies: [
        "Models",
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]
    ),
    .target(
      name: "UtilsClientLive",
      dependencies: [
        "UtilsClient",
      ]
    ),
    .testTarget(
      name: "UtilsClientTests",
      dependencies: [
        "UtilsClientLive",
      ]
    ),
  ]
)
