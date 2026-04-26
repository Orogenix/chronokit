@testable import ChronoCore
import ChronoMath
import Testing

// MARK: - Initialization Tests

struct PlainTimeTests {
    @Test("PlainTimeTests: Initialize from valid components", arguments: [
        (0, 0, 0, 0), // Midnight
        (12, 30, 15, 500_000), // Mid-day
        (23, 59, 59, 999_999_999), // Last nanosecond
    ])
    func validComponentInit(h: Int, m: Int, s: Int, n: Int) {
        let time = PlainTime(hour: h, minute: m, second: s, nanosecond: n)
        #expect(time != nil)
        #expect(time?.hour == h)
        #expect(time?.minute == m)
        #expect(time?.second == s)
        #expect(time?.nanosecond == n)
    }

    @Test("PlainTimeTests: Initialize from invalid components returns nil", arguments: [
        (24, 0, 0, 0), // Invalid hour
        (-1, 0, 0, 0), // Negative hour
        (12, 60, 0, 0), // Invalid minute
        (12, 0, 60, 0), // Invalid second
        (12, 0, 0, Int(1_000_000_000)) // Invalid nanosecond (1s)
    ])
    func invalidComponentInit(h: Int, m: Int, s: Int, n: Int) {
        #expect(PlainTime(hour: h, minute: m, second: s, nanosecond: n) == nil)
    }

    @Test("PlainTimeTests: Initialize from nanoseconds since midnight")
    func nanosSinceMidnightInit() {
        // 1 hour, 1 minute, 1 second, 1 nanosecond
        let totalNanos: Int64 = NanoSeconds.perHour64 + NanoSeconds.perMinute64 + NanoSeconds.perSecond64 + 1
        let time = PlainTime(nanosecondsSinceMidnight: totalNanos)

        #expect(time.hour == 1)
        #expect(time.minute == 1)
        #expect(time.second == 1)
        #expect(time.nanosecond == 1)
        #expect(time.nanosecondsSinceMidnight == totalNanos)
    }

    @Test("PlainTimeTests: Boundary nanoseconds")
    func nanosBoundaries() {
        let midnight = PlainTime(nanosecondsSinceMidnight: 0)
        #expect(midnight.hour == 0)

        let lastNano = PlainTime(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)
        #expect(lastNano.hour == 23)
        #expect(lastNano.minute == 59)
        #expect(lastNano.second == 59)
        #expect(lastNano.nanosecond == 999_999_999)
    }

    @Test("PlainTimeTests: Component to Nanos round-trip")
    func roundTrip() throws {
        let hour = 14
        let month = 45
        let second = 30
        let nanosecond = 123_456

        let time1 = try #require(PlainTime(hour: hour, minute: month, second: second, nanosecond: nanosecond))
        let time2 = PlainTime(nanosecondsSinceMidnight: time1.nanosecondsSinceMidnight)

        #expect(time1 == time2)
        #expect(time2.hour == hour)
        #expect(time2.nanosecond == nanosecond)
    }

    @Test("PlainTimeTests: Boundary constants integrity")
    func boundaries() {
        // Ensure constants can be initialized without crashing
        let minTime = PlainTime.min
        let maxTime = PlainTime.max

        #expect(minTime.nanosecondsSinceMidnight == 0)
        #expect(maxTime.nanosecondsSinceMidnight == NanoSeconds.perDay64 - 1)

        // Verify max time components (should be 23:59:59.999999999)
        #expect(maxTime.hour == 23)
        #expect(maxTime.minute == 59)
        #expect(maxTime.second == 59)
    }
}

// MARK: - Comparison Tests

extension PlainTimeTests {
    @Test("PlainTimeTests: Strict inequality across time boundaries", arguments: [
        // Different Hours
        (PlainTime(hour: 9, minute: 59, second: 59)!, PlainTime(hour: 10, minute: 0, second: 0)!),
        // Different Minutes
        (PlainTime(hour: 14, minute: 30, second: 59)!, PlainTime(hour: 14, minute: 31, second: 0)!),
        // Different Seconds
        (PlainTime(hour: 23, minute: 59, second: 58)!, PlainTime(hour: 23, minute: 59, second: 59)!),
        // Single Nanosecond difference
        (PlainTime(nanosecondsSinceMidnight: 100), PlainTime(nanosecondsSinceMidnight: 101)),
    ])
    func chronologicalOrder(earlier lhs: PlainTime, later rhs: PlainTime) {
        #expect(lhs < rhs)
        #expect(rhs > lhs)
        #expect(lhs <= rhs)
        #expect(rhs >= lhs)
        #expect(lhs != rhs)
    }

