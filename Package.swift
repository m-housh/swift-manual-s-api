// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-manual-s-api",
  products: [
    .library(name: "swift-manual-s-api", targets: ["swift-manual-s-api"]),
  ],
  dependencies: [
  ],
  targets: [
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
