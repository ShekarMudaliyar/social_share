// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "social_share",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "social-share", targets: ["social_share"])
    ],
    targets: [
        .target(
            name: "social_share"
        )
    ]
)