    @Test("PlainTimeTests: Equality properties")
    func equality() throws {
        let time1 = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        let time2 = try #require(PlainTime(hour: 12, minute: 0, second: 0))

        #expect(time1 == time2)
        #expect(!(time1 < time2))
        #expect(!(time1 > time2))
        #expect(time1 <= time2)
        #expect(time1 >= time2)
    }

    @Test("PlainTimeTests: Sorting a timeline")
    func sorting() throws {
        let morning = try #require(PlainTime(hour: 8, minute: 0, second: 0))
        let noon = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        let afternoon = try #require(PlainTime(hour: 15, minute: 30, second: 0))
        let night = try #require(PlainTime(hour: 23, minute: 59, second: 59))

        let unsorted = [afternoon, morning, night, noon]
        let sorted = unsorted.sorted()

        #expect(sorted == [morning, noon, afternoon, night])
    }

    @Test("PlainTimeTests: Time range validation")
    func ranges() throws {
        let openingTime = try #require(PlainTime(hour: 9, minute: 0, second: 0))
        let closingTime = try #require(PlainTime(hour: 17, minute: 0, second: 0))
        let businessHours = openingTime ... closingTime

        let lunchTime = try #require(PlainTime(hour: 12, minute: 30, second: 0))
        let midnight = try #require(PlainTime(hour: 0, minute: 0, second: 0))

        #expect(businessHours.contains(lunchTime))
        #expect(businessHours.contains(openingTime))
        #expect(businessHours.contains(closingTime))
        #expect(!businessHours.contains(midnight))
    }

    @Test("PlainTimeTests: Minimum and Maximum bounds")
    func extremes() throws {
        let midnight = PlainTime(nanosecondsSinceMidnight: 0)
        let endOfDay = PlainTime(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)

        #expect(midnight < endOfDay)

        let randomTime = try #require(PlainTime(hour: 11, minute: 11, second: 11))
        #expect(midnight < randomTime)
        #expect(randomTime < endOfDay)
    }
}

// MARK: - Arithmetic

extension PlainTimeTests {
    @Test("PlainTimeTests: Standard seconds and minutes")
    func standardAdvance() throws {
        let base = try #require(PlainTime(hour: 10, minute: 0, second: 0))
        // Advance 1 hour, 5 minutes, 10 seconds
        let result = base.advanced(bySeconds: 3600 + 300 + 10)

        #expect(result.hour == 11)
        #expect(result.minute == 5)
        #expect(result.second == 10)
    }

    @Test("PlainTimeTests: Sub-second nanosecond carry")
    func nanosecondCarry() throws {
        let base = try #require(PlainTime(hour: 10, minute: 0, second: 0, nanosecond: 900_000_000))
        // Add 200ms
        let result = base.advanced(bySeconds: 0, nanoseconds: 200_000_000)

        #expect(result.second == 1)
        #expect(result.nanosecond == 100_000_000)
    }

    @Test("PlainTimeTests: Forward past midnight")
    func forwardMidnightWrap() throws {
        let base = try #require(PlainTime(hour: 23, minute: 50, second: 0))
        // Add 15 minutes (900 seconds)
        let result = base.advanced(bySeconds: 900)

        #expect(result.hour == 0)
        #expect(result.minute == 5)
    }

    @Test("PlainTimeTests: Backward past midnight")
    func backwardMidnightWrap() throws {
        let base = try #require(PlainTime(hour: 0, minute: 10, second: 0))
        // Subtract 20 minutes (-1200 seconds)
        let result = base.advanced(bySeconds: -1200)

        #expect(result.hour == 23)
        #expect(result.minute == 50)
    }

    @Test("PlainTimeTests: Multiple days advancement")
    func multiDayWrap() throws {
        let base = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        // Add 48 hours (2 full days)
        let result = base.advanced(bySeconds: 48 * 3600)

        #expect(result.hour == 12, "Should wrap back to exactly the same time")
    }

