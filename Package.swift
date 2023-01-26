// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ManaulSClient", targets: ["ManualSClient"]),
    .library(name: "Router", targets: ["Router"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.8.1")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.6.1")),
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
      ]
    ),
    .target(
      name: "Models",
      dependencies: []
    ),
    .target(
      name: "Router",
      dependencies: []
    ),
    .testTarget(
      name: "ManualSClientTests",
      dependencies: [
        "ManualSClientLive",
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),

  ]
)
