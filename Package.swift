// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "chronokit",
    targets: [
        .testTarget(
            name: "ChronoMathTests",
            dependencies: ["ChronoMath"],
            path: "Tests/ChronoMathTests"
        ),
    ]
)
