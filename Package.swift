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
        .library(
            name: "ChronoSystem",
            targets: ["ChronoSystem"]
        ),
        .library(
            name: "ChronoTZ",
            targets: ["ChronoTZ"]
        ),
    ],
    targets: [
        // MARK: - Kit Libraries

        .target(
            name: "ChronoKit",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoMath",
                "ChronoParser",
                "ChronoSystem",
            ],
            path: "Sources/ChronoKit"
        ),
        .target(
            name: "ChronoCore",
            dependencies: ["ChronoMath"],
            path: "Sources/ChronoCore"
        ),
        .target(
            name: "ChronoFormatter",
            dependencies: ["ChronoCore", "ChronoMath"],
            path: "Sources/ChronoFormatter"
        ),
        .target(
            name: "ChronoMath",
            path: "Sources/ChronoMath"
        ),
        .target(
            name: "ChronoParser",
            dependencies: ["ChronoCore", "ChronoMath"],
            path: "Sources/ChronoParser"
        ),
        .target(
            name: "ChronoSystem",
            dependencies: ["ChronoCore"],
            path: "Sources/ChronoSystem"
        ),

        // MARK: - TimeZone Data

        .target(
            name: "ChronoTZ",
            dependencies: [
                "ChronoCore",
                "ChronoMath",
                "ChronoSystem",
            ],
            path: "Sources/ChronoTZ",
            resources: [
                .copy("Resources/iana.tzdb"),
            ]
        ),

        // MARK: - Build-time Tools

        .target(
            name: "ChronoTZGenCore",
            dependencies: ["ChronoSystem", "ChronoTZ"],
            path: "Tools/ChronoTZGenCore"
        ),
        .executableTarget(
            name: "ChronoTZGen",
            dependencies: ["ChronoTZGenCore", "ChronoSystem"],
            path: "Tools/ChronoTZGen"
        ),

        // MARK: - Unit Tests

        .testTarget(
            name: "ChronoCoreTests",
            dependencies: ["ChronoCore"],
            path: "Tests/Unit/ChronoCoreTests"
        ),
        .testTarget(
            name: "ChronoFormatterTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoMath",
                "ChronoSystem",
            ],
            path: "Tests/Unit/ChronoFormatterTests"
        ),
        .testTarget(
            name: "ChronoMathTests",
            dependencies: ["ChronoMath"],
            path: "Tests/Unit/ChronoMathTests"
        ),
        .testTarget(
            name: "ChronoParserTests",
            dependencies: [
                "ChronoCore",
                "ChronoParser",
                "ChronoMath",
            ],
            path: "Tests/Unit/ChronoParserTests"
        ),
        .testTarget(
            name: "ChronoSystemTests",
            dependencies: ["ChronoCore", "ChronoSystem"],
            path: "Tests/Unit/ChronoSystemTests"
        ),
        .testTarget(
            name: "ChronoTZTests",
            dependencies: [
                "ChronoCore",
                "ChronoMath",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Unit/ChronoTZTests"
        ),
        .testTarget(
            name: "ChronoTZGenTests",
            dependencies: [
                "ChronoSystem",
                "ChronoTZ",
                "ChronoTZGenCore",
            ],
            path: "Tests/Unit/ChronoTZGenTests"
        ),

        // MARK: - Integration Tests

        .testTarget(
            name: "ChronoIntegrationTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoMath",
                "ChronoParser",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Integration",
            resources: [
                .process("Resources/iana.tzdb"),
            ]
        ),

        // MARK: - Property Tests

        .testTarget(
            name: "ChronoPropertyTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoMath",
                "ChronoParser",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Property"
        ),
    ]
)

for target in package.targets {
    target.swiftSettings = [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("StrictConcurrency"),
    ]
}
