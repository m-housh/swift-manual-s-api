// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v10_15), .iOS(.v13)],
  products: [
    .library(name: "Models", targets: ["Models"]),
    .library(name: "Router", targets: ["Router"]),
    .library(name: "SiteHandler", targets: ["SiteHandler"]),
    .library(name: "SiteHandlerLive", targets: ["SiteHandlerLive"]),
    .library(name: "SiteRouteValidations", targets: ["SiteRouteValidations"]),
    .library(name: "SiteRouteValidationsLive", targets: ["SiteRouteValidationsLive"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.8.1")),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.6.1")),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.4.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "0.1.0"),
    .package(url: "https://github.com/m-housh/swift-validations.git", from: "0.3.2"),
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
        "TestSupport",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "SiteHandler",
      dependencies: [
        "Models",
        "SiteRouteValidations",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "SiteHandlerLive",
      dependencies: [
        "SiteHandler",
        .product(name: "Validations", package: "swift-validations"),
      ]
    ),
    .testTarget(
      name: "SiteHandlerTests",
      dependencies: [
        "SiteHandlerLive",
        "SiteRouteValidationsLive",
        "TestSupport",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "SiteRouteValidations",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Validations", package: "swift-validations"),
      ]
    ),
    .target(
      name: "SiteRouteValidationsLive",
      dependencies: [
        "SiteRouteValidations"
      ]
    ),
    .testTarget(
      name: "SiteRouteValidationTests",
      dependencies: [
        "SiteRouteValidationsLive",
        "TestSupport",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "TestSupport",
      dependencies: [
        "Models"
      ]
    ),

  ]
)
