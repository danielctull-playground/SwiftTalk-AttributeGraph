// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "AttributeGraph",
  platforms: [
    .macOS(.v15),
  ],
  products: [
    .library(name: "AttributeGraph", targets: ["AttributeGraph"]),
    .executable(name: "VisualizeGraph", targets: ["VisualizeGraph"]),
  ],
  targets: [
    .target(name: "AttributeGraph"),
    .testTarget(
      name: "AttributeGraphTests",
      dependencies: ["AttributeGraph"]
    ),
    .executableTarget(
      name: "VisualizeGraph",
      dependencies: ["AttributeGraph"]
    ),
  ]
)
