@testable import ChronoCore
import ChronoMath
import Testing

@Suite("Naive Time Tests")
struct NaiveTimeTests {
    // MARK: - Initialization Tests

    @Test("NaiveTimeTests: Initialize from valid components", arguments: [
        (0, 0, 0, 0), // Midnight
        (12, 30, 15, 500_000), // Mid-day
        (23, 59, 59, 999_999_999), // Last nanosecond
    ])
    func validComponentInit(h: Int, m: Int, s: Int, n: Int) {
        let time = NaiveTime(hour: h, minute: m, second: s, nanosecond: n)
        #expect(time != nil)
        #expect(time?.hour == h)
        #expect(time?.minute == m)
        #expect(time?.second == s)
        #expect(time?.nanosecond == n)
    }

    @Test("NaiveTimeTests: Initialize from invalid components returns nil", arguments: [
        (24, 0, 0, 0), // Invalid hour
        (-1, 0, 0, 0), // Negative hour
        (12, 60, 0, 0), // Invalid minute
        (12, 0, 60, 0), // Invalid second
        (12, 0, 0, Int(1_000_000_000)) // Invalid nanosecond (1s)
    ])
    func invalidComponentInit(h: Int, m: Int, s: Int, n: Int) {
        #expect(NaiveTime(hour: h, minute: m, second: s, nanosecond: n) == nil)
    }

    @Test("NaiveTimeTests: Initialize from nanoseconds since midnight")
    func nanosSinceMidnightInit() {
        // 1 hour, 1 minute, 1 second, 1 nanosecond
        let totalNanos: Int64 = NanoSeconds.perHour64 + NanoSeconds.perMinute64 + NanoSeconds.perSecond64 + 1
        let time = NaiveTime(nanosecondsSinceMidnight: totalNanos)

        #expect(time.hour == 1)
        #expect(time.minute == 1)
        #expect(time.second == 1)
        #expect(time.nanosecond == 1)
        #expect(time.nanosecondsSinceMidnight == totalNanos)
    }

    @Test("NaiveTimeTests: Boundary nanoseconds")
    func nanosBoundaries() {
        let midnight = NaiveTime(nanosecondsSinceMidnight: 0)
        #expect(midnight.hour == 0)

        let lastNano = NaiveTime(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)
        #expect(lastNano.hour == 23)
        #expect(lastNano.minute == 59)
        #expect(lastNano.second == 59)
        #expect(lastNano.nanosecond == 999_999_999)
    }

    @Test("NaiveTimeTests: Component to Nanos round-trip")
    func roundTrip() {
        let hour = 14
        let month = 45
        let second = 30
        let nanosecond = 123_456

        let time1 = NaiveTime(hour: hour, minute: month, second: second, nanosecond: nanosecond)!
        let time2 = NaiveTime(nanosecondsSinceMidnight: time1.nanosecondsSinceMidnight)

        #expect(time1 == time2)
        #expect(time2.hour == hour)
        #expect(time2.nanosecond == nanosecond)
    }

    @Test("NaiveTimeTests: NaiveTime.now() basic validation")
    func timeNow() {
        let now = NaiveTime.now()

        // Sanity check: hour and minute must be within standard clock bounds
        #expect(now.hour >= 0 && now.hour <= 23)
        #expect(now.minute >= 0 && now.minute <= 59)
        #expect(now.second >= 0 && now.second <= 59)
    }

    @Test("NaiveTimeTests: now(in:) reflects specific offsets")
    func timeNowWithOffset() {
        // We use UTC and a +1 hour offset
        let utc = FixedOffset.utc
        let plusOne = FixedOffset(.hours(1))

        let timeUTC = NaiveTime.now(in: utc)
        let timePlus1 = NaiveTime.now(in: plusOne)

        // Convert to total seconds for easy comparison
        let totalSecondsUTC = Int64(timeUTC.hour) * 3600 + Int64(timeUTC.minute) * 60 + Int64(timeUTC.second)
        let totalSecondsPlus1 = Int64(timePlus1.hour) * 3600 + Int64(timePlus1.minute) * 60 + Int64(timePlus1.second)

        // Logic: (Plus1 - UTC) mod 24h should be exactly 3600 seconds
        // Adding 86400 before modulo handles the midnight wrap-around safely
        let diff = (totalSecondsPlus1 - totalSecondsUTC + 86400) % 86400
        #expect(diff == 3600)
    }

