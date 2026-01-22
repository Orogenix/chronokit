@testable import ChronoCore
import Testing

@Suite("Date Time Tests")
struct DateTimeTests {
    // MARK: - Initialization

    @Test("DateTimeTests: Basic initialization preserves instant and timezone")
    func initialization() {
        let instant = Instant(seconds: 1_735_171_200, nanoseconds: 0) // 2024-12-26
        let timezone = FixedOffset(seconds: 3600) // UTC+1

        let dt = DateTime(instant: instant, timezone: timezone)

        #expect(dt.instant == instant)
        #expect(dt.timezone == timezone)
    }

    @Test("DateTimeTests: Works with different TimeZoneProtocol implementations")
    func genericTypes() {
        let instant = Instant(seconds: 0, nanoseconds: 0)

        // Test with UTC
        let utcDT = DateTime(instant: instant, timezone: FixedOffset.utc)
        #expect(utcDT.timezone.identifier == "UTC")

        // Test with FixedOffset
        let offsetDT = DateTime(instant: instant, timezone: FixedOffset(.hours(-5)))
        #expect(offsetDT.timezone.duration == .hours(-5))

        // Test with a Mock
        let mockTZ = MockTimeZone(offset: 3600)
        let mockDT = DateTime(instant: instant, timezone: mockTZ)
        #expect(mockDT.timezone.identifier == "MockTZ")
    }

    @Test("DateTimeTests: System vs Fixed")
    func typeSafety() {
        let systemDT = DateTime<SystemTimeZone>.now()
        let fixedDT = DateTime<FixedOffset>.nowUTC

        // Verifying type identities
        #expect(type(of: systemDT.timezone) == SystemTimeZone.self)
        #expect(type(of: fixedDT.timezone) == FixedOffset.self)
    }

    @Test("DateTimeTests: System and Fixed Now")
    func constructors() {
        let now = DateTime<SystemTimeZone>.now()
        let manualNow = DateTime.now(in: SystemTimeZone())

        // Ensure they captured roughly the same time
        let diff = abs(now.instant.seconds - manualNow.instant.seconds)
        #expect(diff < 2)

        let fixed = DateTime<FixedOffset>.now(in: .hours(7))
        #expect(fixed.timezone.offset(for: fixed.instant) == .hours(7))
    }

    @Test("DateTimeTests: System to Fixed Snapshot")
    func fixedOffsetSnapshot() {
        let systemTime = DateTime<SystemTimeZone>.now()

        // Capture a snapshot
        let fixedSnapshot = systemTime.fixedOffset()

        // The Instant must remain identical
        #expect(systemTime.instant == fixedSnapshot.instant)

        // The type must be FixedOffset
        #expect(type(of: fixedSnapshot.timezone) == FixedOffset.self)

        // The value must match the system's offset at that moment
        let currentSysOffset = systemTime.timezone.offset(for: systemTime.instant)
        #expect(fixedSnapshot.timezone.offset(for: fixedSnapshot.instant) == .seconds(currentSysOffset.seconds))
    }

    @Test("DateTimeTests: Timezone Identifier consistency")
    func identifierConsistency() {
        let sys = SystemTimeZone()
        let dt = DateTime<SystemTimeZone>.now()

        #expect(dt.timezone.identifier == sys.identifier)
        #expect(!dt.timezone.identifier.isEmpty)
    }

    @Test("DateTimeTests: Parameterized Fixed Offsets", arguments: [
        0, 3600, -3600, 18000, -18000
    ])
    func parameterizedOffsets(seconds: Int) {
        let offset = FixedOffset(.seconds(Int64(seconds)))
        let dt = DateTime.now(in: offset)

        #expect(dt.timezone.offset(for: dt.instant) == .seconds(seconds))
    }
}

// MARK: - Comparison Tests

