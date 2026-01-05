@testable import ChronoCore
import ChronoMath
import Testing

@Suite("Instant Tests")
struct InstantTests {
    // MARK: - Initialization Tests

    @Test("InstantTests: Initialization with valid components")
    func validInit() {
        // Unix Epoch
        let epoch = Instant(seconds: 0, nanoseconds: 0)
        #expect(epoch.seconds == 0)
        #expect(epoch.nanoseconds == 0)

        // Future date
        let future = Instant(seconds: 2_000_000_000, nanoseconds: 500_000_000)
        #expect(future.seconds == 2_000_000_000)
        #expect(future.nanoseconds == 500_000_000)

        // Past date (Pre-1970)
        let past = Instant(seconds: -100, nanoseconds: 123)
        #expect(past.seconds == -100)
        #expect(past.nanoseconds == 123)
    }

    @Test("InstantTests: Instant.zero identity")
    func instantZero() {
        let zero: Instant = .zero
        #expect(zero.seconds == 0)
        #expect(zero.nanoseconds == 0)
    }

    @Test("InstantTests: Instant.now() captures current time")
    func instantNow() {
        let first: Instant = .now()

        // Brief sleep or work to ensure time passes
        // Note: Even without sleep, system clocks usually have enough resolution
        let second: Instant = .now()

        // 1. Verify seconds are in a realistic Unix range (e.g., > Jan 1 2024)
        // 1704067200 is 2024-01-01 00:00:00 UTC
        #expect(first.seconds > 1_704_067_200)

        // 2. Verify time is moving forward
        #expect(second >= first)
    }

    @Test("InstantTests: High resolution check")
    func highResolution() {
        // Capture many instants in a tight loop
        let count = 100
        var instants: [Instant] = []
        instants.reserveCapacity(count)

        for _ in 0 ..< count {
            instants.append(.now())
        }

        // Verify that we are actually getting different nanosecond values
        // (Ensures the clock isn't just returning whole seconds)
        let uniqueInstants = Set(instants.map { "\($0.seconds).\($0.nanoseconds)" })

        #expect(uniqueInstants.count > 1, "Clock resolution might be too low or stuck")
    }
}

// MARK: - Comparison Tests

extension InstantTests {
    @Test("InstantTests: Different seconds")
    func differentSeconds() {
        let earlier = Instant(seconds: 100, nanoseconds: 0)
        let later = Instant(seconds: 200, nanoseconds: 0)

        #expect(earlier < later)
        #expect(later > earlier)
        #expect(!(earlier > later))
    }

    @Test("InstantTests: Same seconds, different nanoseconds")
    func sameSeconds() {
        let earlier = Instant(seconds: 100, nanoseconds: 500)
        let later = Instant(seconds: 100, nanoseconds: 900)

        #expect(earlier < later, "With equal seconds, higher nanoseconds should be greater")
        #expect(later > earlier)
    }

    @Test("InstantTests: Negative seconds (Pre-Epoch)")
    func negativeSeconds() {
        let veryPast = Instant(seconds: -200, nanoseconds: 0)
        let recentPast = Instant(seconds: -100, nanoseconds: 0)
        let epoch = Instant(seconds: 0, nanoseconds: 0)

        #expect(veryPast < recentPast)
        #expect(recentPast < epoch)

        // Testing nanosecond priority in negative time
        let negativeWithNanos = Instant(seconds: -100, nanoseconds: 500)
        #expect(recentPast < negativeWithNanos, "Nanos should increase the value toward zero/positive")
    }

    @Test("InstantTests: Equality and Hashable conformance")
    func equality() {
        let i1 = Instant(seconds: 123_456, nanoseconds: 500)
        let i2 = Instant(seconds: 123_456, nanoseconds: 500)
        let i3 = Instant(seconds: 123_456, nanoseconds: 501)
        let i4 = Instant(seconds: 123_457, nanoseconds: 500)

        #expect(i1 == i2)
        #expect(i1 != i3)
        #expect(i1 != i4)
        #expect(i1.hashValue == i2.hashValue)
    }