    @Test("NaiveTimeTests: Consistency across TimeZoneProtocol")
    func protocolConsistency() {
        let systemZone = SystemTimeZone()

        // The two calls should produce virtually identical results
        let time1 = NaiveTime.now() // uses default internal SystemTimeZone
        let time2 = NaiveTime.now(in: systemZone) // uses explicit protocol

        // We allow for a 1-second drift in case the clock ticked during execution
        let total1 = time1.nanosecondsSinceMidnight
        let total2 = time2.nanosecondsSinceMidnight
        let drift = abs(total1 - total2)

        #expect(drift < NanoSeconds.perSecond64)
    }

    @Test("NaiveTimeTests: Boundary constants integrity")
    func boundaries() {
        // Ensure constants can be initialized without crashing
        let minTime = NaiveTime.min
        let maxTime = NaiveTime.max

        #expect(minTime.nanosecondsSinceMidnight == 0)
        #expect(maxTime.nanosecondsSinceMidnight == NanoSeconds.perDay64 - 1)

        // Verify max time components (should be 23:59:59.999999999)
        #expect(maxTime.hour == 23)
        #expect(maxTime.minute == 59)
        #expect(maxTime.second == 59)
    }
}

// MARK: - Comparison Tests

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Strict inequality across time boundaries", arguments: [
        // Different Hours
        (NaiveTime(hour: 9, minute: 59, second: 59)!, NaiveTime(hour: 10, minute: 0, second: 0)!),
        // Different Minutes
        (NaiveTime(hour: 14, minute: 30, second: 59)!, NaiveTime(hour: 14, minute: 31, second: 0)!),
        // Different Seconds
        (NaiveTime(hour: 23, minute: 59, second: 58)!, NaiveTime(hour: 23, minute: 59, second: 59)!),
        // Single Nanosecond difference
        (NaiveTime(nanosecondsSinceMidnight: 100), NaiveTime(nanosecondsSinceMidnight: 101)),
    ])
    func chronologicalOrder(earlier lhs: NaiveTime, later rhs: NaiveTime) {
        #expect(lhs < rhs)
        #expect(rhs > lhs)
        #expect(lhs <= rhs)
        #expect(rhs >= lhs)
        #expect(lhs != rhs)
    }

    @Test("NaiveTimeTests: Equality properties")
    func equality() {
        let time1 = NaiveTime(hour: 12, minute: 0, second: 0)!
        let time2 = NaiveTime(hour: 12, minute: 0, second: 0)!

        #expect(time1 == time2)
        #expect(!(time1 < time2))
        #expect(!(time1 > time2))
        #expect(time1 <= time2)
        #expect(time1 >= time2)
    }

    @Test("NaiveTimeTests: Sorting a timeline")
    func sorting() {
        let morning = NaiveTime(hour: 8, minute: 0, second: 0)!
        let noon = NaiveTime(hour: 12, minute: 0, second: 0)!
        let afternoon = NaiveTime(hour: 15, minute: 30, second: 0)!
        let night = NaiveTime(hour: 23, minute: 59, second: 59)!

        let unsorted = [afternoon, morning, night, noon]
        let sorted = unsorted.sorted()

        #expect(sorted == [morning, noon, afternoon, night])
    }

    @Test("NaiveTimeTests: Time range validation")
    func ranges() {
        let openingTime = NaiveTime(hour: 9, minute: 0, second: 0)!
        let closingTime = NaiveTime(hour: 17, minute: 0, second: 0)!
        let businessHours = openingTime ... closingTime

        let lunchTime = NaiveTime(hour: 12, minute: 30, second: 0)!
        let midnight = NaiveTime(hour: 0, minute: 0, second: 0)!

        #expect(businessHours.contains(lunchTime))
        #expect(businessHours.contains(openingTime))
        #expect(businessHours.contains(closingTime))
        #expect(!businessHours.contains(midnight))
    }

    @Test("NaiveTimeTests: Minimum and Maximum bounds")
    func extremes() {
        let midnight = NaiveTime(nanosecondsSinceMidnight: 0)
        let endOfDay = NaiveTime(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)

        #expect(midnight < endOfDay)

        let randomTime = NaiveTime(hour: 11, minute: 11, second: 11)!
        #expect(midnight < randomTime)
        #expect(randomTime < endOfDay)
    }
}

