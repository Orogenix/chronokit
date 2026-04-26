@testable import ChronoCore
import ChronoMath
import Testing

struct PlainDateTimeTests {
    // MARK: - Initialization Tests

    @Test("PlainDateTimeTests: Initialize from existing PlainDate and PlainTime object")
    func componentInit() {
        let date = PlainDate(year: 2025, month: 12, day: 25)!
        let time = PlainTime(hour: 10, minute: 30, second: 0)!
        let dateTime = PlainDateTime(date: date, time: time)

        #expect(dateTime.date == date)
        #expect(dateTime.time == time)
        #expect(dateTime.date.year == 2025)
        #expect(dateTime.date.month == 12)
        #expect(dateTime.date.day == 25)
        #expect(dateTime.time.hour == 10)
        #expect(dateTime.time.minute == 30)
        #expect(dateTime.time.second == 0)
        #expect(dateTime.time.nanosecond == 0)
    }

    @Test("PlainDateTimeTests: Initialize from raw components (Failable)", arguments: [
        (2025, 1, 1, 0, 0, 0, 0),
        (2024, 2, 29, 23, 59, 59, 999_999_999), // Leap year boundary
        (1970, 1, 1, 12, 0, 0, 0)
    ])
    // swiftlint:disable:next function_parameter_count
    func validRawInit(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        nanosecond: Int,
    ) {
        let dateTime = PlainDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond,
        )

        #expect(dateTime != nil)
        #expect(dateTime!.date.year == year)
        #expect(dateTime!.date.month == month)
        #expect(dateTime!.date.day == day)
        #expect(dateTime!.time.hour == hour)
        #expect(dateTime!.time.minute == minute)
        #expect(dateTime!.time.second == second)
        #expect(dateTime!.time.nanosecond == nanosecond)
    }

    @Test("PlainDateTimeTests: Raw initialization returns nil for invalid components", arguments: [
        (2025, 2, 29, 12, 0, 0, 0), // Invalid Date (not leap year)
        (2025, 1, 1, 24, 0, 0, 0), // Invalid Time (24h)
        (2025, 13, 1, 12, 0, 0, 0), // Invalid Month
        (2025, 1, 1, 12, 60, 0, 0) // Invalid Minute
    ])
    // swiftlint:disable:next function_parameter_count
    func invalidRawInit(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        nanosecond: Int,
    ) {
        let dateTime = PlainDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond,
        )
        #expect(dateTime == nil)
    }

    @Test("PlainDateTimeTests: Boundary constants")
    func boundaries() {
        #expect(PlainDateTime.min.date == PlainDate.min)
        #expect(PlainDateTime.min.time == PlainTime.min)
        #expect(PlainDateTime.max.date == PlainDate.max)
        #expect(PlainDateTime.max.time == PlainTime.max)
    }
}

// MARK: - Comparison Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Comparing same date, different times")
    func sameDateDifferentTimes() {
        let date = PlainDate(year: 2025, month: 6, day: 15)!
        let morning = PlainTime(hour: 8, minute: 0, second: 0)!
        let evening = PlainTime(hour: 20, minute: 0, second: 0)!

        let dt1 = PlainDateTime(date: date, time: morning)
        let dt2 = PlainDateTime(date: date, time: evening)

        #expect(dt1 < dt2, "Earlier time on same day should be lesser")
        #expect(dt2 > dt1, "Later time on same day should be greater")
    }

    @Test("PlainDateTimeTests: Comparing different dates (Date priority)")
    func differentDates() {
        let jan1 = PlainDate(year: 2025, month: 1, day: 1)!
        let jan2 = PlainDate(year: 2025, month: 1, day: 2)!

        // Late night on Jan 1st
        let dt1 = PlainDateTime(date: jan1, time: PlainTime(hour: 23, minute: 59, second: 59)!)
        // Early morning on Jan 2nd
        let dt2 = PlainDateTime(date: jan2, time: PlainTime(hour: 0, minute: 0, second: 1)!)

        #expect(dt1 < dt2, "Even with a later time, the earlier date must be lesser")
        #expect(dt2 > dt1)
    }

    @Test("PlainDateTimeTests: Comparing identity equality")
    func equalityComparison() {
        let dt1 = PlainDateTime(year: 2025, month: 12, day: 25, hour: 12, minute: 0, second: 0)!
        let dt2 = PlainDateTime(year: 2025, month: 12, day: 25, hour: 12, minute: 0, second: 0)!

        #expect(!(dt1 < dt2), "Equal values should not be less than each other")
        #expect(!(dt1 > dt2), "Equal values should not be greater than each other")
        #expect(dt1 <= dt2)
        #expect(dt1 >= dt2)
    }

    @Test("PlainDateTimeTests: Sorting across multiple years and times")
    func complexSorting() {
        let dt1 = PlainDateTime(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 0)!
        let dt2 = PlainDateTime(year: 2025, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        let dt3 = PlainDateTime(year: 2025, month: 1, day: 1, hour: 12, minute: 0, second: 0)!

        let unsorted = [dt3, dt1, dt2]
        let sorted = unsorted.sorted()

        #expect(sorted == [dt1, dt2, dt3])
    }

    @Test("PlainDateTimeTests: Extreme boundaries")
    func boundaryComparisons() {
        let minDate = PlainDate.min
        let maxDate = PlainDate.max
        let minTime = PlainTime(nanosecondsSinceMidnight: 0)
        let maxTime = PlainTime(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)

        let startOfTime = PlainDateTime(date: minDate, time: minTime)
        let endOfTime = PlainDateTime(date: maxDate, time: maxTime)

        #expect(startOfTime < endOfTime)
    }

    @Test("PlainDateTimeTests: Equality and Hashable conformance")
    func equality() {
        let dt1 = PlainDateTime(year: 2025, month: 5, day: 1, hour: 12, minute: 0, second: 0)!
        let dt2 = PlainDateTime(year: 2025, month: 5, day: 1, hour: 12, minute: 0, second: 0)!
        let dt3 = PlainDateTime(year: 2025, month: 5, day: 2, hour: 12, minute: 0, second: 0)! // Different day
        let dt4 = PlainDateTime(year: 2025, month: 5, day: 1, hour: 13, minute: 0, second: 0)! // Different hour

        #expect(dt1 == dt2)
        #expect(dt1 != dt3)
        #expect(dt1 != dt4)
        #expect(dt1.hashValue == dt2.hashValue)
        #expect(dt1.hashValue != dt3.hashValue)
    }
}

