// swift-tools-version: 5.7

import Foundation
import PackageDescription

// MARK: - Shared
var package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "Models", targets: ["Models"]),
    .library(name: "SiteRouter", targets: ["SiteRouter"]),
    .library(name: "ValidationMiddleware", targets: ["ValidationMiddleware"]),
    .library(name: "ValidationMiddlewareLive", targets: ["ValidationMiddlewareLive"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      from: "0.8.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "0.6.1"
    ),
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
      name: "SiteRouter",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
    .testTarget(
      name: "SiteRouterTests",
      dependencies: [
        "SiteRouter",
        "FirstPartyMocks",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "ValidationMiddleware",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Validations", package: "swift-validations"),
      ]
    ),
    .target(
      name: "ValidationMiddlewareLive",
      dependencies: [
        "ValidationMiddleware"
      ]
    ),
    .testTarget(
      name: "ValidationMiddlewareTests",
      dependencies: [
        "ValidationMiddlewareLive",
        "FirstPartyMocks",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "FirstPartyMocks",
      dependencies: [
        "Models"
      ]
    ),

  ]
)

// MARK: - Server
package.dependencies.append(contentsOf: [
  .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
  .package(url: "https://github.com/pointfreeco/vapor-routing.git", from: "0.1.0"),
  .package(url: "https://github.com/pointfreeco/swift-html-vapor.git", from: "0.4.0"),
  .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
])

package.targets.append(contentsOf: [
  .target(
    name: "ApiRouteMiddleware",
    dependencies: [
      "Models",
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
    ]
  ),
  .target(
    name: "ApiRouteMiddlewareLive",
    dependencies: [
      "ApiRouteMiddleware"
    ]
  ),
  .testTarget(
    name: "ApiRouteMiddlewareTests",
    dependencies: [
      "ApiRouteMiddlewareLive",
      "FirstPartyMocks",
      .product(name: "CustomDump", package: "swift-custom-dump"),
    ]
  ),
  .target(
    name: "DocumentMiddleware",
    dependencies: [
      "Models",
      "SiteRouter",
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "HtmlVaporSupport", package: "swift-html-vapor"),
    ]
  ),
  .target(
    name: "LoggingDependency",
    dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "Logging", package: "swift-log"),
    ]
  ),
  .executableTarget(
    name: "server",
    dependencies: ["ServerConfig"]
  ),
  .target(
    name: "ServerConfig",
    dependencies: [
      "ApiRouteMiddlewareLive",
      "LoggingDependency",
      "Models",
      "SiteMiddleware",
      "SiteRouter",
      "ValidationMiddlewareLive",
      .product(name: "Vapor", package: "vapor"),
      .product(name: "VaporRouting", package: "vapor-routing"),
    ],
    swiftSettings: [
      // Enable better optimizations when building in Release configuration. Despite the use of
      // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
      // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
      .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
    ]
  ),
  .target(
    name: "SiteMiddleware",
    dependencies: [
      "ApiRouteMiddleware",
      "DocumentMiddleware",
      "LoggingDependency",
      "ValidationMiddleware",
    ]
  ),

])