extension DateTimeTests {
    @Test("DateTimeTests: Comparison is based on absolute Instant, not local time")
    func absoluteComparison() {
        // Instant at 12:00:00 UTC
        let instant1 = Instant(seconds: 3600 * 12, nanoseconds: 0)
        // Instant at 13:00:00 UTC
        let instant2 = Instant(seconds: 3600 * 13, nanoseconds: 0)

        // London (UTC+0) at 12:00
        let london = DateTime(instant: instant1, timezone: FixedOffset.utc)
        // Berlin (UTC+1) at 14:00 (which is 13:00 UTC)
        let berlin = DateTime(instant: instant2, timezone: FixedOffset(seconds: 3600))

        // Even though Berlin's "wall clock" says 14:00 and London says 12:00,
        // London is EARLIER because its UTC instant is smaller.
        #expect(london < berlin)
        #expect(berlin > london)
    }

    @Test("DateTimeTests: Different timezones representing the same UTC moment")
    func sameInstantDifferentZones() {
        let now = Instant(seconds: 1_735_243_200, nanoseconds: 0)

        let nyc = DateTime(instant: now, timezone: FixedOffset(seconds: -18000)) // UTC-5
        let tokyo = DateTime(instant: now, timezone: FixedOffset(seconds: 32400)) // UTC+9

        #expect(!(nyc < tokyo))
        #expect(!(tokyo < nyc))
    }

    @Test("DateTimeTests: Sub-second comparison")
    func subsecondComparison() {
        let base = Instant(seconds: 100, nanoseconds: 500)
        let slightlyLater = Instant(seconds: 100, nanoseconds: 501)

        let dt1 = DateTime(instant: base, timezone: FixedOffset.utc)
        let dt2 = DateTime(instant: slightlyLater, timezone: FixedOffset.utc)

        #expect(dt1 < dt2)
    }

    @Test("DateTimeTests: Equality when TZ is Equatable")
    func equality() {
        let i1 = Instant(seconds: 100)
        let i2 = Instant(seconds: 10)
        let tz1 = FixedOffset(seconds: 3600)
        let tz2 = FixedOffset(seconds: 3600)
        let tz3 = FixedOffset(seconds: 0)

        let dt1 = DateTime(instant: i1, timezone: tz1)
        let dt2 = DateTime(instant: i1, timezone: tz2)
        let dt3 = DateTime(instant: i2, timezone: tz3)

        #expect(dt1 == dt2)
        #expect(dt1 != dt3)
    }

    @Test("DateTimeTests: Sorting a mixed-timezone collection")
    func sortingMixedZones() {
        let i1 = Instant(seconds: 1000)
        let i2 = Instant(seconds: 2000)
        let i3 = Instant(seconds: 3000)

        let d1 = DateTime(instant: i1, timezone: FixedOffset(seconds: 3600))
        let d2 = DateTime(instant: i2, timezone: FixedOffset(seconds: -3600))
        let d3 = DateTime(instant: i3, timezone: FixedOffset(seconds: 0))

        let unsorted = [d3, d1, d2]
        let sorted = unsorted.sorted()

        #expect(sorted.map(\.instant.seconds) == [1000, 2000, 3000])
    }
}

// MARK: - Timestamp Tests

extension DateTimeTests {
    @Test("DateTimeTests: Delegates timestamp properties to underlying Instant", arguments: [
        (1_735_171_200, 500_000_000), // Mid-day 2024
        (0, 123_456_789), // Epoch with nanos
        (-1000, 999_999_999), // Pre-epoch
    ])
    func delegation(seconds: Int64, nanoseconds: Int32) {
        let instant = Instant(seconds: seconds, nanoseconds: nanoseconds)

        // Use different timezones to ensure they don't interfere with the UTC timestamps
        let dtUTC = DateTime(instant: instant, timezone: FixedOffset.utc)
        let dtOffset = DateTime(instant: instant, timezone: FixedOffset(seconds: -18000))

        // Verify standard timestamp
        #expect(dtUTC.timestamp == instant.timestamp)
        #expect(dtOffset.timestamp == instant.timestamp)

        // Verify microsecond timestamp
        #expect(dtUTC.timestampMicroseconds == instant.timestampMicroseconds)
        #expect(dtOffset.timestampMicroseconds == instant.timestampMicroseconds)

        // Verify nanosecond timestamp
        #expect(dtUTC.timestampNanoSeconds == instant.timestampNanoseconds)
        #expect(dtOffset.timestampNanoSeconds == instant.timestampNanoseconds)
    }