    @Test("PlainTimeTests: Advanced by Duration")
    func durationInterface() throws {
        let base = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        let duration = Duration(seconds: 3661, nanoseconds: 500_000_000) // 1h 1m 1.5s

        let result = base.advanced(by: duration)

        #expect(result.hour == 13)
        #expect(result.minute == 1)
        #expect(result.second == 1)
        #expect(result.nanosecond == 500_000_000)
    }
}

// MARK: - Addition

extension PlainTimeTests {
    @Test("PlainTimeTests: DateTime + Duration")
    func additionPointDuration() throws {
        let time = try #require(PlainTime(hour: 14, minute: 30, second: 0))
        let delta = Duration(seconds: 3600) // 1 hour

        let result = time + delta

        #expect(result.hour == 15)
        #expect(result.minute == 30)
    }

    @Test("PlainTimeTests: Duration + DateTime (Commutative)")
    func additionDurationPoint() throws {
        let delta = Duration(seconds: 60) // 1 minute
        let time = try #require(PlainTime(hour: 8, minute: 0, second: 0))

        let result = delta + time

        #expect(result.hour == 8)
        #expect(result.minute == 1)
    }

    @Test("PlainTimeTests: Wrap around midnight")
    func additionWrap() throws {
        let time = try #require(PlainTime(hour: 23, minute: 59, second: 59))
        let delta = Duration(seconds: 2)

        let result = time + delta

        #expect(result.hour == 0)
        #expect(result.minute == 0)
        #expect(result.second == 1)
    }

    @Test("PlainTimeTests: Mutating addition")
    func compoundAddition() throws {
        var time = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        let delta = Duration(seconds: 1800) // 30 minutes

        time += delta

        #expect(time.hour == 12)
        #expect(time.minute == 30)
    }

    @Test("PlainTimeTests: Multiple mutations")
    func multipleMutations() throws {
        var time = try #require(PlainTime(hour: 0, minute: 0, second: 0))
        let hour = Duration(seconds: 3600)

        time += hour
        time += hour

        #expect(time.hour == 2)
    }
}

// MARK: - Substraction

extension PlainTimeTests {
    @Test("PlainTimeTests: Standard subtraction")
    func subtraction() throws {
        let time = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        let delta = Duration(seconds: 3600) // 1 hour

        let result = time - delta

        #expect(result.hour == 11)
        #expect(result.minute == 0)
    }

    @Test("PlainTimeTests: Sub-second borrow")
    func subSecondBorrow() throws {
        let time = try #require(PlainTime(hour: 10, minute: 0, second: 1, nanosecond: 0))
        // Subtract 0.5 seconds
        let delta = Duration(seconds: 0, nanoseconds: 500_000_000)

        let result = time - delta

        #expect(result.hour == 10)
        #expect(result.second == 0)
        #expect(result.nanosecond == 500_000_000)
    }

    @Test("PlainTimeTests: Backward wrap across midnight")
    func testBackwardMidnightWrap() throws {
        let time = try #require(PlainTime(hour: 0, minute: 0, second: 1))
        // Subtract 2 seconds (Should go to 23:59:59)
        let delta = Duration(seconds: 2)

        let result = time - delta

        #expect(result.hour == 23)
        #expect(result.minute == 59)
        #expect(result.second == 59)
    }

    @Test("PlainTimeTests: Mutating subtraction")
    func compoundSubtraction() throws {
        var time = try #require(PlainTime(hour: 1, minute: 0, second: 0))
        let delta = Duration(seconds: 3600) // 1 hour

        time -= delta

        #expect(time.hour == 0)
        #expect(time.minute == 0)
    }

    @Test("PlainTimeTests: Multiple backward wraps")
    func largeNegativeDelta() throws {
        var time = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        // Subtract 25 hours (Should be 11:00 AM)
        let delta = Duration(seconds: 25 * 3600)

        time -= delta

        #expect(time.hour == 11)
        #expect(time.minute == 0)
    }
}

// MARK: - 12-Hour Clock Tests

extension PlainTimeTests {
    @Test("PlainTimeTests: 12-hour clock conversion", arguments: [
        (0, false, 12), // Midnight
        (1, false, 1), // 1 AM
        (11, false, 11), // 11 AM
        (12, true, 12), // Noon
        (13, true, 1), // 1 PM
        (23, true, 11), // 11 PM
    ])
    func hour12Conversion(hour24: Int, expectedIsPM: Bool, expectedHour12: Int) throws {
        let time = try #require(PlainTime(hour: hour24, minute: 0, second: 0))
        let result = time.hour12

        #expect(result.isPM == expectedIsPM, "Hour \(hour24) PM status mismatch")
        #expect(result.hour == expectedHour12, "Hour \(hour24) 12-hour value mismatch")
    }
}

