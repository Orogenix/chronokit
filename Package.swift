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
            name: "ChronoFormatter",
            targets: ["ChronoFormatter"]
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
            name: "ChronoFormatter",
            dependencies: ["ChronoCore", "ChronoMath"],
            path: "Sources/ChronoFormatter",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "ChronoKit",
            dependencies: ["ChronoCore", "ChronoFormatter", "ChronoMath", "ChronoParser"],
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
            name: "ChronoFormatterTests",
            dependencies: ["ChronoFormatter"],
            path: "Tests/ChronoFormatterTests"
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