    @Test("InstantTests: Equality boundaries")
    func equalityBoundaries() {
        let i1 = Instant(seconds: 50, nanoseconds: 250)
        let i2 = Instant(seconds: 50, nanoseconds: 250)

        #expect(!(i1 < i2))
        #expect(!(i1 > i2))
        #expect(i1 <= i2)
        #expect(i1 >= i2)
    }

    @Test("InstantTests: Collection ordering")
    func collectionSorting() {
        let i1 = Instant(seconds: -10, nanoseconds: 0)
        let i2 = Instant(seconds: 10, nanoseconds: 0)
        let i3 = Instant(seconds: 10, nanoseconds: 500)
        let i4 = Instant(seconds: 100, nanoseconds: 0)

        let unsorted = [i3, i1, i4, i2]
        let sorted = unsorted.sorted()

        #expect(sorted == [i1, i2, i3, i4])
    }
}

// MARK: Timestamp Tests

extension InstantTests {
    @Test("InstantTests: Standard second timestamp")
    func timestamp() {
        let instant = Instant(seconds: 123_456_789, nanoseconds: 500)
        #expect(instant.timestamp == 123_456_789)
    }

    @Test("InstantTests: Microsecond timestamp conversion", arguments: [
        // (sec, nano, expected micros)
        (0, 1000, 1),
        (1, 500_000, 1_000_500),
        (-1, 1000, -999_999) // -1s + 1ms = -999,999 micros
    ])
    func timestampMicroseconds(s: Int64, n: Int32, expected: Int64) {
        let instant = Instant(seconds: s, nanoseconds: n)
        #expect(instant.timestampMicroseconds == expected)
    }

    @Test("InstantTests: Nanosecond timestamp conversion", arguments: [
        (0, 500, 500),
        (1, 1, 1_000_000_001),
        (-1, 1, -999_999_999)
    ])
    func timestampNanoseconds(s: Int64, n: Int32, expected: Int64) {
        let instant = Instant(seconds: s, nanoseconds: n)
        #expect(instant.timestampNanoseconds == expected)
    }

    @Test("InstantTests: Checked nanosecond timestamp overflow")
    func timestampNanosecondsChecked() {
        // A date very far in the future (e.g., Year 3000)
        // Int64.max nanoseconds is ~292 years from 1970.
        // So 10 billion seconds (~317 years) should overflow.
        let farFuture = Instant(seconds: 10_000_000_000, nanoseconds: 0)
        #expect(farFuture.timestampNanosecondsChecked == nil, "Should return nil on overflow")

        let farPast = Instant(seconds: -10_000_000_000, nanoseconds: 0)
        #expect(farPast.timestampNanosecondsChecked == nil, "Should return nil on underflow")

        // Valid date (Year 2025)
        let valid = Instant(seconds: 1_735_171_200, nanoseconds: 0)
        #expect(valid.timestampNanosecondsChecked != nil)
    }
}

// MAKR: - Arithmetic Tests

extension InstantTests {
    @Test("InstantTests: Positive seconds and nanoseconds")
    func standardAdvance() {
        let base = Instant(seconds: 1000, nanoseconds: 500_000_000)
        // Add 500 seconds and 600ms
        let result = base.advanced(bySeconds: 500, nanoseconds: 600_000_000)

        // 500ms + 600ms = 1.1s. Carry 1 to seconds, 100ms remains.
        #expect(result.seconds == 1501)
        #expect(result.nanoseconds == 100_000_000)
    }

    @Test("InstantTests: Forward from negative to positive")
    func crossEpochForward() {
        // 0.5 seconds before 1970
        let base = Instant(seconds: -1, nanoseconds: 500_000_000)
        // Add 1 second
        let result = base.advanced(bySeconds: 1)

        #expect(result.seconds == 0)
        #expect(result.nanoseconds == 500_000_000)
    }