// MARK: - Arithmetic Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Within the same day")
    func standardAdvance() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 10, minute: 0, second: 0)!,
        )
        // Add 1 hour and 30 minutes
        let result = base.advanced(bySeconds: 3600 + 1800)

        #expect(result.date.day == 1)
        #expect(result.time.hour == 11)
        #expect(result.time.minute == 30)
    }

    @Test("PlainDateTimeTests: Forward across midnight")
    func forwardRollover() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 23, minute: 59, second: 50)!,
        )
        // Add 20 seconds
        let result = base.advanced(bySeconds: 20)

        #expect(result.date.day == 2)
        #expect(result.time.hour == 0)
        #expect(result.time.minute == 0)
        #expect(result.time.second == 10)
    }

    @Test("PlainDateTimeTests: Backward across midnight")
    func backwardRollover() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 2)!,
            time: PlainTime(hour: 0, minute: 0, second: 10)!,
        )
        // Subtract 20 seconds
        let result = base.advanced(bySeconds: -20)

        #expect(result.date.day == 1)
        #expect(result.time.hour == 23)
        #expect(result.time.minute == 59)
        #expect(result.time.second == 50)
    }

    @Test("PlainDateTimeTests: Multi-day leap year jump")
    func leapYearMultiDay() {
        let base = PlainDateTime(
            date: PlainDate(year: 2024, month: 2, day: 28)!,
            time: PlainTime(hour: 12, minute: 0, second: 0)!,
        )
        // Add 48 hours (2 days)
        let result = base.advanced(bySeconds: 2 * 86400)

        // 2024 is leap, so Feb 28 + 2 days = March 1
        #expect(result.date.month == 3)
        #expect(result.date.day == 1)
        #expect(result.time.hour == 12)
    }

    @Test("PlainDateTimeTests: Nanosecond overflow to days")
    func nanoOverflow() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 23, minute: 59, second: 59, nanosecond: 900_000_000)!,
        )
        // Add 200ms
        let result = base.advanced(bySeconds: 0, nanoseconds: 200_000_000)

        #expect(result.date.day == 2)
        #expect(result.time.hour == 0)
        #expect(result.time.nanosecond == 100_000_000)
    }

    @Test("PlainDateTimeTests: Advanced by Duration")
    func durationInterface() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 12, minute: 0, second: 0)!,
        )
        let duration = Duration(seconds: 86400 + 3600, nanoseconds: 0) // 1 day, 1 hour

        let result = base.advanced(by: duration)

        #expect(result.date.day == 2)
        #expect(result.time.hour == 13)
    }
}