// MARK: - Seconds Calculation Tests

extension PlainTimeTests {
    @Test("PlainTimeTests: Total seconds from midnight", arguments: [
        (0, 0, 0, 0),
        (0, 0, 1, 1),
        (0, 1, 0, 60),
        (1, 0, 0, 3600),
        (23, 59, 59, 86399),
    ])
    func totalSeconds(h: Int, m: Int, s: Int, expectedSeconds: Int) throws {
        let time = try #require(PlainTime(hour: h, minute: m, second: s))
        #expect(time.secondsFromMidnight == expectedSeconds)
    }
}

// MARK: - Modification (with...) Tests

extension PlainTimeTests {
    @Test("PlainTimeTests: Modify hour component")
    func modifyHour() throws {
        let base = try #require(PlainTime(hour: 10, minute: 30, second: 0))

        // Valid
        let newTime = base.with(hour: 22)
        #expect(newTime?.hour == 22)
        #expect(newTime?.minute == 30) // Ensure other components persist

        // Invalid
        #expect(base.with(hour: 24) == nil)
        #expect(base.with(hour: -1) == nil)
    }

    @Test("PlainTimeTests: Modify minute component")
    func modifyMinute() throws {
        let base = try #require(PlainTime(hour: 10, minute: 30, second: 0))

        #expect(base.with(minute: 59)?.minute == 59)
        #expect(base.with(minute: 0)?.minute == 0)
        #expect(base.with(minute: 60) == nil)
    }

    @Test("PlainTimeTests: Modify second component")
    func modifySecond() throws {
        let base = try #require(PlainTime(hour: 10, minute: 30, second: 30))

        #expect(base.with(second: 45)?.second == 45)
        #expect(base.with(second: 60) == nil)
    }

    @Test("PlainTimeTests: Modify nanosecond component")
    func modifyNanosecond() throws {
        let base = try #require(PlainTime(hour: 10, minute: 30, second: 0, nanosecond: 500))

        #expect(base.with(nanosecond: 999_999_999)?.nanosecond == 999_999_999)
        #expect(base.with(nanosecond: -1) == nil)
        #expect(base.with(nanosecond: 1_000_000_000) == nil)
    }
}

// MARK: - Rounding Tests

extension PlainTimeTests {
    @Test("PlainTimeTests: Truncate subseconds", arguments: [
        // (Original Nanos, Digits, Expected Nanos)
        (123_456_789, 0, 0), // Truncate to whole second
        (123_456_789, 3, 123_000_000), // Truncate to milliseconds
        (123_456_789, 6, 123_456_000), // Truncate to microseconds
        (123_456_789, 9, 123_456_789), // No change at 9 digits
    ])
    func truncatePrecision(nanos: Int, digits: Int, expected: Int) throws {
        let time = try #require(PlainTime(hour: 0, minute: 0, second: 0, nanosecond: nanos))
        let truncated = time.truncateSubseconds(digits)
        #expect(truncated.nanosecond == expected)
    }

    @Test("PlainTimeTests: Round subseconds (Half-Up)", arguments: [
        // Rounding to Milliseconds (3 digits, span = 1,000,000)
        (123_400_000, 3, 123_000_000),
        (123_500_000, 3, 124_000_000),
        (123_600_000, 3, 124_000_000),

        // Rounding to Microseconds (6 digits, span = 1,000)
        (123_456_499, 6, 123_456_000),
        (123_456_500, 6, 123_457_000),

        // Rounding to nearest second (0 digits, span = 1,000,000,000)
        (499_999_999, 0, 0),
        (500_000_000, 0, 1_000_000_000), // Correctly results in 1 second, 0 nanos
    ])
    func roundPrecision(nanos: Int, digits: Int, expectedTotalNanos: Int64) throws {
        // 1. Create the input time (at 00:00:00.nanos)
        let time = try #require(PlainTime(hour: 0, minute: 0, second: 0, nanosecond: nanos))

        // 2. Perform the rounding
        let rounded = time.roundSubseconds(digits)

        // 3. Create the expected time using the total nanoseconds
        // This allows 1,000,000,000 to correctly become 00:00:01.000000000
        let expectedTime = PlainTime(nanosecondsSinceMidnight: expectedTotalNanos)

        #expect(rounded == expectedTime)

        // Additional check to see the "carry" in action for the last case
        if expectedTotalNanos == 1_000_000_000 {
            #expect(rounded.second == 1)
            #expect(rounded.nanosecond == 0)
        }
    }