// MARK: - Arithmetic

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Standard seconds and minutes")
    func standardAdvance() {
        let base = NaiveTime(hour: 10, minute: 0, second: 0)!
        // Advance 1 hour, 5 minutes, 10 seconds
        let result = base.advanced(bySeconds: 3600 + 300 + 10)

        #expect(result.hour == 11)
        #expect(result.minute == 5)
        #expect(result.second == 10)
    }

    @Test("NaiveTimeTests: Sub-second nanosecond carry")
    func nanosecondCarry() {
        let base = NaiveTime(hour: 10, minute: 0, second: 0, nanosecond: 900_000_000)!
        // Add 200ms
        let result = base.advanced(bySeconds: 0, nanoseconds: 200_000_000)

        #expect(result.second == 1)
        #expect(result.nanosecond == 100_000_000)
    }

    @Test("NaiveTimeTests: Forward past midnight")
    func forwardMidnightWrap() {
        let base = NaiveTime(hour: 23, minute: 50, second: 0)!
        // Add 15 minutes (900 seconds)
        let result = base.advanced(bySeconds: 900)

        #expect(result.hour == 0)
        #expect(result.minute == 5)
    }

    @Test("NaiveTimeTests: Backward past midnight")
    func backwardMidnightWrap() {
        let base = NaiveTime(hour: 0, minute: 10, second: 0)!
        // Subtract 20 minutes (-1200 seconds)
        let result = base.advanced(bySeconds: -1200)

        #expect(result.hour == 23)
        #expect(result.minute == 50)
    }

    @Test("NaiveTimeTests: Multiple days advancement")
    func multiDayWrap() {
        let base = NaiveTime(hour: 12, minute: 0, second: 0)!
        // Add 48 hours (2 full days)
        let result = base.advanced(bySeconds: 48 * 3600)

        #expect(result.hour == 12, "Should wrap back to exactly the same time")
    }

    @Test("NaiveTimeTests: Advanced by Duration")
    func durationInterface() {
        let base = NaiveTime(hour: 12, minute: 0, second: 0)!
        let duration = Duration(seconds: 3661, nanoseconds: 500_000_000) // 1h 1m 1.5s

        let result = base.advanced(by: duration)

        #expect(result.hour == 13)
        #expect(result.minute == 1)
        #expect(result.second == 1)
        #expect(result.nanosecond == 500_000_000)
    }
}

// MARK: - Addition

extension NaiveTimeTests {
    @Test("NaiveTimeTests: DateTime + Duration")
    func additionPointDuration() {
        let time = NaiveTime(hour: 14, minute: 30, second: 0)!
        let delta = Duration(seconds: 3600) // 1 hour

        let result = time + delta

        #expect(result.hour == 15)
        #expect(result.minute == 30)
    }

    @Test("NaiveTimeTests: Duration + DateTime (Commutative)")
    func additionDurationPoint() {
        let delta = Duration(seconds: 60) // 1 minute
        let time = NaiveTime(hour: 8, minute: 0, second: 0)!

        let result = delta + time

        #expect(result.hour == 8)
        #expect(result.minute == 1)
    }