// MARK: - Addition Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: PlainDateTime + Duration")
    func dateTimePlusDuration() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 6, day: 1)!,
            time: PlainTime(hour: 12, minute: 0, second: 0)!,
        )
        let delta = Duration(seconds: 3600) // 1 hour

        let result = base + delta

        #expect(result.time.hour == 13)
        #expect(result.date.day == 1)
    }

    @Test("PlainDateTimeTests: Duration + PlainDateTime (Commutative)")
    func durationPlusDateTime() {
        let delta = Duration(seconds: 86400) // 1 day
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 12, day: 31)!,
            time: PlainTime(hour: 10, minute: 0, second: 0)!,
        )

        // Tests the (Duration, Self) overload
        let result = delta + base

        #expect(result.date.year == 2026)
        #expect(result.date.month == 1)
        #expect(result.date.day == 1)
        #expect(result.time.hour == 10)
    }

    @Test("PlainDateTimeTests: Sub-second overflow via Duration")
    func subSecondAddition() {
        let base = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 23, minute: 59, second: 59, nanosecond: 500_000_000)!,
        )
        let delta = Duration(seconds: 0, nanoseconds: 600_000_000) // 0.6s

        let result = base + delta

        // 59.5s + 0.6s = 00.1s on the next day
        #expect(result.date.day == 2)
        #expect(result.time.hour == 0)
        #expect(result.time.second == 0)
        #expect(result.time.nanosecond == 100_000_000)
    }

    @Test("PlainDateTimeTests: In-place mutation")
    func compoundAddition() {
        var dt = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 12, minute: 0, second: 0)!,
        )
        let delta = Duration(seconds: 7200) // 2 hours

        dt += delta

        #expect(dt.time.hour == 14)

        dt += Duration(seconds: 86400) // 1 day
        #expect(dt.date.day == 2)
    }

    @Test("PlainDateTimeTests: Multiple chain rollovers")
    func multipleMutations() {
        var dt = PlainDateTime(
            date: PlainDate(year: 1999, month: 12, day: 31)!,
            time: PlainTime(hour: 23, minute: 0, second: 0)!,
        )

        dt += Duration(seconds: 3600) // Should hit midnight
        #expect(dt.date.year == 2000)
        #expect(dt.date.day == 1)
        #expect(dt.time.hour == 0)

        dt += Duration(seconds: 3600) // 1 AM
        #expect(dt.time.hour == 1)
    }

    @Test("PlainDateTimeTests: Basic addition and month-end clamping", arguments: [
        // Jan 1 + 1 month 5 days = Feb 6
        (year: 2025, month: 1, day: 1, h: 10, im: 1, id: 5, expectedDay: 6, expectedMonth: 2),
        // Jan 31 + 1 month = Feb 28 (Clamping)
        (year: 2025, month: 1, day: 31, h: 12, im: 1, id: 0, expectedDay: 28, expectedMonth: 2),
        // Feb 28 2024 (Leap) + 1 day = Feb 29
        (year: 2024, month: 2, day: 28, h: 12, im: 0, id: 1, expectedDay: 29, expectedMonth: 2),
        // Feb 28 2025 (Non-leap) + 1 day = Mar 1
        (year: 2025, month: 2, day: 28, h: 12, im: 0, id: 1, expectedDay: 1, expectedMonth: 3)
    ])
    // swiftlint:disable:next function_parameter_count
    func calendarAddition(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        intervalMonth: Int32,
        intervalDay: Int32,
        expectedDay: Int,
        expectedMonth: Int,
    ) {
        let date = PlainDate(year: year, month: month, day: day)!
        let time = PlainTime(hour: hour, minute: 0, second: 0)!
        let dt = PlainDateTime(date: date, time: time)

        let interval = CalendarInterval(month: intervalMonth, day: intervalDay, nanosecond: 0)
        let result = dt + interval

        #expect(result.date.month == expectedMonth)
        #expect(result.date.day == expectedDay)
    }

    @Test("PlainDateTimeTests: Midnight boundary overflows", arguments: [
        // 23:00 + 2 hours = Next day 01:00
        (h: 23, addH: 2, expectedDayOffset: 1, expectedHour: 1),
        // 01:00 - 2 hours = Previous day 23:00
        (h: 1, addH: -2, expectedDayOffset: -1, expectedHour: 23),
        // 12:00 + 48 hours = +2 days, 12:00
        (h: 12, addH: 48, expectedDayOffset: 2, expectedHour: 12),
        // 12:00 - 25 hours = 11:00 AM on the PREVIOUS day (-1 offset)
        (h: 12, addH: -25, expectedDayOffset: -1, expectedHour: 11)
    ])
    func midnightOverflow(h: Int, addH: Int64, expectedDayOffset: Int64, expectedHour: Int) {
        let baseDate = PlainDate(year: 2025, month: 6, day: 15)! // Mid-month to avoid month overflow
        let baseTime = PlainTime(hour: h, minute: 0, second: 0)!
        let dt = PlainDateTime(date: baseDate, time: baseTime)

        let interval = CalendarInterval.hours(addH)
        let result = dt + interval

        #expect(result.date.daysSinceEpoch == baseDate.daysSinceEpoch + expectedDayOffset)
        #expect(result.time.hour == expectedHour)
    }

    @Test("PlainDateTimeTests: Complex multi-component interval")
    func complexInterval() {
        // Start: 2025-01-31 23:00:00
        let dt = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 31)!,
            time: PlainTime(hour: 23, minute: 0, second: 0)!,
        )

        // Interval: 1 month and 2 hours
        // 1. Jan 31 + 1 month = Feb 28
        // 2. 23:00 + 2 hours = Next Day (Feb 28 + 1) at 01:00
        let interval = CalendarInterval(month: 1, day: 0, nanosecond: NanoSeconds.perHour64 * 2)
        let result = dt + interval

        #expect(result.date.year == 2025)
        #expect(result.date.month == 3) // Feb 28 + 1 day overflow = March 1
        #expect(result.date.day == 1)
        #expect(result.time.hour == 1)
    }
}

