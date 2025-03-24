// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "DogTrainingNotifier",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DogTrainingNotifier",
            targets: ["DogTrainingNotifier"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1"),
    ],
    targets: [
        .target(
            name: "DogTrainingNotifier",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "DogTrainingNotifierTests",
            dependencies: ["DogTrainingNotifier"]),
    ]
)