    @Test("InstantTests: Backward from positive to negative")
    func crossEpochBackward() {
        // 0.1 seconds after 1970
        let base = Instant(seconds: 0, nanoseconds: 100_000_000)
        // Subtract 0.2 seconds
        let result = base.advanced(bySeconds: 0, nanoseconds: -200_000_000)

        // Result should be -0.1s (represented as -1s + 900ms)
        #expect(result.seconds == -1)
        #expect(result.nanoseconds == 900_000_000)
    }

    @Test("InstantTests: Large nanosecond carry")
    func largeNanoCarry() {
        let base = Instant(seconds: 0, nanoseconds: 0)
        // Add 2.5 seconds purely via nanoseconds
        let result = base.advanced(bySeconds: 0, nanoseconds: 2_500_000_000)

        #expect(result.seconds == 2)
        #expect(result.nanoseconds == 500_000_000)
    }

    @Test("InstantTests: Exactly one second in nanos")
    func exactSecondCarry() {
        let base = Instant(seconds: 10, nanoseconds: 0)
        let result = base.advanced(bySeconds: 0, nanoseconds: 1_000_000_000)

        #expect(result.seconds == 11)
        #expect(result.nanoseconds == 0)
    }

    @Test("InstantTests: Advanced by Duration")
    func durationInterface() {
        let base = Instant(seconds: 10, nanoseconds: 0)
        let duration = Duration(seconds: -11, nanoseconds: 100_000_000) // -10.9s

        let result = base.advanced(by: duration)

        // 10s + (-10.9s) = -0.9s (represented as -1s + 100ms)
        #expect(result.seconds == -1)
        #expect(result.nanoseconds == 100_000_000)
    }
}

// MARK: - Addition Rounding

extension InstantTests {
    @Test("InstantTests: Instant + Duration")
    func instantPlusDuration() {
        let base = Instant(seconds: 100, nanoseconds: 0)
        let delta = Duration(seconds: 50, nanoseconds: 500_000_000)

        let result = base + delta

        #expect(result.seconds == 150)
        #expect(result.nanoseconds == 500_000_000)
    }

    @Test("InstantTests: Duration + Instant (Commutative)")
    func durationPlusInstant() {
        let delta = Duration(seconds: 10)
        let base = Instant(seconds: -5, nanoseconds: 0) // 5s before 1970

        let result = delta + base

        #expect(result.seconds == 5)
        #expect(result.nanoseconds == 0)
    }

    @Test("InstantTests: Mutating addition")
    func compoundAddition() {
        var base = Instant(seconds: 1000, nanoseconds: 0)
        let delta = Duration(seconds: 1, nanoseconds: 0)

        base += delta
        base += delta

        #expect(base.seconds == 1002)
    }

    @Test("InstantTests: Cross-midnight equivalent logic")
    func compoundAdditionWithCarry() {
        var base = Instant(seconds: 0, nanoseconds: 900_000_000)
        let delta = Duration(seconds: 0, nanoseconds: 200_000_000)

        base += delta

        #expect(base.seconds == 1)
        #expect(base.nanoseconds == 100_000_000)
    }
}

// MARK: - Substraction Rounding

extension InstantTests {
    @Test("InstantTests: Positive difference")
    func positiveDistance() {
        let end = Instant(seconds: 100, nanoseconds: 500_000_000)
        let start = Instant(seconds: 90, nanoseconds: 100_000_000)

        let diff = end - start

        #expect(diff.seconds == 10)
        #expect(diff.nanoseconds == 400_000_000)
    }

    @Test("InstantTests: Negative difference with normalization")
    func negativeDistanceNormalization() {
        let start = Instant(seconds: 10, nanoseconds: 200_000_000) // 10.2s
        let end = Instant(seconds: 10, nanoseconds: 800_000_000) // 10.8s

        // 10.2 - 10.8 = -0.6s
        let diff = start - end

        // Normalized Duration: -1 second + 400,000,000 nanoseconds = -0.6s
        #expect(diff.seconds == -1)
        #expect(diff.nanoseconds == 400_000_000)
    }