// MARK: - Substraction Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Same day, positive and negative")
    func distanceWithinDay() {
        let dt1 = PlainDateTime(year: 2025, month: 1, day: 1, hour: 12, minute: 0, second: 0)!
        let dt2 = PlainDateTime(year: 2025, month: 1, day: 1, hour: 10, minute: 0, second: 0)!

        let diff = dt1 - dt2
        #expect(diff.seconds == 7200) // 2 hours
        #expect(diff.nanoseconds == 0)

        let negativeDiff = dt2 - dt1
        #expect(negativeDiff.seconds == -7200) // Normalized: -2 hours is -7200s.
    }

    @Test("PlainDateTimeTests: Normalized nanoseconds (Borrowing from seconds)")
    func distanceNormalization() {
        let dt1 = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 10, minute: 0, second: 1,
            nanosecond: 100_000_000,
        )! // 1.1s
        let dt2 = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 10, minute: 0, second: 1,
            nanosecond: 900_000_000,
        )! // 1.9s

        let diff = dt1 - dt2 // Should be -0.8s

        // Duration logic: -1 second + 200,000,000 nanoseconds = -0.8s
        #expect(diff.seconds == -1)
        #expect(diff.nanoseconds == 200_000_000)
    }

    @Test("PlainDateTimeTests: Across day boundaries")
    func distanceAcrossDays() {
        let jan2 = PlainDateTime(year: 2025, month: 1, day: 2, hour: 1, minute: 0, second: 0)!
        let jan1 = PlainDateTime(year: 2025, month: 1, day: 1, hour: 23, minute: 0, second: 0)!

        let diff = jan2 - jan1
        #expect(diff.seconds == 7200) // 2 hours apart
    }

    @Test("PlainDateTimeTests: Subtract duration across midnight")
    func subtractDurationAcrossMidnight() {
        let dt = PlainDateTime(year: 2025, month: 1, day: 2, hour: 0, minute: 30, second: 0)!
        let delta = Duration(seconds: 3600) // 1 hour

        let result = dt - delta

        #expect(result.date.day == 1)
        #expect(result.time.hour == 23)
        #expect(result.time.minute == 30)
    }

    @Test("PlainDateTimeTests: Subtract duration across year boundary")
    func subtractDurationAcrossYear() {
        let dt = PlainDateTime(year: 2025, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        let delta = Duration(seconds: 1)

        let result = dt - delta

        #expect(result.date.year == 2024)
        #expect(result.date.month == 12)
        #expect(result.date.day == 31)
        #expect(result.time.hour == 23)
        #expect(result.time.minute == 59)
        #expect(result.time.second == 59)
    }

    @Test("PlainDateTimeTests: Mutating subtraction")
    func compoundSubtraction() {
        var dt = PlainDateTime(year: 2025, month: 1, day: 1, hour: 12, minute: 0, second: 0)!
        dt -= Duration(seconds: 86400) // 1 day

        #expect(dt.date.day == 31)
        #expect(dt.date.year == 2024)
        #expect(dt.time.hour == 12)
    }

    @Test("PlainDateTimeTests: Calendar Subtraction (Month/Day Clamping)", arguments: [
        // Mar 31 - 1 month = Feb 28 (Clamping)
        (y: 2025, m: 3, d: 31, subM: 1, subD: 0, expM: 2, expD: 28),
        // Mar 31 2024 - 1 month = Feb 29 (Leap Clamping)
        (y: 2024, m: 3, d: 31, subM: 1, subD: 0, expM: 2, expD: 29),
        // Jan 1 - 1 day = Dec 31
        (y: 2025, m: 1, d: 1, subM: 0, subD: 1, expM: 12, expD: 31),
        // Jan 1 2025 - 13 months = Dec 1 2023
        (y: 2025, m: 1, d: 1, subM: 13, subD: 0, expM: 12, expD: 1)
    ])
    // swiftlint:disable:next function_parameter_count
    func calendarSubtraction(
        y: Int32,
        m: Int,
        d: Int,
        subM: Int32,
        subD: Int32,
        expM: Int,
        expD: Int,
    ) {
        let dt = PlainDateTime(
            date: PlainDate(year: y, month: m, day: d)!,
            time: PlainTime(hour: 12, minute: 0, second: 0)!,
        )

        let interval = CalendarInterval(month: subM, day: subD, nanosecond: 0)
        let result = dt - interval

        #expect(result.date.month == expM)
        #expect(result.date.day == expD)
    }

    @Test("PlainDateTimeTests: Time Subtraction (Midnight Underflow)", arguments: [
        // 01:00 AM - 2 hours = 23:00 (Previous Day)
        (h: 1, subH: 2, expDayOffset: -1, expH: 23),
        // 12:00 PM - 24 hours = 12:00 PM (Previous Day)
        (h: 12, subH: 24, expDayOffset: -1, expH: 12),
        // 12:00 PM - 25 hours = 11:00 AM (Previous Day)
        (h: 12, subH: 25, expDayOffset: -1, expH: 11),
        // 00:00 AM - 1 nanosecond = 23:59:59.999999999 (Previous Day)
        (h: 0, subH: 0, expDayOffset: -1, expH: 23)
    ])
    func timeSubtraction(h: Int, subH: Int64, expDayOffset: Int64, expH: Int) {
        let baseDate = PlainDate(year: 2025, month: 6, day: 15)!
        let baseTime = PlainTime(hour: h, minute: 0, second: 0)!
        let dt = PlainDateTime(date: baseDate, time: baseTime)

        // Use the specific nanosecond case for the last argument
        let interval = subH == 0 && h == 0
            ? CalendarInterval(month: 0, day: 0, nanosecond: 1) // test subtracting 1ns
            : CalendarInterval.hours(subH)

        let result = dt - interval

        #expect(result.date.daysSinceEpoch == baseDate.daysSinceEpoch + expDayOffset)
        #expect(result.time.hour == expH)
    }
}

