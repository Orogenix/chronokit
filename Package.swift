// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "chronokit",
    products: [
        .library(
            name: "ChronoKit",
            targets: ["ChronoKit"]
        ),
        .library(
            name: "ChronoCore",
            targets: ["ChronoCore"]
        ),
        .library(
            name: "ChronoFormat",
            targets: ["ChronoFormat"]
        ),
        .library(
            name: "ChronoParser",
            targets: ["ChronoParser"]
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
            name: "ChronoKit",
            dependencies: ["ChronoCore", "ChronoFormat", "ChronoMath", "ChronoParser"],
            path: "Sources/ChronoKit",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "ChronoMath",
            path: "Sources/ChronoMath",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "ChronoParser",
            dependencies: ["ChronoCore", "ChronoMath"],
            path: "Sources/ChronoParser",
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
        .testTarget(
            name: "ChronoParserTests",
            dependencies: ["ChronoParser"],
            path: "Tests/ChronoParserTests"
        ),
    ]
)