    @Test("InstantTests: Across the 1970 Epoch")
    func distanceAcrossEpoch() {
        let postEpoch = Instant(seconds: 1, nanoseconds: 0) // 1970-01-01 00:00:01
        let preEpoch = Instant(seconds: -1, nanoseconds: 0) // 1969-12-31 23:59:59

        let diff = postEpoch - preEpoch
        #expect(diff.seconds == 2)
    }

    @Test("InstantTests: Subtract duration with nanosecond borrow")
    func subtractDurationBorrow() {
        let base = Instant(seconds: 10, nanoseconds: 100_000_000) // 10.1s
        let delta = Duration(seconds: 0, nanoseconds: 200_000_000) // 0.2s

        let result = base - delta

        // 10.1 - 0.2 = 9.9s
        #expect(result.seconds == 9)
        #expect(result.nanoseconds == 900_000_000)
    }

    @Test("InstantTests: Mutating subtraction")
    func compoundSubtraction() {
        var time = Instant(seconds: 0, nanoseconds: 0)
        let delta = Duration(seconds: 1, nanoseconds: 500_000_000) // 1.5s

        time -= delta

        // 0 - 1.5 = -1.5s (Stored as -2s + 500ms)
        #expect(time.seconds == -2)
        #expect(time.nanoseconds == 500_000_000)
    }
}

// MARK: - Subsecond Rounding

extension InstantTests {
    @Test("InstantTests: Truncate subseconds to varying precision", arguments: [
        (123_456_789, 0, 0), // To whole second
        (123_456_789, 3, 123_000_000), // To milliseconds
        (123_456_789, 6, 123_456_000), // To microseconds
        (123_456_789, 8, 123_456_780), // To 10-nanoseconds
    ])
    func truncateSubseconds(nanos: Int32, digits: Int, expectedNanos: Int32) {
        let instant = Instant(seconds: 1000, nanoseconds: nanos)
        let result = instant.truncateSubseconds(digits)

        #expect(result.seconds == 1000)
        #expect(result.nanoseconds == expectedNanos)
    }

    @Test("InstantTests: Round subseconds (Half-Up)", arguments: [
        (499_999_999, 0, 0, 0), // Round down (< 0.5)
        (500_000_000, 0, 1, 0), // Round up (== 0.5)
        (123_400_000, 3, 0, 123_000_000), // Round down (milli)
        (123_500_000, 3, 0, 124_000_000), // Round up (milli)
        (999_999_999, 0, 1, 0) // Round up to next second
    ])
    func roundSubseconds(nanos: Int32, digits: Int, secOffset: Int64, expNanos: Int32) {
        let baseSeconds: Int64 = 1000
        let instant = Instant(seconds: baseSeconds, nanoseconds: nanos)
        let result = instant.roundSubseconds(digits)

        #expect(result.seconds == baseSeconds + secOffset)
        #expect(result.nanoseconds == expNanos)
    }

    @Test("InstantTests: Precision at or above 9 digits is a no-op")
    func roundingNoOp() {
        let instant = Instant(seconds: 100, nanoseconds: 123_456_789)

        #expect(instant.roundSubseconds(9) == instant)
        #expect(instant.truncateSubseconds(10) == instant)
    }

    @Test("InstantTests: Rounding near the Unix Epoch (Negative Seconds)")
    func roundingNegativeSeconds() {
        // -0.5 seconds (represented as seconds: -1, nanos: 500,000,000)
        let halfSecondBeforeEpoch = Instant(seconds: -1, nanoseconds: 500_000_000)

        // Rounding to 0 digits should round UP to 0 (the epoch)
        let rounded = halfSecondBeforeEpoch.roundSubseconds(0)
        #expect(rounded.seconds == 0)
        #expect(rounded.nanoseconds == 0)

        // -0.6 seconds (seconds: -1, nanos: 400,000,000)
        let pointSixBeforeEpoch = Instant(seconds: -1, nanoseconds: 400_000_000)

        // Rounding to 0 digits should round DOWN to -1.0
        let roundedDown = pointSixBeforeEpoch.roundSubseconds(0)
        #expect(roundedDown.seconds == -1)
        #expect(roundedDown.nanoseconds == 0)
    }
}

// MARK: Duration Rounding Tests