// MARK: - Era and Year Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Year CE calculation", arguments: [
        (2025, true, 2025),
        (1, true, 1),
        (0, false, 1),
        (-1, false, 2),
    ])
    func yearCE(inputYear: Int32, expectedIsCE: Bool, expectedYear: UInt32) {
        let dt = PlainDateTime(year: inputYear, month: 1, day: 1, hour: 12, minute: 0, second: 0)!
        #expect(dt.yearCE.isCE == expectedIsCE)
        #expect(dt.yearCE.year == expectedYear)
    }

    @Test("PlainDateTimeTests: Leap year property", arguments: [
        (2024, true),
        (2000, true),
        (2100, false),
        (2023, false)
    ])
    func leapYear(year: Int32, expected: Bool) {
        let dt = PlainDateTime(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        #expect(dt.isLeapYear == expected)
    }
}

// MARK: - Quarter Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Quarter calculation", arguments: [
        (1, 1), (4, 2), (7, 3), (10, 4),
    ])
    func quarters(month: Int, expectedQuarter: Int) {
        let dt = PlainDateTime(year: 2025, month: month, day: 1, hour: 12, minute: 0, second: 0)!
        #expect(dt.quarter == expectedQuarter)
    }
}

// MARK: - Month Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Month zero-based properties")
    func monthProperties() {
        let dt = PlainDateTime(year: 2025, month: 12, day: 25, hour: 10, minute: 0, second: 0)!
        #expect(dt.month == 12)
        #expect(dt.monthZeroBased == 11)
        #expect(dt.monthSymbol == .december)
    }
}

// MARK: - Weekday Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: ISO Week Consistency")
    func isoWeekCheck() {
        // Monday, Dec 29, 2025 is Week 1 of 2026
        let dt = PlainDateTime(year: 2025, month: 12, day: 29, hour: 23, minute: 59, second: 59)!
        #expect(dt.isoWeek.week == 1)
        #expect(dt.isoWeek.year == 2026)
    }

    @Test("PlainDateTimeTests: Weekday symbol check")
    func weekdaySymbol() {
        let dt = PlainDateTime(year: 2025, month: 12, day: 26, hour: 12, minute: 0, second: 0)!
        // Dec 26, 2025 is Friday (usually 5 or 6 depending on your Weekday enum start)
        #expect(dt.weekdaySymbol != nil)
        #expect(dt.weekdaySymbol?.rawValue == dt.weekday)
    }
}