    @Test("NaiveTimeTests: Wrap around midnight")
    func additionWrap() {
        let time = NaiveTime(hour: 23, minute: 59, second: 59)!
        let delta = Duration(seconds: 2)

        let result = time + delta

        #expect(result.hour == 0)
        #expect(result.minute == 0)
        #expect(result.second == 1)
    }

    @Test("NaiveTimeTests: Mutating addition")
    func compoundAddition() {
        var time = NaiveTime(hour: 12, minute: 0, second: 0)!
        let delta = Duration(seconds: 1800) // 30 minutes

        time += delta

        #expect(time.hour == 12)
        #expect(time.minute == 30)
    }

    @Test("NaiveTimeTests: Multiple mutations")
    func multipleMutations() {
        var time = NaiveTime(hour: 0, minute: 0, second: 0)!
        let hour = Duration(seconds: 3600)

        time += hour
        time += hour

        #expect(time.hour == 2)
    }
}

// MARK: - Substraction

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Standard subtraction")
    func subtraction() {
        let time = NaiveTime(hour: 12, minute: 0, second: 0)!
        let delta = Duration(seconds: 3600) // 1 hour

        let result = time - delta

        #expect(result.hour == 11)
        #expect(result.minute == 0)
    }

    @Test("NaiveTimeTests: Sub-second borrow")
    func subSecondBorrow() {
        let time = NaiveTime(hour: 10, minute: 0, second: 1, nanosecond: 0)!
        // Subtract 0.5 seconds
        let delta = Duration(seconds: 0, nanoseconds: 500_000_000)

        let result = time - delta

        #expect(result.hour == 10)
        #expect(result.second == 0)
        #expect(result.nanosecond == 500_000_000)
    }

    @Test("NaiveTimeTests: Backward wrap across midnight")
    func testBackwardMidnightWrap() {
        let time = NaiveTime(hour: 0, minute: 0, second: 1)!
        // Subtract 2 seconds (Should go to 23:59:59)
        let delta = Duration(seconds: 2)

        let result = time - delta

        #expect(result.hour == 23)
        #expect(result.minute == 59)
        #expect(result.second == 59)
    }

    @Test("NaiveTimeTests: Mutating subtraction")
    func compoundSubtraction() {
        var time = NaiveTime(hour: 1, minute: 0, second: 0)!
        let delta = Duration(seconds: 3600) // 1 hour

        time -= delta

        #expect(time.hour == 0)
        #expect(time.minute == 0)
    }

    @Test("NaiveTimeTests: Multiple backward wraps")
    func largeNegativeDelta() {
        var time = NaiveTime(hour: 12, minute: 0, second: 0)!
        // Subtract 25 hours (Should be 11:00 AM)
        let delta = Duration(seconds: 25 * 3600)

        time -= delta

        #expect(time.hour == 11)
        #expect(time.minute == 0)
    }
}

// MARK: - 12-Hour Clock Tests

extension NaiveTimeTests {
    @Test("NaiveTimeTests: 12-hour clock conversion", arguments: [
        (0, false, 12), // Midnight
        (1, false, 1), // 1 AM
        (11, false, 11), // 11 AM
        (12, true, 12), // Noon
        (13, true, 1), // 1 PM
        (23, true, 11), // 11 PM
    ])
    func hour12Conversion(hour24: Int, expectedIsPM: Bool, expectedHour12: Int) {
        let time = NaiveTime(hour: hour24, minute: 0, second: 0)!
        let result = time.hour12

        #expect(result.isPM == expectedIsPM, "Hour \(hour24) PM status mismatch")
        #expect(result.hour == expectedHour12, "Hour \(hour24) 12-hour value mismatch")
    }
}

// MARK: - Seconds Calculation Tests

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Total seconds from midnight", arguments: [
        (0, 0, 0, 0),
        (0, 0, 1, 1),
        (0, 1, 0, 60),
        (1, 0, 0, 3600),
        (23, 59, 59, 86399),
    ])
    func totalSeconds(h: Int, m: Int, s: Int, expectedSeconds: Int) {
        let time = NaiveTime(hour: h, minute: m, second: s)!
        #expect(time.secondsFromMidnight == expectedSeconds)
    }
}