    @Test("DateTimeTests: Delegates checked nanoseconds (including nil on overflow)")
    func checkedDelegation() {
        // Test valid range
        let validInstant = Instant(seconds: 100, nanoseconds: 0)
        let dtValid = DateTime(instant: validInstant, timezone: FixedOffset.utc)
        #expect(dtValid.timestampNanosecondsChecked == validInstant.timestampNanosecondsChecked)

        // Test overflow range (approx +/- 292 years from epoch for Int64 nanos)
        // 20,000,000,000 seconds is well beyond the limit.
        let overflowInstant = Instant(seconds: 20_000_000_000, nanoseconds: 0)
        let dtOverflow = DateTime(instant: overflowInstant, timezone: FixedOffset.utc)

        #expect(dtOverflow.timestampNanosecondsChecked == nil)
        #expect(dtOverflow.timestampNanosecondsChecked == overflowInstant.timestampNanosecondsChecked)
    }
}

// MARK: - Arithmetic Tests

extension DateTimeTests {
    @Test("DateTimeTests: advanced(bySeconds:nanoseconds:) preserves timezone")
    func advancedByComponents() {
        let timezone = FixedOffset(seconds: -18000) // NYC
        let start = DateTime(instant: Instant(seconds: 100, nanoseconds: 0), timezone: timezone)

        // Advance by 50.5 seconds
        let result = start.advanced(bySeconds: 50, nanoseconds: 500_000_000)

        #expect(result.instant.seconds == 150)
        #expect(result.instant.nanoseconds == 500_000_000)
        #expect(result.timezone == timezone)
    }

    @Test("DateTimeTests: advanced(by: Duration) preserves timezone")
    func advancedByDuration() {
        let timezone: FixedOffset = .utc
        let start = DateTime(instant: Instant(seconds: 1000), timezone: timezone)
        let duration = Duration(seconds: 60, nanoseconds: 0)

        let result = start.advanced(by: duration)

        #expect(result.instant.seconds == 1060)
    }

    @Test("DateTimeTests: Operator - calculates Duration between zones")
    func subtractionOperator() {
        let i1 = Instant(seconds: 2000, nanoseconds: 0)
        let i2 = Instant(seconds: 1500, nanoseconds: 500_000_000)

        let dt1 = DateTime(instant: i1, timezone: FixedOffset.utc)
        let dt2 = DateTime(instant: i2, timezone: FixedOffset(.hours(1)))

        // 2000.0 - 1500.5 = 499.5 seconds
        let diff: Duration = dt1 - dt2

        #expect(diff.seconds == 499)
        #expect(diff.nanoseconds == 500_000_000)
    }
}

// MARK: - Addition Tests

extension DateTimeTests {
    @Test("DateTimeTests: Standard forward advance")
    func dateTimePlusDuration() {
        let instant = Instant(seconds: 1000, nanoseconds: 0)
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)
        let delta = Duration(seconds: 500, nanoseconds: 500_000_000)

        let result = dt + delta