extension InstantTests {
    @Test("InstantTests: Truncate by duration quantum", arguments: [
        (15, 10, 10, 0), // 15s truncated by 10s -> 10s
        (25, 15, 15, 0), // 25s truncated by 15s -> 15s
        (100, 60, 60, 0), // 100s truncated by 1min -> 60s
        (5, 2, 4, 0), // 5s truncated by 2s -> 4s
    ])
    func truncateByQuantum(baseSec: Int64, quantumSec: Int64, expSec: Int64, expNanos: Int32) throws {
        let instant = Instant(seconds: baseSec, nanoseconds: 0)
        let quantum = Duration(seconds: quantumSec, nanoseconds: 0)

        let result = try instant.truncate(byQuantum: quantum)

        #expect(result.seconds == expSec)
        #expect(result.nanoseconds == expNanos)
    }

    @Test("InstantTests: Round by duration quantum (Half-Up)", arguments: [
        (7, 10, 10), // 7s rounded by 10s -> 10s (Up)
        (4, 10, 0), // 4s rounded by 10s -> 0s (Down)
        (5, 10, 10), // 5s rounded by 10s -> 10s (Midpoint Up)
        (90, 60, 120), // 90s rounded by 60s -> 120s (Midpoint Up)
    ])
    func roundByQuantum(baseSec: Int64, quantumSec: Int64, expSec: Int64) throws {
        let instant = Instant(seconds: baseSec, nanoseconds: 0)
        let quantum = Duration(seconds: quantumSec, nanoseconds: 0)

        let result = try instant.round(byQuantum: quantum)
        #expect(result.seconds == expSec)
    }

    @Test("InstantTests: Round Up by duration quantum")
    func roundUpByQuantum() throws {
        let instant = Instant(seconds: 1, nanoseconds: 0)
        let quantum = Duration(seconds: 60, nanoseconds: 0)

        let result = try instant.roundUp(byQuantum: quantum)
        #expect(result.seconds == 60)

        let exact = Instant(seconds: 60, nanoseconds: 0)
        #expect(try exact.roundUp(byQuantum: quantum).seconds == 60)
    }

    @Test("InstantTests: Rounding throws invalidQuantum for zero or negative")
    func invalidQuantum() {
        let instant = Instant(seconds: 100, nanoseconds: 0)
        let zero = Duration(seconds: 0, nanoseconds: 0)

        #expect(throws: TimeRoundingError.invalidQuantum) {
            try instant.round(byQuantum: zero)
        }
    }

    @Test("InstantTests: Rounding throws quantumExceedsLimit for massive durations")
    func quantumLimit() {
        let instant = Instant(seconds: 100, nanoseconds: 0)
        // Duration that exceeds Int64 nanosecond capacity
        let huge = Duration(seconds: 20_000_000_000, nanoseconds: 0)

        #expect(throws: TimeRoundingError.quantumExceedsLimit) {
            try instant.truncate(byQuantum: huge)
        }
    }

    @Test("InstantTests: Rounding throws timestampExceedsLimit for distant dates")
    func timestampLimit() {
        // Instant that exceeds Int64 nanosecond capacity (~292 years from epoch)
        let distant = Instant(seconds: 20_000_000_000, nanoseconds: 0)
        let quantum = Duration(seconds: 10, nanoseconds: 0)

        #expect(throws: TimeRoundingError.timestampExceedsLimit) {
            try distant.round(byQuantum: quantum)
        }
    }

    @Test("InstantTests: Rounding by sub-second quantum (e.g., 250ms)")
    func subsecondQuantum() throws {
        let instant = Instant(seconds: 0, nanoseconds: 300_000_000) // 300ms
        let quantum = Duration(seconds: 0, nanoseconds: 250_000_000) // 250ms

        // Truncate 300ms by 250ms -> 250ms
        #expect(try instant.truncate(byQuantum: quantum).nanoseconds == 250_000_000)

        // Round 300ms by 250ms -> 250ms (since 300 is closer to 250 than 500)
        #expect(try instant.round(byQuantum: quantum).nanoseconds == 250_000_000)

        // Round Up 300ms by 250ms -> 500ms
        #expect(try instant.roundUp(byQuantum: quantum).nanoseconds == 500_000_000)
    }
}

