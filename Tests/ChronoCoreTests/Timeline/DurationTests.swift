@testable import ChronoCore
import Testing

@Suite("Duration Tests")
struct DurationTests {
    // MARK: - Initialization & Normalization Tests

    @Test("DurationTests: Basic initialization")
    func basicInit() {
        let duration = Duration(seconds: 10, nanoseconds: 500)
        #expect(duration.seconds == 10)
        #expect(duration.nanoseconds == 500)
    }

    @Test("DurationTests: Normalization of large positive nanoseconds", arguments: [
        (0, 1_000_000_000, 1, 0),
        (5, 1_500_000_000, 6, 500_000_000),
        (0, 2_999_999_999, 2, 999_999_999)
    ])
    func normalizationPositive(s: Int64, n: Int64, expS: Int64, expN: Int32) {
        let duration = Duration(seconds: s, nanoseconds: n)
        #expect(duration.seconds == expS)
        #expect(duration.nanoseconds == expN)
    }

    @Test("DurationTests: Normalization of negative nanoseconds", arguments: [
        (0, -1, -1, 999_999_999),
        (0, -1_000_000_000, -1, 0),
        (0, -1_500_000_000, -2, 500_000_000),
        (10, -1, 9, 999_999_999)
    ])
    func normalizationNegative(s: Int64, n: Int64, expS: Int64, expN: Int32) {
        let duration = Duration(seconds: s, nanoseconds: n)
        #expect(duration.seconds == expS)
        #expect(duration.nanoseconds == expN)
    }

