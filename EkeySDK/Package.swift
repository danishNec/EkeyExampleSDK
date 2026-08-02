// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EkeySDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "EkeySDK", type: .dynamic, targets: ["EkeySDK"])
    ],
    targets: [
        .target(name: "EkeySDK")
    ]
)