// MARK: - Naive Conversion Tests

extension InstantTests {
    @Test("InstantTests: Convert UTC 0 to NaiveDateTime")
    func epochConversion() {
        let epoch = Instant(seconds: 0, nanoseconds: 0)
        let utc = MockTimeZone(offset: 0)

        let result = epoch.naiveDateTime(in: utc)

        #expect(result.year == 1970)
        #expect(result.month == 1)
        #expect(result.day == 1)
        #expect(result.hour == 0)
        #expect(result.minute == 0)
    }

    @Test("InstantTests: Positive offset rolls to next day", arguments: [
        // 23:00 UTC + 2 hour offset = 01:00 Next Day
        (23 * 3600, 2 * 3600, 2, 1, 0)
    ])
    func positiveOffsetRollover(
        seconds: Int64,
        offset: Int,
        expectedDay: Int,
        expectedHour: Int,
        expectedMinute: Int
    ) {
        let instant = Instant(seconds: seconds, nanoseconds: 0)
        let tz = MockTimeZone(offset: offset)

        let result = instant.naiveDateTime(in: tz)

        #expect(result.year == 1970)
        #expect(result.month == 1)
        #expect(result.day == expectedDay)
        #expect(result.hour == expectedHour)
        #expect(result.minute == expectedMinute)
    }

    @Test("InstantTests: Negative offset rolls to previous day", arguments: [
        // 01:00 UTC - 2 hour offset = 23:00 Previous Day
        (1 * 3600, -2 * 3600, 1969, 12, 31, 23)
    ])
    // swiftlint:disable:next function_parameter_count
    func negativeOffsetRollover(
        seconds: Int64,
        offset: Int,
        expY: Int32,
        expM: Int,
        expD: Int,
        expH: Int
    ) {
        let instant = Instant(seconds: seconds, nanoseconds: 0)
        let tz = MockTimeZone(offset: offset)

        let result = instant.naiveDateTime(in: tz)

        #expect(result.year == expY)
        #expect(result.month == expM)
        #expect(result.day == expD)
        #expect(result.hour == expH)
    }

    @Test("InstantTests: Nanoseconds are preserved during conversion")
    func nanosecondPreservation() {
        let instant = Instant(seconds: 100, nanoseconds: 123_456_789)
        let tz = MockTimeZone(offset: 3600)

        let result = instant.naiveDateTime(in: tz)

        #expect(result.nanosecond == 123_456_789)
    }
}

// MARK: - Date Time Conversion

extension InstantTests {
    @Test("InstantTests: Wraps into DateTime with specific TimeZone")
    func wrapInTimeZone() {
        let instant = Instant(seconds: 1_735_171_200, nanoseconds: 500) // 2024-12-26
        let mockTZ = MockTimeZone(offset: 3600) // UTC+1

        let zoned = instant.dateTime(in: mockTZ)

        #expect(zoned.instant == instant)
        #expect(zoned.timezone.offset == 3600)
    }

    @Test("InstantTests: Wraps into DateTime<UTC>")
    func wrapInUTC() {
        let instant = Instant(seconds: 0, nanoseconds: 0)
        let zonedUTC = instant.dateTimeUTC()

        #expect(zonedUTC.instant == instant)
        #expect(zonedUTC.hour == 0) // UTC Epoch hour
    }

    @Test("InstantTests: Wraps into DateTime with FixedOffset")
    func wrapInFixedOffset() {
        let instant = Instant(seconds: 0, nanoseconds: 0)
        let offset = FixedOffset(seconds: -18000) // UTC-5

        let zoned = instant.dateTime(in: offset)

        #expect(zoned.instant == instant)
        #expect(zoned.timezone.duration.seconds == -18000)

        // In UTC-5, the Epoch 00:00:00 UTC is actually 19:00:00 on the previous day
        #expect(zoned.hour == 19)
    }
}