    @Test("DurationTests: Milliseconds to Seconds normalization")
    func milliNormalization() {
        let duration: Duration = .milliseconds(1500)
        #expect(duration.seconds == 1)
        #expect(duration.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Negative nanoseconds normalization")
    func negativeNormalization() {
        // -500ms should be seconds: -1, nanos: 500,000,000
        let duration: Duration = .nanoseconds(-500_000_000)
        #expect(duration.seconds == -1)
        #expect(duration.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Large units")
    func largeUnits() {
        let duration: Duration = .weeks(1)
        #expect(duration.seconds == 604_800)
    }

    @Test("DurationTests: Double conversion")
    func doubleSeconds() {
        let duration: Duration = .seconds(2.5)
        #expect(duration.seconds == 2)
        #expect(duration.nanoseconds == 500_000_000)
    }
}

// MARK: - Timestamp Calculations

extension DurationTests {
    @Test("DurationTests: Total nanoseconds calculation")
    func timestampNanoseconds() {
        let duration = Duration(seconds: 2, nanoseconds: 500)
        // 2 * 1,000,000,000 + 500
        #expect(duration.timestampNanoseconds == 2_000_000_500)

        let negD = Duration(seconds: -1, nanoseconds: 999_999_999) // -1ns total
        #expect(negD.timestampNanoseconds == -1)
    }

    @Test("DurationTests: Checked timestamp overflow")
    func timestampCheckedOverflow() {
        // Near the limit of Int64.max
        // Int64.max is approx 9.22 * 10^18.
        // 10 billion seconds will definitely overflow when converted to nanos.
        let huge = Duration(seconds: 10_000_000_000, nanoseconds: 0)
        #expect(huge.timestampNanosecondsChecked == nil)

        // Valid limit check
        let valid = Duration(seconds: 9, nanoseconds: 0)
        #expect(valid.timestampNanosecondsChecked != nil)
    }

    @Test("DurationTests: Equality and Hashing")
    func equality() {
        let d1 = Duration(seconds: 1, nanoseconds: 500_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 1_500_000_000) // Normalizes to d1
        let d3 = Duration(seconds: 1, nanoseconds: 500_000_001)

        #expect(d1 == d2)
        #expect(d1 != d3)
        #expect(d1.hashValue == d2.hashValue)
    }
}

// MARK: - Comparison Tests

extension DurationTests {
    @Test("DurationTests: Positive durations")
    func positiveComparison() {
        let oneSecond = Duration(seconds: 1, nanoseconds: 0)
        let halfSecond = Duration(seconds: 0, nanoseconds: 500_000_000)
        let oneAndHalf = Duration(seconds: 1, nanoseconds: 500_000_000)

        #expect(halfSecond < oneSecond)
        #expect(oneSecond < oneAndHalf)
        #expect(oneAndHalf > halfSecond)
    }

    @Test("DurationTests: Same seconds, different nanoseconds")
    func sameSecondsComparison() {
        let d1 = Duration(seconds: 5, nanoseconds: 100)
        let d2 = Duration(seconds: 5, nanoseconds: 200)

        #expect(d1 < d2)
        #expect(d2 > d1)
        #expect(!(d1 > d2))
    }

    @Test("DurationTests: Negative durations (normalization check)")
    func negativeComparison() {
        // -1.5 seconds is represented as: seconds -2, nanos 500,000_000
        let minusOnePointFive = Duration(seconds: -1, nanoseconds: -500_000_000)

        // -1.0 seconds is represented as: seconds -1, nanos 0
        let minusOne = Duration(seconds: -1, nanoseconds: 0)

        // -0.5 seconds is represented as: seconds -1, nanos 500,000,000
        let minusPointFive = Duration(seconds: 0, nanoseconds: -500_000_000)

        #expect(minusOnePointFive < minusOne, "-1.5s should be less than -1.0s")
        #expect(minusOne < minusPointFive, "-1.0s should be less than -0.5s")
        #expect(minusPointFive < Duration(seconds: 0, nanoseconds: 0), "-0.5s should be less than zero")
    }

    @Test("DurationTests: Mixed signs")
    func mixedSigns() {
        let neg = Duration(seconds: -1, nanoseconds: 0)
        let zero = Duration(seconds: 0, nanoseconds: 0)
        let pos = Duration(seconds: 1, nanoseconds: 0)

        #expect(neg < zero)
        #expect(zero < pos)
        #expect(neg < pos)
    }

    @Test("DurationTests: Normalized equality")
    func normalizedEquality() {
        // 0s 1500ms vs 1s 500ms
        let d1 = Duration(seconds: 0, nanoseconds: 1_500_000_000)
        let d2 = Duration(seconds: 1, nanoseconds: 500_000_000)

        #expect(!(d1 < d2))
        #expect(!(d2 < d1))
        #expect(d1 <= d2)
        #expect(d1 >= d2)
    }

    @Test("DurationTests: Collection ordering")
    func sorting() {
        let d1 = Duration(seconds: -1, nanoseconds: 0)
        let d2 = Duration(seconds: 0, nanoseconds: 500)
        let d3 = Duration(seconds: 0, nanoseconds: 1000)
        let d4 = Duration(seconds: 1, nanoseconds: 0)

        let unsorted = [d3, d1, d4, d2]
        let sorted = unsorted.sorted()

        #expect(sorted == [d1, d2, d3, d4])
    }
}

// MARK: - Arithmetic Tests

extension DurationTests {
    @Test("DurationTests: 0.6s + 0.6s")
    func additionNormalization() {
        let d1 = Duration(seconds: 0, nanoseconds: 600_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 600_000_000)
        let result = d1 + d2
        #expect(result.seconds == 1)
        #expect(result.nanoseconds == 200_000_000)
    }

    @Test("DurationTests: Negative Scaling")
    func negativeMultiplication() {
        let duration = Duration(seconds: 1, nanoseconds: 500_000_000) // 1.5s
        let result = duration * -1
        // Expected: -1.5s -> -2s + 500ms
        #expect(result.seconds == -2)
        #expect(result.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Negative Duration by Positive Scalar")
    func negativeDivision() {
        // -1.5s stored as -2s + 500ms
        let duration = Duration(seconds: -2, nanoseconds: 500_000_000)
        let result = duration / 2

        // Logical result: -0.75s
        // Floored Normalization: -1s + 250ms
        #expect(result.seconds == -1)
        #expect(result.nanoseconds == 250_000_000)
    }

    @Test("DurationTests: Remainder Carry")
    func divisionWithRemainder() {
        let duration = Duration(seconds: 1, nanoseconds: 0)
        let result = duration / 4
        #expect(result.seconds == 0)
        #expect(result.nanoseconds == 250_000_000)
    }

    @Test("DurationTests: Large values")
    func divisionLarge() {
        let duration = Duration(seconds: .max / 2, nanoseconds: 0)
        // Should not overflow due to your reportingOverflow checks
        let result = duration / 1
        #expect(result.seconds == .max / 2)
    }
}
