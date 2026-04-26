import Benchmark
import ChronoKit
import Foundation

let benchmarks: @Sendable () -> Void = {
    // Setup shared test data
    let date = PlainDate(year: 2025, month: 12, day: 31)!
    let time = PlainTime(hour: 23, minute: 59, second: 58, nanosecond: 123_456_789)!
    let dt = PlainDateTime(date: date, time: time)

    // Setup Foundation comparison
    let foundationDate = Date()
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

    // --- GROUP 1: String Serialization ---

    Benchmark("ChronoKit: PlainDateTime.description") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(dt.description)
        }
    }

    Benchmark("Foundation: ISO8601DateFormatter.string") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(isoFormatter.string(from: foundationDate))
        }
    }

    // --- GROUP 2: Zero-Allocation Buffer Writing ---
    // This simulates writing directly into a network packet buffer.

    Benchmark("ChronoKit: Write to Raw Buffer (Zero-Alloc)") { benchmark in
        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            let written = dt.rfc3339()
            blackHole(written)
        }
        benchmark.stopMeasurement()
    }

    // --- GROUP 3: Decomposition Logic ---
    // SQL drivers often need just the integers (Year, Month, Day) to pack into binary packets.

    Benchmark("ChronoKit: Component Extraction (Y/M/D)") { benchmark in
        for _ in benchmark.scaledIterations {
            let y = date.year
            let m = date.month
            let d = date.day
            blackHole(y)
            blackHole(m)
            blackHole(d)
        }
    }
}