        #expect(result.instant.seconds == 1500)
        #expect(result.instant.nanoseconds == 500_000_000)
    }

    @Test("DateTimeTests: Commutative addition")
    func durationPlusDateTime() {
        let delta: Duration = .hours(1)
        let timezone: FixedOffset = .utc
        let dt = DateTime(instant: .zero, timezone: timezone)

        let result = delta + dt

        #expect(result.instant.seconds == 3600)
    }

    @Test("DateTimeTests: In-place mutation")
    func dateTimeCompoundAddition() {
        let timezone: FixedOffset = .utc
        var dt = DateTime(instant: Instant(seconds: 1000, nanoseconds: 0), timezone: timezone)
        let delta = Duration(seconds: 1, nanoseconds: 0)

        dt += delta
        dt += delta

        #expect(dt.instant.seconds == 1002)
    }

    @Test("DateTimeTests: Sub-second carry normalization")
    func dateTimeCarryNormalization() {
        let timezone: FixedOffset = .utc
        let dt = DateTime(instant: Instant(seconds: 0, nanoseconds: 800_000_000), timezone: timezone)
        let delta = Duration(seconds: 0, nanoseconds: 400_000_000)

        // 0.8s + 0.4s = 1.2s
        let result = dt + delta

        #expect(result.instant.seconds == 1)
        #expect(result.instant.nanoseconds == 200_000_000)
    }
}

// MARK: - Subtraction Tests

extension DateTimeTests {
    @Test("DateTimeTests: Different timezones")
    func distanceBetweenDifferentTimezones() {
        let utc: FixedOffset = .utc
        let est = FixedOffset(.hours(-5))
        // 1000s past epoch in UTC
        let dt1 = DateTime(instant: Instant(seconds: 1000, nanoseconds: 0), timezone: utc)
        // 1500s past epoch in Tokyo
        let dt2 = DateTime(instant: Instant(seconds: 1500, nanoseconds: 0), timezone: est)

        // The distance depends ONLY on the underlying Instant, not the TZ offset
        let diff = dt2 - dt1

        #expect(diff.seconds == 500)
        #expect(diff.nanoseconds == 0)
    }

    @Test("DateTimeTests: Negative distance with sub-second borrow")
    func negativeDistanceNormalization() {
        let utc: FixedOffset = .utc
        let dt1 = DateTime(instant: Instant(seconds: 10, nanoseconds: 100_000_000), timezone: utc)
        let dt2 = DateTime(instant: Instant(seconds: 10, nanoseconds: 500_000_000), timezone: utc)

        // 10.1s - 10.5s = -0.4s
        let diff = dt1 - dt2

        // Floored Normalization: -1s + 600ms
        #expect(diff.seconds == -1)
        #expect(diff.nanoseconds == 600_000_000)
    }

    @Test("DateTimeTests: Standard backward shift")
    func dateTimeMinusDuration() {
        let utc: FixedOffset = .utc
        let dt = DateTime(instant: Instant(seconds: 1000, nanoseconds: 0), timezone: utc)
        let delta = Duration(seconds: 100, nanoseconds: 0)

        let result = dt - delta

        #expect(result.instant.seconds == 900)
        #expect(result.timezone == utc)
    }

    @Test("DateTimeTests: Sub-second borrow")
    func dateTimeMinusDurationBorrow() {
        let utc: FixedOffset = .utc
        let dt = DateTime(instant: Instant(seconds: 10, nanoseconds: 0), timezone: utc)
        let delta = Duration(seconds: 0, nanoseconds: 100_000_000) // 0.1s

        // 10.0s - 0.1s = 9.9s
        let result = dt - delta

        #expect(result.instant.seconds == 9)
        #expect(result.instant.nanoseconds == 900_000_000)
    }

    @Test("DateTimeTests: In-place mutation")
    func dateTimeCompoundSubtraction() {
        let utc: FixedOffset = .utc
        var dt = DateTime(instant: Instant(seconds: 100, nanoseconds: 0), timezone: utc)
        let delta = Duration(seconds: 10, nanoseconds: 0)

        dt -= delta

        #expect(dt.instant.seconds == 90)
    }
}

// MARK: - Local Transformation Tests

extension DateTimeTests {
    @Test("DateTimeTests: withLocal preserves TimeZone and Time")
    func withLocalPreservation() {
        let timezone = FixedOffset(seconds: 3600) // UTC+1
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: timezone)!

