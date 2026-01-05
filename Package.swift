// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "chronokit",
    products: [
        .library(
            name: "ChronoCore",
            targets: ["ChronoCore"]
        ),
        .library(
            name: "ChronoFormat",
            targets: ["ChronoFormat"]
        ),
    ],
    targets: [
        .target(
            name: "ChronoCore",
            dependencies: ["ChronoMath"],
            path: "Sources/ChronoCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "ChronoFormat",
            dependencies: ["ChronoCore", "ChronoMath"],
            path: "Sources/ChronoFormat",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "ChronoMath",
            path: "Sources/ChronoMath",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "ChronoCoreTests",
            dependencies: ["ChronoCore"],
            path: "Tests/ChronoCoreTests"
        ),
        .testTarget(
            name: "ChronoFormatTests",
            dependencies: ["ChronoFormat"],
            path: "Tests/ChronoFormatTests"
        ),
        .testTarget(
            name: "ChronoMathTests",
            dependencies: ["ChronoMath"],
            path: "Tests/ChronoMathTests"
        ),
    ]
)
