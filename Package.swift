// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "NucleusUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NucleusUI", targets: ["NucleusUI"]),
    ],
    targets: [
        .target(name: "NucleusUI"),
    ]
)