        // Transform: Change only the year
        let result = dt.withLocal { $0.with(year: 2030) }!

        #expect(result.year == 2030)
        #expect(result.month == 1)
        #expect(result.day == 1)
        #expect(result.naive.time.hour == 10)
        #expect(result.timezone.offset(for: result.instant) == .hours(1))
    }

    @Test("DateTimeTests: withLocal handles nil transformations")
    func withLocalNilSafety() {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: utc)!

        // Transform: Create an invalid date (Feb 30)
        let result = dt.withLocal { $0.with(month: 2)?.with(day: 30) }

        #expect(result == nil, "Should return nil if the transformation closure returns nil")
    }

    @Test("DateTimeTests: withLocal multi-component update")
    func withLocalMultiUpdate() {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: utc)!

        // Transform: Change month and day in one go
        let result = dt.withLocal { naive in
            naive.with(month: 12)?.with(day: 25)
        }

        #expect(result?.month == 12)
        #expect(result?.day == 25)
        #expect(result?.year == 2025)
    }

    @Test("DateTimeTests: naiveLocal reflects timezone offset")
    func naiveLocalOffset() {
        // 12:00 PM UTC
        let instant = Instant(seconds: 43200, nanoseconds: 0)
        let timezone = FixedOffset(seconds: -3600) // UTC-1

        let dt = DateTime(instant: instant, timezone: timezone)

        // Wall clock should be 11:00 AM
        #expect(dt.naive.time.hour == 11)
        #expect(dt.naive.date.daysSinceEpoch == 0)
    }
}

// MARK: - DST Resolution Tests (Mocked)

extension DateTimeTests {
    @Test("DateTimeTests: withLocal applies resolution policy")
    func withLocalPolicy() {
        let utc: FixedOffset = .utc
        // Note: This test becomes much more powerful when using a TimeZone
        // that actually has gaps/overlaps. For FixedOffset, policy has no effect.
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: utc)!

        // We can't easily spy on the policy without a MockTimeZone,
        // but we verify the parameter is accepted.
        let result = dt.withLocal(resolving: .preferLater) { $0.with(day: 2) }!

        #expect(result.day == 2)
    }

    @Test("DateTimeTests: Returns nil when landing in a DST gap")
    func gapResolution() {
        let gapTZ = MockGapTimeZone()
        // Start with a valid time (doesn't matter what, the mock always returns .invalid)
        let dt = DateTime(instant: Instant(seconds: 0, nanoseconds: 0), timezone: gapTZ)

        // Try to modify the date. Because the mock says the result is .invalid,
        // withLocal must return nil.
        let result = dt.withLocal { $0.with(day: 2) }

        #expect(result == nil)
    }

    @Test("DateTimeTests: Respects .earlier policy in ambiguous time")
    func ambiguousEarlier() {
        let ambTZ = MockAmbiguousTimeZone(earlierOffset: 7200, laterOffset: 3600)
        let dt = DateTime(instant: Instant(seconds: 0, nanoseconds: 0), timezone: ambTZ)

        // Force the local time to be exactly "Epoch Midnight" (0 seconds from Epoch)
        let result = dt.withLocal(resolving: .preferEarlier) { _ in
            NaiveDateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        }

        // Local(0) - Offset(7200) = -7200
        #expect(result?.instant.seconds == -7200)
    }

    @Test("DateTimeTests: Respects .later policy in ambiguous time")
    func ambiguousLater() {
        let ambTZ = MockAmbiguousTimeZone(earlierOffset: 7200, laterOffset: 3600)
        let dt = DateTime(instant: Instant(seconds: 0, nanoseconds: 0), timezone: ambTZ)

        // Force the local time to be exactly "Epoch Midnight"
        let result = dt.withLocal(resolving: .preferLater) { _ in
            NaiveDateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        }

        // Local(0) - Offset(3600) = -3600
        #expect(result?.instant.seconds == -3600)
    }
}

// MARK: - Era and Year Tests

