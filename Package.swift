// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(name: "Models", targets: ["Models"]),
    .library(name: "Router", targets: ["Router"]),
    .library(name: "SiteHandler", targets: ["SiteHandler"]),
    .library(name: "SiteHandlerLive", targets: ["SiteHandlerLive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.8.1")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.6.1")),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.4.0"),
  ],
  targets: [
    .target(
      name: "Models",
      dependencies: []
    ),
    .target(
      name: "Router",
      dependencies: [
        "Models",
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
      name: "SiteHandler",
      dependencies: [
        "Models",
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]
    ),
    .target(
      name: "SiteHandlerLive",
      dependencies: [
        "SiteHandler",
      ]
    ),
    .testTarget(
      name: "SiteHandlerTests",
      dependencies: [
        "SiteHandlerLive",
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
  ]
)