// MARK: - Modification (with...) Tests

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Modify hour component")
    func modifyHour() {
        let base = NaiveTime(hour: 10, minute: 30, second: 0)!

        // Valid
        let newTime = base.with(hour: 22)
        #expect(newTime?.hour == 22)
        #expect(newTime?.minute == 30) // Ensure other components persist

        // Invalid
        #expect(base.with(hour: 24) == nil)
        #expect(base.with(hour: -1) == nil)
    }

    @Test("NaiveTimeTests: Modify minute component")
    func modifyMinute() {
        let base = NaiveTime(hour: 10, minute: 30, second: 0)!

        #expect(base.with(minute: 59)?.minute == 59)
        #expect(base.with(minute: 0)?.minute == 0)
        #expect(base.with(minute: 60) == nil)
    }

    @Test("NaiveTimeTests: Modify second component")
    func modifySecond() {
        let base = NaiveTime(hour: 10, minute: 30, second: 30)!

        #expect(base.with(second: 45)?.second == 45)
        #expect(base.with(second: 60) == nil)
    }

    @Test("NaiveTimeTests: Modify nanosecond component")
    func modifyNanosecond() {
        let base = NaiveTime(hour: 10, minute: 30, second: 0, nanosecond: 500)!

        #expect(base.with(nanosecond: 999_999_999)?.nanosecond == 999_999_999)
        #expect(base.with(nanosecond: -1) == nil)
        #expect(base.with(nanosecond: 1_000_000_000) == nil)
    }
}

// MARK: - Rounding Tests

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Truncate subseconds", arguments: [
        // (Original Nanos, Digits, Expected Nanos)
        (123_456_789, 0, 0), // Truncate to whole second
        (123_456_789, 3, 123_000_000), // Truncate to milliseconds
        (123_456_789, 6, 123_456_000), // Truncate to microseconds
        (123_456_789, 9, 123_456_789), // No change at 9 digits
    ])
    func truncatePrecision(nanos: Int, digits: Int, expected: Int) {
        let time = NaiveTime(hour: 0, minute: 0, second: 0, nanosecond: nanos)!
        let truncated = time.truncateSubseconds(digits)
        #expect(truncated.nanosecond == expected)
    }

    @Test("NaiveTimeTests: Round subseconds (Half-Up)", arguments: [
        // Rounding to Milliseconds (3 digits, span = 1,000,000)
        (123_400_000, 3, 123_000_000),
        (123_500_000, 3, 124_000_000),
        (123_600_000, 3, 124_000_000),

        // Rounding to Microseconds (6 digits, span = 1,000)
        (123_456_499, 6, 123_456_000),
        (123_456_500, 6, 123_457_000),

        // Rounding to nearest second (0 digits, span = 1,000,000,000)
        (499_999_999, 0, 0),
        (500_000_000, 0, 1_000_000_000) // Correctly results in 1 second, 0 nanos
    ])
    func roundPrecision(nanos: Int, digits: Int, expectedTotalNanos: Int64) {
        // 1. Create the input time (at 00:00:00.nanos)
        let time = NaiveTime(hour: 0, minute: 0, second: 0, nanosecond: nanos)!

        // 2. Perform the rounding
        let rounded = time.roundSubseconds(digits)

        // 3. Create the expected time using the total nanoseconds
        // This allows 1,000,000,000 to correctly become 00:00:01.000000000
        let expectedTime = NaiveTime(nanosecondsSinceMidnight: expectedTotalNanos)

        #expect(rounded == expectedTime)

        // Additional check to see the "carry" in action for the last case
        if expectedTotalNanos == 1_000_000_000 {
            #expect(rounded.second == 1)
            #expect(rounded.nanosecond == 0)
        }
    }

    @Test("NaiveTimeTests: Rounding at the end of the day wrap-around")
    func roundingBoundary() {
        // 23:59:59.600...
        let nearlyMidnight = NaiveTime(hour: 23, minute: 59, second: 59, nanosecond: 600_000_000)!

        // Rounding to 0 digits (nearest second)
        let rounded = nearlyMidnight.roundSubseconds(0)

        // It should now be exactly Midnight (00:00:00) instead of crashing
        #expect(rounded.nanosecondsSinceMidnight == 0)
        #expect(rounded.hour == 0)
        #expect(rounded.minute == 0)
        #expect(rounded.second == 0)
    }

    @Test("NaiveTimeTests: Truncation at the end of the day does not wrap")
    func truncationBoundary() {
        let nearlyMidnight = NaiveTime(hour: 23, minute: 59, second: 59, nanosecond: 999_999_999)!

        // Truncating always goes down, so it stays within the same second/day
        let truncated = nearlyMidnight.truncateSubseconds(0)

        #expect(truncated.hour == 23)
        #expect(truncated.second == 59)
        #expect(truncated.nanosecond == 0)
    }
}