extension DateTimeTests {
    @Test("DateTimeTests: Year and Leap Year via protocol", arguments: [
        (2024, true),
        (2025, false),
    ])
    func yearAndLeapProperties(inputYear: Int32, expectedLeap: Bool) {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: inputYear, month: 1, day: 1, hour: 0, timezone: utc)!

        #expect(dt.year == inputYear)
        #expect(dt.isLeapYear == expectedLeap)
    }
}

// MARK: - Month and Quarter Tests

extension DateTimeTests {
    @Test("DateTimeTests: Month and Quarter delegation", arguments: [
        (1, 1, 0, Month.january),
        (4, 2, 3, Month.april),
        (12, 4, 11, Month.december),
    ])
    func monthAndQuarter(month: Int, quarter: Int, zeroBased: Int, symbol: Month) {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: month, day: 1, hour: 12, timezone: utc)!

        #expect(dt.month == month)
        #expect(dt.quarter == quarter)
        #expect(dt.monthZeroBased == zeroBased)
        #expect(dt.monthSymbol == symbol)
    }
}

// MARK: - Weekday and Ordinal Tests

extension DateTimeTests {
    @Test("DateTimeTests: Day and Ordinal properties")
    func dayAndOrdinal() {
        let utc: FixedOffset = .utc
        // Feb 1, 2025 is the 32nd day
        let dt = DateTime(year: 2025, month: 2, day: 1, hour: 10, timezone: utc)!

        #expect(dt.day == 1)
        #expect(dt.ordinal == 32)
        #expect(dt.weekdaySymbol != nil)
    }

    @Test("DateTimeTests: ISO Week via protocol")
    func isoWeekCheck() {
        let utc: FixedOffset = .utc
        // Monday, Dec 29, 2025 is Week 1 of 2026
        let dt = DateTime(year: 2025, month: 12, day: 29, hour: 12, timezone: utc)!
        #expect(dt.isoWeek.week == 1)
        #expect(dt.isoWeek.year == 2026)
    }
}

// MARK: - Modification Tests

extension DateTimeTests {
    @Test("DateTimeTests: Component modification preserves TimeZone and Time")
    func modificationWith() {
        let timezone = FixedOffset(seconds: -18000) // EST
        let base = DateTime(year: 2023, month: 5, day: 1, hour: 14, minute: 30, timezone: timezone)!

        // Test basic component modification
        let yr25 = base.with(year: 2025)!
        #expect(yr25.year == 2025)
        #expect(yr25.timezone.offset(for: yr25.instant) == .hours(-5))
        #expect(yr25.naive.time.hour == 14)

        // Test month symbols and zero-based
        #expect(base.with(monthSymbol: .august)?.month == 8)
        #expect(base.with(monthZeroBased: 0)?.month == 1)

        // Test day modification
        let day25 = base.with(day: 25)
        #expect(day25?.day == 25)
        #expect(day25?.naive.time.minute == 30)
    }

    @Test("DateTimeTests: Ordinal modifications")
    func ordinalModifications() {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 9, timezone: utc)!

        // Day 60 in 2025 (common) is March 1
        let mar1 = dt.with(ordinal: 60)!
        #expect(mar1.month == 3 && mar1.day == 1)

        // Zero-based ordinal (31 = day 32 = Feb 1)
        let feb1 = dt.with(ordinalZeroBased: 31)!
        #expect(feb1.month == 2 && feb1.day == 1)
    }

    @Test("DateTimeTests: Invalid protocol modifications return nil")
    func invalidModifications() {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 2, day: 1, hour: 12, timezone: utc)!

        // Feb 29 on non-leap year
        #expect(dt.with(day: 29) == nil)

        // Invalid month
        #expect(dt.with(month: 13) == nil)

        // Out of bounds ordinal
        #expect(dt.with(ordinal: 367) == nil)
    }
}

// MARK: - 12-Hour Clock Tests