// MARK: - Day and Epoch Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Unix Epoch Alignment")
    func unixEpoch() {
        let dt = PlainDateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        #expect(dt.daysSinceUnixEpoch == 0)
    }

    @Test("PlainDateTimeTests: Days in month", arguments: [
        (2024, 2, 29),
        (2025, 2, 28)
    ])
    func daysInMonth(year: Int32, month: Int, expectedDays: Int) {
        let dt = PlainDateTime(year: year, month: month, day: 1, hour: 12, minute: 0, second: 0)!
        #expect(dt.daysInMonth == expectedDays)
    }
}

// MARK: - Modification Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Modify date components preserves time")
    func modificationWith() {
        let originalTime = PlainTime(hour: 14, minute: 30, second: 15)!
        let base = PlainDateTime(date: PlainDate(year: 2023, month: 5, day: 1)!, time: originalTime)

        #expect(base.with(year: 2025)?.year == 2025)
        #expect(base.with(month: 10)?.month == 10)
        #expect(base.with(monthZeroBased: 11)!.month == 12)
        #expect(base.with(monthSymbol: .january)!.month == 1)
        #expect(base.with(day: 25)?.day == 25)
        #expect(base.with(dayZeroBased: 10)!.day == 11)

        // Ensure time remains exactly the same after date modification
        let modified = base.with(year: 2025)
        #expect(modified?.time == originalTime)
    }

    @Test("PlainDateTimeTests: Ordinal modifications")
    func ordinalModifications() {
        let dt = PlainDateTime(year: 2025, month: 1, day: 1, hour: 12, minute: 0, second: 0)!

        // Day 60 in 2025 (common) is March 1
        let mar1 = dt.with(ordinal: 60)
        #expect(mar1?.month == 3 && mar1?.day == 1)
        #expect(mar1?.time.hour == 12)

        // Ordinal zero-based
        let feb1 = dt.with(ordinalZeroBased: 31) // 32nd day
        #expect(feb1?.month == 2 && feb1?.day == 1)
    }

    @Test("PlainDateTimeTests: Invalid date modifications return nil")
    func invalidModifications() {
        let dt = PlainDateTime(year: 2025, month: 1, day: 1, hour: 12, minute: 0, second: 0)!

        // Feb 29 on non-leap year
        let feb = dt.with(month: 2)!
        #expect(feb.with(day: 29) == nil)

        // Out of bounds ordinal
        #expect(dt.with(ordinal: 400) == nil)
    }
}

// MARK: - 12-Hour Clock Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: 12-hour clock conversion", arguments: [
        (0, false, 12), // Midnight
        (1, false, 1), // 1 AM
        (12, true, 12), // Noon
        (13, true, 1), // 1 PM
        (23, true, 11), // 11 PM
    ])
    func hour12Conversion(hour24: Int, expectedIsPM: Bool, expectedHour12: Int) {
        let date = PlainDate(year: 2025, month: 12, day: 25)!
        let time = PlainTime(hour: hour24, minute: 0, second: 0)!
        let dt = PlainDateTime(date: date, time: time)

        #expect(dt.hour12.isPM == expectedIsPM)
        #expect(dt.hour12.hour == expectedHour12)
    }
}

// MARK: - Seconds Calculation Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Total seconds from midnight", arguments: [
        (0, 0, 0, 0),
        (1, 0, 0, 3600),
        (23, 59, 59, 86399),
    ])
    func totalSeconds(h hour: Int, m minute: Int, s second: Int, expectedSeconds: Int) {
        let dt = PlainDateTime(
            year: 2025,
            month: 1,
            day: 1,
            hour: hour,
            minute: minute,
            second: second,
        )!
        #expect(dt.secondsFromMidnight == expectedSeconds)
    }
}

// MARK: - Time Modification (Date Preservation)

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Modify hour component preserves date")
    func modifyHour() {
        let originalDate = PlainDate(year: 2025, month: 5, day: 20)!
        let base = PlainDateTime(date: originalDate, time: PlainTime(hour: 10, minute: 30, second: 0)!)

        let modified = base.with(hour: 22)

        #expect(modified?.hour == 22)
        #expect(modified?.date == originalDate, "Date must not change")
        #expect(modified?.minute == 30, "Ensure other time components persist")
        #expect(base.with(hour: 24) == nil)
    }

    @Test("PlainDateTimeTests: Modify minute component preserves date")
    func modifyMinute() {
        let originalDate = PlainDate(year: 2025, month: 1, day: 1)!
        let base = PlainDateTime(date: originalDate, time: PlainTime(hour: 10, minute: 30, second: 0)!)

        let modified = base.with(minute: 45)

        #expect(modified?.minute == 45)
        #expect(modified?.date == originalDate)
        #expect(base.with(minute: 60) == nil)
    }

    @Test("PlainDateTimeTests: Modify second component preserves date")
    func modifySecond() {
        let originalDate = PlainDate(year: 2025, month: 1, day: 1)!
        let base = PlainDateTime(date: originalDate, time: PlainTime(hour: 10, minute: 30, second: 30)!)

        let modified = base.with(second: 0)

        #expect(modified?.second == 0)
        #expect(modified?.date == originalDate)
        #expect(base.with(second: -1) == nil)
    }

    @Test("PlainDateTimeTests: Modify nanosecond component preserves date")
    func modifyNanosecond() {
        let originalDate = PlainDate(year: 2025, month: 1, day: 1)!
        let base = PlainDateTime(date: originalDate, time: PlainTime(hour: 10, minute: 0, second: 0, nanosecond: 500)!)

        let modified = base.with(nanosecond: 123_456_789)

        #expect(modified?.nanosecond == 123_456_789)
        #expect(modified?.date == originalDate)
        #expect(base.with(nanosecond: 1_000_000_000) == nil)
    }
}