// MARK: - Naive Date Time Conversion

extension NaiveTimeTests {
    @Test("NaiveTimeTests: Convert using NaiveDate object")
    func toDateTimeWithDateObject() {
        let baseTime = NaiveTime(hour: 14, minute: 15, second: 30, nanosecond: 500)!
        let date = NaiveDate(year: 2025, month: 12, day: 25)!
        let dt = baseTime.on(date)

        #expect(dt.time == baseTime)
        #expect(dt.date == date)
        #expect(dt.year == 2025)
        #expect(dt.hour == 14)
    }

    @Test("NaiveTimeTests: Convert using days since epoch", arguments: [
        (0, 1970, 1, 1), // Epoch
        (20082, 2024, 12, 25), // Christmas 2024
        (-1, 1969, 12, 31) // Day before epoch
    ])
    func toDateTimeWithDays(days: Int64, expY: Int32, expM: Int, expD: Int) {
        let baseTime = NaiveTime(hour: 14, minute: 15, second: 30, nanosecond: 500)!
        let dt = baseTime.on(daysSinceEpoch: days)

        #expect(dt.time == baseTime)
        #expect(dt.year == expY)
        #expect(dt.month == expM)
        #expect(dt.day == expD)
    }

    @Test("NaiveTimeTests: Convert using valid year/month/day components")
    func toDateTimeWithValidComponents() {
        let baseTime = NaiveTime(hour: 14, minute: 15, second: 30, nanosecond: 500)!
        // Testing the (Int32, Int, Int) overload
        let dt = baseTime.on(year: 2024, month: 2, day: 29)

        #expect(dt != nil)
        #expect(dt!.year == 2024)
        #expect(dt!.month == 2)
        #expect(dt!.day == 29)
        #expect(dt!.time == baseTime)
    }

    @Test("NaiveTimeTests: Convert using invalid date components returns nil", arguments: [
        (2025, 2, 29), // Not a leap year
        (2025, 13, 1), // Invalid month
        (2025, 1, 32) // Invalid day
    ])
    func toDateTimeWithInvalidComponents(year: Int32, month: Int, day: Int) {
        let baseTime = NaiveTime(hour: 14, minute: 15, second: 30, nanosecond: 500)!
        let result = baseTime.on(year: year, month: month, day: day)
        #expect(result == nil)
    }

    @Test("NaiveTimeTests: Convert using UInt8 month/day components")
    func toDateTimeWithUInt8Components() {
        let baseTime = NaiveTime(hour: 14, minute: 15, second: 30, nanosecond: 500)!
        // Testing the (Int32, UInt8, UInt8) overload
        let month: UInt8 = 10
        let day: UInt8 = 31
        let dt = baseTime.on(year: 2025, month: month, day: day)

        #expect(dt!.month == 10)
        #expect(dt!.day == 31)
    }
}