extension DateTimeTests {
    @Test("DateTimeTests: 12-hour clock conversion", arguments: [
        (0, false, 12), // Midnight
        (1, false, 1), // 1 AM
        (12, true, 12), // Noon
        (13, true, 1), // 1 PM
        (23, true, 11), // 11 PM
    ])
    func hour12Conversion(hour24: Int, expectedIsPM: Bool, expectedHour12: Int) {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 12, day: 25, hour: hour24, timezone: utc)!

        #expect(dt.hour12.isPM == expectedIsPM)
        #expect(dt.hour12.hour == expectedHour12)
    }
}

// MARK: - Seconds Calculation Tests

extension DateTimeTests {
    @Test("DateTimeTests: Total seconds from midnight", arguments: [
        (0, 0, 0, 0),
        (1, 0, 0, 3600),
        (23, 59, 59, 86399),
    ])
    func totalSeconds(h hour: Int, m minute: Int, s second: Int, expectedSeconds: Int) {
        let utc: FixedOffset = .utc
        let dt = DateTime(
            year: 2025,
            month: 1,
            day: 1,
            hour: hour,
            minute: minute,
            second: second,
            timezone: utc,
        )!

        #expect(dt.secondsFromMidnight == expectedSeconds)
    }
}

// MARK: - Time Modification (Context Preservation)

extension DateTimeTests {
    @Test("DateTimeTests: Modify hour component preserves date and timezone")
    func modifyHour() {
        let timezone = FixedOffset(.hours(-5)) // EST
        let base = DateTime(year: 2025, month: 5, day: 20, hour: 10, minute: 30, timezone: timezone)!

        let modified = base.with(hour: 22)!

        #expect(modified.hour == 22)
        #expect(modified.day == 20, "Date must not change")
        #expect(modified.minute == 30, "Other time components must persist")
        #expect(modified.timezone.offset(for: modified.instant) == .hours(-5), "Timezone must be preserved")

        // Validation: 24 is out of bounds for NaiveTime
        #expect(base.with(hour: 24) == nil)
    }

    @Test("DateTimeTests: Modify minute component preserves context")
    func modifyMinute() {
        let utc: FixedOffset = .utc
        let base = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 30, timezone: utc)!

        let modified = base.with(minute: 45)!

        #expect(modified.minute == 45)
        #expect(modified.hour == 10)
        #expect(modified.day == 1)
        #expect(base.with(minute: 60) == nil)
    }

    @Test("DateTimeTests: Modify second component preserves context")
    func modifySecond() {
        let utc: FixedOffset = .utc
        let base = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 30, second: 30, timezone: utc)!

        let modified = base.with(second: 0)!

        #expect(modified.second == 0)
        #expect(modified.minute == 30)
        #expect(base.with(second: -1) == nil)
    }

    @Test("DateTimeTests: Modify nanosecond component preserves context")
    func modifyNanosecond() {
        let utc: FixedOffset = .utc
        let base = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: utc)!

        let modified = base.with(nanosecond: 500_000_000)!

        #expect(modified.nanosecond == 500_000_000)
        #expect(modified.hour == 10)
        #expect(base.with(nanosecond: 1_000_000_000) == nil)
    }
}

// MARK: - Subsecond Rounding

extension DateTimeTests {
    @Test("DateTimeTests: Truncate subseconds to varying precision", arguments: [
        (123_456_789, 0, 0), // Truncate all
        (123_456_789, 3, 123_000_000), // Truncate to milliseconds
        (123_456_789, 6, 123_456_000), // Truncate to microseconds
        (123_456_789, 9, 123_456_789), // No change at max precision
    ])
    func truncation(nanoseconds: Int, digits: Int, expected: Int) {
        let utc: FixedOffset = .utc
        let dt = DateTime(
            instant: Instant(seconds: 1000, nanoseconds: Int32(nanoseconds)),
            timezone: utc,
        )

        let result = dt.truncateSubseconds(digits)

        #expect(result.nanosecond == expected)
        #expect(result.instant.seconds == 1000, "Seconds should never change during truncation")
        #expect(result.timezone == utc, "Timezone must be preserved")
    }

