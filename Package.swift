// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AttributeGraph",
    products: [
        .library(name: "AttributeGraph", targets: ["AttributeGraph"]),
    ],
    targets: [
        .target(name: "AttributeGraph"),
        .testTarget(
            name: "AttributeGraphTests",
            dependencies: ["AttributeGraph"]
        ),
    ]
)