// MARK: - Subsecond Rounding Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Truncate subseconds", arguments: [
        (123_456_789, 0, 0), // To whole second
        (123_456_789, 3, 123_000_000), // To milliseconds
        (123_456_789, 6, 123_456_000), // To microseconds
    ])
    func truncateSubseconds(nanos: Int, digits: Int, expectedNanos: Int) {
        let dt = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 10, minute: 0, second: 0,
            nanosecond: nanos,
        )!
        let truncated = dt.truncateSubseconds(digits)

        #expect(truncated.year == 2025)
        #expect(truncated.nanosecond == expectedNanos)
    }

    @Test("PlainDateTimeTests: Round subseconds (Half-Up)", arguments: [
        (123_400_000, 3, 123_000_000, 0), // Down
        (123_500_000, 3, 124_000_000, 0), // Midpoint Up
        (499_999_999, 0, 0, 0), // Down to 0 seconds
        (500_000_000, 0, 0, 1) // Up to 1 second
    ])
    func roundSubseconds(nanos: Int, digits: Int, expectedNanos: Int, expectedSec: Int) {
        let dt = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 0, minute: 0, second: 0,
            nanosecond: nanos,
        )!
        let rounded = dt.roundSubseconds(digits)

        #expect(rounded.second == expectedSec)
        #expect(rounded.nanosecond == expectedNanos)
    }

    @Test("PlainDateTimeTests: Truncation at end of day stays on same date")
    func truncationAtEndDay() {
        let endOfDay = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 23, minute: 59, second: 59,
            nanosecond: 999_999_999,
        )!

        let truncated = endOfDay.truncateSubseconds(0)

        #expect(truncated.day == 1) // Stays on Jan 1
        #expect(truncated.hour == 23)
        #expect(truncated.nanosecond == 0)
    }

    @Test("PlainDateTimeTests: Rounding up at end of day increments date")
    func roundingAtEndDay() {
        // 2025-12-31 at 23:59:59.600
        let endOfYear = PlainDateTime(
            year: 2025, month: 12, day: 31,
            hour: 23, minute: 59, second: 59,
            nanosecond: 600_000_000,
        )!

        // Rounding to 0 digits (nearest second) should push it to the next year
        let rounded = endOfYear.roundSubseconds(0)

        #expect(rounded.year == 2026)
        #expect(rounded.month == 1)
        #expect(rounded.day == 1)
        #expect(rounded.hour == 0)
        #expect(rounded.minute == 0)
        #expect(rounded.second == 0)
        #expect(rounded.nanosecond == 0)
    }

    @Test("PlainDateTimeTests: Rounding precision at 9 digits is a no-op")
    func maxPrecision() {
        let dt = PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 12, minute: 0, second: 0,
            nanosecond: 123,
        )!
        let result = dt.roundSubseconds(9)

        #expect(result == dt)
    }
}