    @Test("PlainTimeTests: Rounding at the end of the day wrap-around")
    func roundingBoundary() throws {
        // 23:59:59.600...
        let nearlyMidnight = try #require(PlainTime(hour: 23, minute: 59, second: 59, nanosecond: 600_000_000))

        // Rounding to 0 digits (nearest second)
        let rounded = nearlyMidnight.roundSubseconds(0)

        // It should now be exactly Midnight (00:00:00) instead of crashing
        #expect(rounded.nanosecondsSinceMidnight == 0)
        #expect(rounded.hour == 0)
        #expect(rounded.minute == 0)
        #expect(rounded.second == 0)
    }

    @Test("PlainTimeTests: Truncation at the end of the day does not wrap")
    func truncationBoundary() throws {
        let nearlyMidnight = try #require(PlainTime(hour: 23, minute: 59, second: 59, nanosecond: 999_999_999))

        // Truncating always goes down, so it stays within the same second/day
        let truncated = nearlyMidnight.truncateSubseconds(0)

        #expect(truncated.hour == 23)
        #expect(truncated.second == 59)
        #expect(truncated.nanosecond == 0)
    }
}

// MARK: - Plain Date Time Conversion

extension PlainTimeTests {
    @Test("PlainTimeTests: Convert using PlainDate object")
    func toDateTimeWithDateObject() throws {
        let baseTime = try #require(PlainTime(hour: 14, minute: 15, second: 30, nanosecond: 500))
        let date = try #require(PlainDate(year: 2025, month: 12, day: 25))
        let dt = baseTime.on(date)

        #expect(dt.time == baseTime)
        #expect(dt.date == date)
        #expect(dt.year == 2025)
        #expect(dt.hour == 14)
    }

    @Test("PlainTimeTests: Convert using days since epoch", arguments: [
        (0, 1970, 1, 1), // Epoch
        (20082, 2024, 12, 25), // Christmas 2024
        (-1, 1969, 12, 31), // Day before epoch
    ])
    func toDateTimeWithDays(days: Int64, expY: Int32, expM: Int, expD: Int) throws {
        let baseTime = try #require(PlainTime(hour: 14, minute: 15, second: 30, nanosecond: 500))
        let dt = baseTime.on(daysSinceEpoch: days)

        #expect(dt.time == baseTime)
        #expect(dt.year == expY)
        #expect(dt.month == expM)
        #expect(dt.day == expD)
    }

    @Test("PlainTimeTests: Convert using valid year/month/day components")
    func toDateTimeWithValidComponents() throws {
        let baseTime = try #require(PlainTime(hour: 14, minute: 15, second: 30, nanosecond: 500))
        // Testing the (Int32, Int, Int) overload
        let dt = baseTime.on(year: 2024, month: 2, day: 29)

        #expect(dt != nil)
        #expect(dt?.year == 2024)
        #expect(dt?.month == 2)
        #expect(dt?.day == 29)
        #expect(dt?.time == baseTime)
    }

    @Test("PlainTimeTests: Convert using invalid date components returns nil", arguments: [
        (2025, 2, 29), // Not a leap year
        (2025, 13, 1), // Invalid month
        (2025, 1, 32), // Invalid day
    ])
    func toDateTimeWithInvalidComponents(year: Int32, month: Int, day: Int) throws {
        let baseTime = try #require(PlainTime(hour: 14, minute: 15, second: 30, nanosecond: 500))
        let result = baseTime.on(year: year, month: month, day: day)
        #expect(result == nil)
    }

    @Test("PlainTimeTests: Convert using UInt8 month/day components")
    func toDateTimeWithUInt8Components() throws {
        let baseTime = try #require(PlainTime(hour: 14, minute: 15, second: 30, nanosecond: 500))
        // Testing the (Int32, UInt8, UInt8) overload
        let month: UInt8 = 10
        let day: UInt8 = 31
        let dt = baseTime.on(year: 2025, month: month, day: day)

        #expect(dt?.month == 10)
        #expect(dt?.day == 31)
    }
}
