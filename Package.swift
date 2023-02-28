// swift-tools-version: 5.7

import Foundation
import PackageDescription

// MARK: - Shared
var package = Package(
  name: "swift-manual-s-api",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "AnvilClient", targets: ["AnvilClient"]),
    .library(name: "ConcurrencyHelpers", targets: ["ConcurrencyHelpers"]),
    .library(name: "FirstPartyMocks", targets: ["FirstPartyMocks"]),
    .library(name: "LoggingDependency", targets: ["LoggingDependency"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "SiteRouter", targets: ["SiteRouter"]),
    .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
    .library(name: "ValidationMiddleware", targets: ["ValidationMiddleware"]),
    .library(name: "ValidationMiddlewareLive", targets: ["ValidationMiddlewareLive"]),
    .library(name: "XCTestDebugSupport", targets: ["XCTestDebugSupport"]),
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
    .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
  ],
  targets: [
    .target(
      name: "AnvilClient",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
    .target(name: "ConcurrencyHelpers"),
    .target(
      name: "FirstPartyMocks",
      dependencies: [
        "Models"
      ]
    ),
    .target(
      name: "LoggingDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
      ]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged")
      ]
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
      name: "UserDefaultsClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
      name: "XCTestDebugSupport",
      dependencies: []
    ),
  ]
)

// TODO: Add section for shared information between client and cli.

// MARK: - Client
if ProcessInfo.processInfo.environment["TEST_SERVER"] == nil {
  package.platforms?.append(contentsOf: [
    .iOS(.v13)
  ])
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "0.12.0")
  ])
  package.products.append(contentsOf: [
    .library(name: "ApiClient", targets: ["ApiClient"])
  ])
  package.targets.append(contentsOf: [
    .target(
      name: "ApiClient",
      dependencies: [
        "LoggingDependency",
        "Models",
        "XCTestDebugSupport",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "ApiClientLive",
      dependencies: [
        "ApiClient",
        "ConcurrencyHelpers",
        "Models",
        "SiteRouter",
        "UserDefaultsClient",
      ]
    ),
    .testTarget(
      name: "ApiClientLiveTests",
      dependencies: [
        "ApiClientLive",
        "FirstPartyMocks",
      ]
    ),
  ])
}

// MARK: - CLI
if ProcessInfo.processInfo.environment["TEST_SERVER"] == nil {
  //  package.platforms?.append(contentsOf: [.macOS(.v13)])
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/adorkable/swift-log-format-and-pipe.git", from: "0.1.0"),
  ])
  package.products.append(contentsOf: [
    .executable(name: "equipment-selection", targets: ["equipment-selection"]),
    .library(name: "ClientConfig", targets: ["ClientConfig"]),
    .library(name: "ClientConfigLive", targets: ["ClientConfigLive"]),
    .library(name: "FileClient", targets: ["FileClient"]),
    .library(name: "TemplateClient", targets: ["TemplateClient"]),
    .library(name: "TemplateClientLive", targets: ["TemplateClientLive"]),
  ])
  package.targets.append(contentsOf: [
    .target(
      name: "ClientConfig",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "ClientConfigLive",
      dependencies: [
        "ClientConfig",
        "ConcurrencyHelpers",
        "FileClient",
        "UserDefaultsClient",
      ]
    ),
    .testTarget(
      name: "CliConfigTests",
      dependencies: [
        "ClientConfig",
        "ClientConfigLive",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .executableTarget(
      name: "equipment-selection",
      dependencies: [
        "ApiClientLive",
        "ClientConfigLive",
        "ConcurrencyHelpers",
        "FirstPartyMocks",
        "LoggingDependency",
        "Models",
        "TemplateClientLive",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "LoggingFormatAndPipe", package: "swift-log-format-and-pipe"),
      ]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        "LoggingDependency",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "TemplateClient",
      dependencies: [
        "ConcurrencyHelpers",
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "TemplateClientLive",
      dependencies: [
        "ClientConfig",
        "LoggingDependency",
        "FileClient",
        "FirstPartyMocks",
        "TemplateClient",
        "UserDefaultsClient",
      ]
    ),
    .testTarget(
      name: "TemplateClientTests",
      dependencies: [
        "ClientConfigLive",
        "TemplateClientLive",
      ]
    ),
  ])
}

// MARK: - Server
package.dependencies.append(contentsOf: [
  .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
  .package(url: "https://github.com/pointfreeco/vapor-routing.git", from: "0.1.0"),
  .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.4.0"),
  .package(url: "https://github.com/pointfreeco/swift-html-vapor.git", from: "0.4.0"),
])

package.products.append(contentsOf: [
  .library(name: "ApiRouteMiddleware", targets: ["ApiRouteMiddleware"]),
  .library(name: "ApiRouteMiddlewareLive", targets: ["ApiRouteMiddlewareLive"]),
  .library(name: "DocumentMiddleware", targets: ["DocumentMiddleware"]),
  .library(name: "DocumentMiddlewareLive", targets: ["DocumentMiddlewareLive"]),
  .executable(name: "server", targets: ["server"]),
  .library(name: "ServerConfig", targets: ["ServerConfig"]),
  .library(name: "SiteMiddleware", targets: ["SiteMiddleware"]),
  .library(name: "SiteMiddlewareLive", targets: ["SiteMiddlewareLive"]),
  .library(name: "Stylesheet", targets: ["Stylesheet"]),
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
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "Html", package: "swift-html"),
      .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
    ]
  ),
  .target(
    name: "DocumentMiddlewareLive",
    dependencies: [
      "ApiRouteMiddleware",
      "DocumentMiddleware",
      "FirstPartyMocks",
      "LoggingDependency",
      "Models",
      "SiteRouter",
      "Stylesheet",
      "ValidationMiddlewareLive",
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
      "DocumentMiddlewareLive",
      "LoggingDependency",
      "Models",
      "SiteMiddlewareLive",
      "SiteRouter",
      "ValidationMiddlewareLive",
      .product(name: "HtmlVaporSupport", package: "swift-html-vapor"),
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
      "Models",
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "Html", package: "swift-html"),
      .product(name: "Vapor", package: "vapor"),
    ]
  ),
  .target(
    name: "SiteMiddlewareLive",
    dependencies: [
      "ApiRouteMiddleware",
      "DocumentMiddleware",
      "LoggingDependency",
      "SiteMiddleware",
      "ValidationMiddleware",
      .product(name: "HtmlVaporSupport", package: "swift-html-vapor"),
      .product(name: "Vapor", package: "vapor"),

    ]
  ),
  .target(
    name: "Stylesheet",
    dependencies: [
      .product(name: "HtmlVaporSupport", package: "swift-html-vapor")
    ]
  ),
  .testTarget(
    name: "StylesheetTests",
    dependencies: ["Stylesheet"]
  ),
])
