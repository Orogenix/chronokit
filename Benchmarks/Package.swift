// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.22.0"),
    ],
    targets: [
        .executableTarget(
            name: "ChronoBench",
            dependencies: [
                .product(name: "ChronoKit", package: "ChronoKit"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Sources",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ],
        ),
    ],
)