// MARK: - Instant Conversion Tests

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: toInstantUTC conversion")
    func toInstantUTC() {
        // Unix Epoch: 1970-01-01 00:00:00
        let epoch = PlainDateTime(
            year: 1970, month: 1, day: 1,
            hour: 0, minute: 0, second: 0,
        )!
        let instant = epoch.instantUTC

        #expect(instant.seconds == 0)
        #expect(instant.nanoseconds == 0)

        // Random date: 2025-12-25 15:30:45.123
        let dt = PlainDateTime(
            year: 2025, month: 12, day: 25,
            hour: 15, minute: 30, second: 45,
            nanosecond: 123_000_000,
        )!
        let instant2 = dt.instantUTC

        // Calculation: (daysSinceEpoch * 86400) + secondsOfDay
        let expectedSeconds = (dt.date.daysSinceEpoch * Seconds.perDay64)
            + (15 * Seconds.perHour64 + 30 * Seconds.perMinute64 + 45)
        #expect(instant2.seconds == expectedSeconds)
        #expect(instant2.nanoseconds == 123_000_000)
    }

    // MARK: - Fixed Offset Conversion

    @Test("PlainDateTimeTests: toInstant with FixedOffset", arguments: [
        (0, 0), // UTC
        (7 * 3600, -25200), // UTC+7 (Plain is ahead, so UTC is 7 hours behind)
        (-5 * 3600, 18000) // UTC-5 (Plain is behind, so UTC is 5 hours ahead)
    ])
    func toInstantWithOffset(offsetSeconds: Int, expectedInstantSeconds: Int64) {
        let dt = PlainDateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        let offset = FixedOffset(seconds: offsetSeconds)

        let instant = dt.instant(offset: offset)
        #expect(instant.seconds == expectedInstantSeconds)
    }

    // MARK: - TimeZone and DST Conversion

    @Test("PlainDateTimeTests: toInstant with complex TimeZone policy")
    func toInstantWithTimeZone() {
        // Mock a timezone that has a gap (Spring Forward) or overlap (Fall Back)
        // For this test, assume a simple timezone protocol implementation
        let dt = PlainDateTime(year: 2024, month: 3, day: 10, hour: 10, minute: 0, second: 0)!
        let mockTZ = MockTimeZone(offset: 3600) // UTC+1

        // Policy: .earlier
        let instant = dt.instant(in: mockTZ, resolving: .preferEarlier)

        #expect(instant != nil)
        // 10:00:00 at UTC+1 is 09:00:00 UTC
        let expectedSeconds = (dt.date.daysSinceEpoch * 86400) + (10 * 3600) - 3600
        #expect(instant?.seconds == Int64(expectedSeconds))
    }

    @Test("PlainDateTimeTests: returns nil when DST policy fails to resolve")
    func toInstantNilResolution() {
        let dt = PlainDateTime(year: 2024, month: 3, day: 10, hour: 2, minute: 30, second: 0)!
        let invalidMockTZ = MockInvalidTimeZone() // Always fails to resolve

        let instant = dt.instant(in: invalidMockTZ, resolving: .preferEarlier)
        #expect(instant == nil)
    }
}

// MARK: - Date Time Conversion

extension PlainDateTimeTests {
    @Test("PlainDateTimeTests: Convert to DateTime<UTC>")
    func toDateTimeUTC() {
        let plain = PlainDateTime(year: 2025, month: 12, day: 25, hour: 15, minute: 30, second: 0)!
        let zonedUTC = plain.dateTimeUTC

        // The components should match exactly because UTC has 0 offset
        #expect(zonedUTC.year == 2025)
        #expect(zonedUTC.month == 12)
        #expect(zonedUTC.day == 25)
        #expect(zonedUTC.hour == 15)
    }

    @Test("PlainDateTimeTests: Convert to DateTime with FixedOffset", arguments: [
        7 * 3600, // UTC+7
        -5 * 3600, // UTC-5
        0 // UTC+0
    ])
    func toDateTimeWithOffset(offsetSeconds: Int) {
        let plain = PlainDateTime(year: 2025, month: 6, day: 1, hour: 10, minute: 0, second: 0)!
        let offset = FixedOffset(seconds: offsetSeconds)

        let zoned = plain.dateTime(offset: offset)

        // A conversion from Plain to Zoned via its own offset
        // should result in the same "wall clock" time.
        #expect(zoned.hour == 10)
        #expect(zoned.minute == 0)
        #expect(zoned.timezone.duration.seconds == offsetSeconds)
    }

    @Test("PlainDateTimeTests: Convert using complex TimeZoneProtocol")
    func toDateTimeWithTimeZone() {
        let plain = PlainDateTime(year: 2024, month: 3, day: 10, hour: 10, minute: 0, second: 0)!
        let mockTZ = MockTimeZone(offset: 3600) // UTC+1

        guard let zoned = plain.dateTime(timezone: mockTZ) else {
            Issue.record("DateTime conversion failed")
            return
        }

        #expect(zoned.hour == 10)
        #expect(zoned.year == 2024)
        #expect(
            zoned.timestamp == plain.instantUTC.timestamp - 3600,
            "The underlying instant should shift correctly (10:00 plain at +1 is 09:00 UTC)",
        )
    }

    @Test("PlainDateTimeTests: returns nil if TimeZone cannot resolve the plain time")
    func toDateTimeNilResolution() {
        let plain = PlainDateTime(year: 2024, month: 3, day: 10, hour: 2, minute: 30, second: 0)!
        let invalidTZ = MockInvalidTimeZone() // Mocking a DST gap where 2:30 doesn't exist

        let zoned = plain.dateTime(timezone: invalidTZ)

        #expect(zoned == nil)
    }
}
