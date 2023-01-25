// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(name: "swift-manual-s-api", targets: ["swift-manual-s-api"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ManaulSClient", targets: ["ManualSClient"]),
    .library(name: "Requests", targets: ["Requests"]),
    .library(name: "Router", targets: ["Router"]),
//    .library(name: "SizingLimitClient", targets: ["SizingLimitClient"]),
//    .library(name: "SizingLimitClientLive", targets: ["SizingLimitClientLive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.8.1")),
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
      name: "Requests",
      dependencies: ["Models"]
    ),
    .target(
      name: "Router",
      dependencies: []
    ),
//    .target(
//      name: "SizingLimitClient",
//      dependencies: [
//        "Models",
//        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
//      ]
//    ),
//    .target(
//      name: "SizingLimitClientLive",
//      dependencies: [
//        "SizingLimitClient"
//      ]
//    ),
    .testTarget(
      name: "ManualSClientTests",
      dependencies: [
        "ManualSClientLive"
      ]
    ),
    .target(
      name: "swift-manual-s-api",
      dependencies: []
    ),
    .testTarget(
      name: "swift-manual-s-apiTests",
      dependencies: ["swift-manual-s-api"]
    ),
  ]
)