    @Test("DateTimeTests: Round subseconds (Half-up)", arguments: [
        (123_500_000, 3, 124_000_000), // Round .1235 up to .124
        (123_400_000, 3, 123_000_000), // Round .1234 down to .123
        (999_999_999, 0, 0), // Rounding .999 to 0 digits moves to next second
    ])
    func rounding(nanoseconds: Int, digits: Int, expectedNano: Int) {
        let utc: FixedOffset = .utc
        let dt = DateTime(
            instant: Instant(seconds: 1000, nanoseconds: Int32(nanoseconds)),
            timezone: utc,
        )

        let result = dt.roundSubseconds(digits)

        #expect(result.nanosecond == expectedNano)

        // Edge case: check if rounding up pushed us to the next second
        if nanoseconds == 999_999_999, digits == 0 {
            #expect(result.instant.seconds == 1001)
        }
    }

    @Test("DateTimeTests: Rounding preserves local wall-clock alignment")
    func roundingAlignment() {
        let timezone = FixedOffset(.hours(-1)) // UTC-1
        // 10:00:00.750 Local
        let dt = DateTime(
            year: 2025, month: 1, day: 1,
            hour: 10, minute: 0, second: 0, nanosecond: 750_000_000,
            timezone: timezone,
        )!

        let rounded = dt.roundSubseconds(0)

        #expect(rounded.hour == 10)
        #expect(rounded.minute == 0)
        #expect(rounded.second == 1)
        #expect(rounded.nanosecond == 0)
        #expect(rounded.timezone.offset(for: rounded.instant) == .hours(-1))
    }
}

// MARK: - Duration Rounding

extension DateTimeTests {
    @Test("DateTimeTests: Truncate by duration quanta", arguments: [
        (45, 15, 45), // 10:45 snapped to 15m -> 10:45
        (50, 15, 45), // 10:50 snapped to 15m -> 10:45
        (59, 30, 30), // 10:59 snapped to 30m -> 10:30
    ])
    func truncationQuanta(minute: Int, quantumMin: Int, expectedMin: Int) throws {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: minute, timezone: utc)!
        let quantum = Duration(seconds: Int64(quantumMin * 60))

        let result = try dt.truncate(byQuantum: quantum)

        #expect(result.minute == expectedMin)
        #expect(result.second == 0)
        #expect(result.timezone == utc)
    }

    @Test("DateTimeTests: Round to nearest duration")
    func roundingNearest() throws {
        let quantum = Duration(seconds: 3600) // 1 hour
        let utc: FixedOffset = .utc

        // 10:29:59 -> 10:00:00
        let early = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 29, second: 59, timezone: utc)!
        let roundedDown = try early.round(byQuantum: quantum)
        #expect(roundedDown.hour == 10)

        // 10:30:00 -> 11:00:00 (Half-up)
        let middle = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 30, second: 0, timezone: utc)!
        let roundedUp = try middle.round(byQuantum: quantum)
        #expect(roundedUp.hour == 11)
    }

    @Test("DateTimeTests: Round up to next quantum")
    func roundingUp() throws {
        let quantum = Duration(seconds: 900) // 15 minutes
        let utc: FixedOffset = .utc

        // 10:00:01 -> 10:15:00
        let base = DateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 0, second: 1, timezone: utc)!
        let result = try base.roundUp(byQuantum: quantum)

        #expect(result.minute == 15)
        #expect(result.second == 0)
    }

    @Test("DateTimeTests: Throws error for invalid quantum")
    func invalidQuantum() {
        let utc: FixedOffset = .utc
        let dt = DateTime(year: 2025, month: 1, day: 1, hour: 10, timezone: utc)!

        // Quantum of zero or negative should throw
        #expect(throws: TimeRoundingError.self) {
            try dt.round(byQuantum: .zero)
        }
    }
}
