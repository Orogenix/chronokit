@testable import ChronoCore
import ChronoMath
import Testing

struct PlainDateTests {
    // MARK: - Initialization Tests

    @Test("PlainDateTests: Initialize from daysSinceEpoch")
    func daysSinceEpochInitialization() {
        let date = PlainDate(daysSinceEpoch: 0)
        #expect(date.year == 1970, "Year should be as expected")
        #expect(date.month == 1, "Month should be as expected")
        #expect(date.day == 1, "Day should be as expected")
    }

    @Test("PlainDateTests: Initialize from valid YMD components (Int & UInt8)", arguments: [
        (2025, 1, 31),
        (2024, 2, 29),
        (2000, 2, 29),
        (1900, 2, 28) // Not a leap year
    ])
    func validYMDInitialization(year: Int32, month: Int, day: Int) {
        let dateInt = PlainDate(year: year, month: month, day: day)
        let dateUInt8 = PlainDate(year: year, month: UInt8(month), day: UInt8(day))

        #expect(dateInt != nil)
        #expect(dateUInt8 != nil)
        #expect(dateInt == dateUInt8)
        #expect(dateInt?.year == year)
        #expect(dateInt?.month == month)
        #expect(dateInt?.day == day)
    }

    @Test("PlainDateTests: Initialize from invalid components returns nil", arguments: [
        (2025, 13, 1), // Invalid month
        (2025, 2, 29), // 2025 is not a leap year
        (2024, 2, 30), // Feb 30 never exists
        (2025, 4, 31), // April has 30 days
        (2025, 0, 1), // Month out of range
        (2025, 1, 0) // Day out of range
    ])
    func invalidYMDInitialization(year: Int32, month: Int, day: Int) {
        #expect(PlainDate(year: year, month: month, day: day) == nil)
    }

    @Test("PlainDateTests: Initialize from leap year", arguments: [
        (2020, 2, 29),
        (2024, 2, 29),
        (2028, 2, 29),
    ])
    func invalidYMDInitialization(year: Int32, month: UInt8, day: UInt8) {
        #expect(
            PlainDate(year: year, month: month, day: day) != nil,
            "Dates should be valid",
        )
    }

    @Test("PlainDateTests: Component to daysSinceEpoch round-trip")
    func roundTrip() {
        let leapDay = PlainDate(year: 2024, month: 2, day: 29)!
        let roundTrip = PlainDate(daysSinceEpoch: leapDay.daysSinceEpoch)
        #expect(roundTrip == leapDay)
    }

    @Test("PlainDateTests: Boundary constants integrity")
    func boundaries() {
        // Accessing these ensures no initialization crashes
        let minDate: PlainDate = .min
        let maxDate: PlainDate = .max

        #expect(minDate.daysSinceEpoch == CalendarConstants.minInputDay)
        #expect(maxDate.daysSinceEpoch == CalendarConstants.maxInputDay)

        // Verify the math spans roughly the Int32 year range you targeted
        #expect(minDate.year <= -2_000_000_000)
        #expect(maxDate.year >= 2_000_000_000)
    }
}

// MARK: - Comparison Tests

extension PlainDateTests {
    @Test("PlainDateTests: Strict inequality across component boundaries", arguments: [
        // Different Years
        (PlainDate(year: 2023, month: 12, day: 31)!, PlainDate(year: 2024, month: 1, day: 1)!),
        // Different Months
        (PlainDate(year: 2024, month: 2, day: 28)!, PlainDate(year: 2024, month: 3, day: 1)!),
        // Different Days
        (PlainDate(year: 2024, month: 6, day: 15)!, PlainDate(year: 2024, month: 6, day: 16)!),
        // Leap Year specific
        (PlainDate(year: 2024, month: 2, day: 29)!, PlainDate(year: 2024, month: 3, day: 1)!),
    ])
    func strictInequality(lhs: PlainDate, rhs: PlainDate) {
        #expect(lhs < rhs)
        #expect(rhs > lhs)
        #expect(lhs != rhs)
        #expect(!(lhs > rhs))
        #expect(!(rhs < lhs))
    }

    @Test("PlainDateTests: Equality and reflexive properties")
    func equality() {
        let lhs = PlainDate(year: 2025, month: 5, day: 1)!
        let rhs = PlainDate(year: 2025, month: 5, day: 1)!

        #expect(lhs == rhs)
        #expect(lhs <= rhs)
        #expect(lhs >= rhs)
        #expect(!(lhs < rhs))
        #expect(!(lhs > rhs))
    }

    @Test("PlainDateTests: Sorting a collection of dates")
    func sorting() {
        let d1 = PlainDate(year: 1990, month: 1, day: 1)!
        let d2 = PlainDate(year: 2000, month: 5, day: 10)!
        let d3 = PlainDate(year: 2024, month: 2, day: 29)!
        let d4 = PlainDate(year: 2024, month: 12, day: 31)!

        let unsorted = [d3, d1, d4, d2]
        let sorted = unsorted.sorted()

        #expect(sorted == [d1, d2, d3, d4])
    }

    @Test("PlainDateTests: Range and boundary check")
    func ranges() {
        let start = PlainDate(year: 2025, month: 1, day: 1)!
        let mid = PlainDate(year: 2025, month: 5, day: 10)!
        let end = PlainDate(year: 2025, month: 12, day: 31)!

        let yearRange = start ... end

        #expect(yearRange.contains(mid))
        #expect(yearRange.contains(start))
        #expect(yearRange.contains(end))
        #expect(!yearRange.contains(PlainDate(year: 2024, month: 12, day: 31)!))
        #expect(!yearRange.contains(PlainDate(year: 2026, month: 1, day: 1)!))
    }

    @Test("PlainDateTests: Extreme boundaries (Min/Max)")
    func extremeBoundaries() {
        let minDate: PlainDate = .min
        let maxDate: PlainDate = .max

        #expect(minDate < maxDate)
        #expect(minDate != maxDate)

        let middle = PlainDate(year: 2000, month: 1, day: 1)!
        #expect(minDate < middle)
        #expect(maxDate > middle)
    }
}

// MARK: - Arithmetic Tests

extension PlainDateTests {
    @Test("PlainDateTests: Within the same month")
    func standardAdvance() {
        let base = PlainDate(year: 2025, month: 1, day: 1)!
        let result = base.advanced(byDays: 10)

        #expect(result.year == 2025)
        #expect(result.month == 1)
        #expect(result.day == 11)
    }

    @Test("PlainDateTests: Across month boundary")
    func monthBoundary() {
        let base = PlainDate(year: 2025, month: 1, day: 31)!
        let result = base.advanced(byDays: 1)

        #expect(result.year == 2025)
        #expect(result.month == 2)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: Across year boundary")
    func yearBoundary() {
        let base = PlainDate(year: 2025, month: 12, day: 31)!
        let result = base.advanced(byDays: 1)

        #expect(result.year == 2026)
        #expect(result.month == 1)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: Leap year Feb 28 to 29")
    func leapYearAdvance() {
        // 2024 was a leap year
        let base = PlainDate(year: 2024, month: 2, day: 28)!
        let result = base.advanced(byDays: 1)

        #expect(result.month == 2)
        #expect(result.day == 29)

        let nextDay = result.advanced(byDays: 1)
        #expect(nextDay.month == 3)
        #expect(nextDay.day == 1)
    }

    @Test("PlainDateTests: Common year Feb 28 to March 1")
    func commonYearAdvance() {
        // 2025 is not a leap year
        let base = PlainDate(year: 2025, month: 2, day: 28)!
        let result = base.advanced(byDays: 1)

        #expect(result.month == 3)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: Negative days (Backward)")
    func negativeAdvance() {
        let base = PlainDate(year: 2025, month: 1, day: 1)!
        let result = base.advanced(byDays: -1)

        #expect(result.year == 2024)
        #expect(result.month == 12)
        #expect(result.day == 31)
    }

    @Test("PlainDateTests: Crossing the Epoch (1970-01-01)")
    func epochCrossing() {
        let epoch = PlainDate(daysSinceEpoch: 0) // 1970-01-01
        let result = epoch.advanced(byDays: -1)

        #expect(result.year == 1969)
        #expect(result.month == 12)
        #expect(result.day == 31)
        #expect(result.daysSinceEpoch == -1)
    }

    @Test("PlainDateTests: Chained mutations")
    func chainedMutations() {
        var dt = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 1)!,
            time: PlainTime(hour: 0, minute: 0, second: 0)!,
        )

        dt += CalendarInterval.days(1)
        dt += CalendarInterval.hours(12)
        dt -= CalendarInterval.minutes(30)

        #expect(dt.date.day == 2)
        #expect(dt.time.hour == 11)
        #expect(dt.time.minute == 30)
    }
}

// MARK: - Addition Tests

extension PlainDateTests {
    @Test("PlainDateTests: Date + Int64")
    func datePlusInt() {
        let base = PlainDate(year: 2025, month: 1, day: 1)!
        let result = base + 31 // Move forward 31 days

        #expect(result.month == 2)
        #expect(result.day == 1)
        #expect(result.year == 2025)
    }

    @Test("PlainDateTests: Int64 + Date (Commutative)")
    func intPlusDate() {
        let days: Int64 = 7
        let base = PlainDate(year: 2025, month: 12, day: 25)!

        // This tests the (Int64, Self) overload
        let result = days + base

        #expect(result.year == 2026)
        #expect(result.month == 1)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: Large additions")
    func largeAddition() {
        let base = PlainDate(year: 2024, month: 1, day: 1)!
        let result = base + 366 // 2024 is a leap year

        #expect(result.year == 2025)
        #expect(result.month == 1)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: In-place mutation")
    func compoundAddition() {
        var date = PlainDate(year: 2025, month: 5, day: 20)!
        date += 11 // Should move to May 31

        #expect(date.day == 31)
        #expect(date.month == 5)

        date += 1 // Should move to June 1
        #expect(date.month == 6)
        #expect(date.day == 1)
    }

    @Test("PlainDateTests: Multiple chain mutations")
    func multipleMutations() {
        var date = PlainDate(year: 2000, month: 1, day: 1)!
        let increments: Int64 = 366 // 2000 was a leap year

        date += increments
        date += 1

        #expect(date.year == 2001)
        #expect(date.month == 1)
        #expect(date.day == 2)
    }

    @Test("PlainDateTests: Month and Year Normalization", arguments: [
        // Basic: Add 1 month to Jan -> Feb
        (y: 2025, m: 1, d: 1, addM: 1, addD: 0, expY: 2025, expM: 2, expD: 1),
        // Year wrap: Dec + 1 month -> Jan next year
        (y: 2025, m: 12, d: 1, addM: 1, addD: 0, expY: 2026, expM: 1, expD: 1),
        // Large month addition: +25 months (2 years, 1 month)
        (y: 2025, m: 1, d: 1, addM: 25, addD: 0, expY: 2027, expM: 2, expD: 1),
        // Negative month: Jan - 1 month -> Dec previous year
        (y: 2025, m: 1, d: 1, addM: -1, addD: 0, expY: 2024, expM: 12, expD: 1),
        // Deep negative: Jan 2025 - 24 months -> Jan 2023
        (y: 2025, m: 1, d: 1, addM: -24, addD: 0, expY: 2023, expM: 1, expD: 1)
    ])
    // swiftlint:disable:next function_parameter_count
    func monthNormalization(
        y: Int32,
        m: Int,
        d: Int,
        addM: Int32,
        addD: Int32,
        expY: Int32,
        expM: Int,
        expD: Int,
    ) {
        let date = PlainDate(year: y, month: m, day: d)!
        let interval = CalendarInterval(month: addM, day: addD)
        let result = date + interval

        #expect(result.year == expY)
        #expect(result.month == expM)
        #expect(result.day == expD)
    }

    @Test("PlainDateTests: Saturating / Clamping Logic", arguments: [
        // Jan 31 + 1 month -> Feb 28 (Common Year)
        (y: 2025, m: 1, d: 31, addM: 1, expM: 2, expD: 28),
        // Jan 31 + 1 month -> Feb 29 (Leap Year)
        (y: 2024, m: 1, d: 31, addM: 1, expM: 2, expD: 29),
        // Aug 31 - 1 month -> July 31 (No clamping needed)
        (y: 2025, m: 8, d: 31, addM: -1, expM: 7, expD: 31),
        // May 31 - 1 month -> April 30 (Clamping)
        (y: 2025, m: 5, d: 31, addM: -1, expM: 4, expD: 30)
    ])
    // swiftlint:disable:next function_parameter_count
    func dayClamping(
        y: Int32,
        m: Int,
        d: Int,
        addM: Int32,
        expM: Int,
        expD: Int,
    ) {
        let date = PlainDate(year: y, month: m, day: d)!
        let interval = CalendarInterval.months(addM)
        let result = date + interval

        #expect(result.month == expM)
        #expect(result.day == expD)
    }

    @Test("PlainDateTests: Day Addition Overflowing Months", arguments: [
        // Feb 28 + 1 day -> March 1
        (y: 2025, m: 2, d: 28, addD: 1, expY: 2025, expM: 3, expD: 1),
        // Dec 31 + 1 day -> Jan 1 next year
        (y: 2025, m: 12, d: 31, addD: 1, expY: 2026, expM: 1, expD: 1),
        // Jan 1 + 40 days -> Feb 10
        (y: 2025, m: 1, d: 1, addD: 40, expY: 2025, expM: 2, expD: 10)
    ])
    // swiftlint:disable:next function_parameter_count
    func dayOverflow(
        y: Int32,
        m: Int,
        d: Int,
        addD: Int32,
        expY: Int32,
        expM: Int,
        expD: Int,
    ) {
        let date = PlainDate(year: y, month: m, day: d)!
        let interval = CalendarInterval.days(addD)
        let result = date + interval

        #expect(result.year == expY)
        #expect(result.month == expM)
        #expect(result.day == expD)
    }

    @Test("PlainDateTests: Order of Operations (Months then Days)")
    func orderOfOperations() {
        // Start: Jan 30
        // If we add 1 Month then 1 Day:
        // 1. Jan 30 + 1 Month = Feb 28 (Clamped)
        // 2. Feb 28 + 1 Day = March 1
        let date = PlainDate(year: 2025, month: 1, day: 30)!
        let interval = CalendarInterval(month: 1, day: 1)

        let result = date + interval

        #expect(result.month == 3)
        #expect(result.day == 1)
    }

    @Test("PlainDateTests: In-place addition (+=) correctly updates state")
    func inPlaceAddition() {
        // Start at 2025-01-31 23:00
        var dt = PlainDateTime(
            date: PlainDate(year: 2025, month: 1, day: 31)!,
            time: PlainTime(hour: 23, minute: 0, second: 0)!,
        )

        // Add 1 month and 2 hours
        // 1. Month addition: Feb 28 (Clamped)
        // 2. Hour addition: 23:00 + 2h = 01:00 (Next Day)
        // Result should be March 1, 01:00
        let interval = CalendarInterval(month: 1, day: 0, nanosecond: 2 * NanoSeconds.perHour64)

        dt += interval

        #expect(dt.date.year == 2025)
        #expect(dt.date.month == 3)
        #expect(dt.date.day == 1)
        #expect(dt.time.hour == 1)
    }
}

// MARK: - Substraction Tests

extension PlainDateTests {
    @Test("PlainDateTests: Subtract days within same month")
    func subtractDays() {
        let base = PlainDate(year: 2025, month: 1, day: 15)!
        let result = base - 10

        #expect(result.day == 5)
        #expect(result.month == 1)
    }

    @Test("PlainDateTests: Subtract across month and year boundaries")
    func subtractAcrossBoundaries() {
        let jan1 = PlainDate(year: 2025, month: 1, day: 1)!
        let result = jan1 - 1 // Should be Dec 31, 2024

        #expect(result.year == 2024)
        #expect(result.month == 12)
        #expect(result.day == 31)
    }

    @Test("PlainDateTests: Distance between dates")
    func dateDistance() {
        let start = PlainDate(year: 2025, month: 1, day: 1)!
        let end = PlainDate(year: 2025, month: 1, day: 11)!

        let diff = end - start
        #expect(diff == 10)

        let negativeDiff = start - end
        #expect(negativeDiff == -10)
    }

    @Test("PlainDateTests: Leap year distance")
    func leapYearDistance() {
        let feb28 = PlainDate(year: 2024, month: 2, day: 28)!
        let march1 = PlainDate(year: 2024, month: 3, day: 1)!

        // 2024 is a leap year, so there is Feb 29 in between
        #expect(march1 - feb28 == 2)
    }

    @Test("PlainDateTests: Mutating subtraction")
    func compoundSubtraction() {
        var date = PlainDate(year: 2025, month: 2, day: 1)!
        date -= 1 // Move to Jan 31

        #expect(date.month == 1)
        #expect(date.day == 31)
        #expect(date.year == 2025)
    }

    @Test("PlainDateTests: Large backward mutation")
    func largeMutation() {
        var date = PlainDate(year: 2024, month: 12, day: 31)!
        date -= 366 // Move back one leap year's worth of days

        #expect(date.year == 2023)
        #expect(date.month == 12)
        #expect(date.day == 31)
    }

    @Test("PlainDateTests: In-place subtraction (-=) correctly updates state")
    func inPlaceSubtraction() {
        // Start at 2025-03-01 01:00
        var dt = PlainDateTime(
            date: PlainDate(year: 2025, month: 3, day: 1)!,
            time: PlainTime(hour: 1, minute: 0, second: 0)!,
        )

        // Subtract 1 month and 2 hours
        let interval = CalendarInterval(month: 1, day: 0, nanosecond: NanoSeconds.perHour64 * 2)

        dt -= interval

        // 1. Time subtract: 01:00 - 2h = 23:00 (Previous day, Feb 28)
        // 2. Month subtract: Feb 28 - 1 month = Jan 28
        #expect(dt.date.month == 1)
        #expect(dt.date.day == 31)
        #expect(dt.time.hour == 23)
    }
}

// MARK: - Era and Year Tests

extension PlainDateTests {
    @Test("PlainDateTests: Year CE calculation", arguments: [
        (2025, true, 2025),
        (1, true, 1),
        (0, false, 1), // 1 BCE
        (-1, false, 2), // 2 BCE
        (-99, false, 100), // 100 BCE
    ])
    func yearCE(inputYear: Int32, expectedIsCE: Bool, expectedYear: UInt32) {
        let date = PlainDate(year: inputYear, month: 1, day: 1)!
        #expect(date.yearCE.isCE == expectedIsCE)
        #expect(date.yearCE.year == expectedYear)
    }

    @Test("PlainDateTests: Leap year property", arguments: [
        (2024, true), // Normal leap
        (2000, true), // Century leap
        (2100, false), // Century non-leap
        (2023, false) // Normal year
    ])
    func leapYear(year: Int32, expected: Bool) {
        let date = PlainDate(year: year, month: 1, day: 1)!
        #expect(date.isLeapYear == expected)
    }
}

// MARK: - Quarter Tests

extension PlainDateTests {
    @Test("PlainDateTests: Quarter calculation", arguments: [
        (1, 1), (3, 1), // Q1
        (4, 2), (6, 2), // Q2
        (7, 3), (9, 3), // Q3
        (10, 4), (12, 4), // Q4
    ])
    func quarters(month: Int, expectedQuarter: Int) {
        let date = PlainDate(year: 2025, month: month, day: 1)!
        #expect(date.quarter == expectedQuarter)
    }
}

// MARK: - Month Tests

extension PlainDateTests {
    @Test("PlainDateTests: Month calculation", arguments: [
        (1, 1, 0),
        (2, 2, 1),
        (3, 3, 2),
        (4, 4, 3),
        (5, 5, 4),
        (6, 6, 5),
        (7, 7, 6),
        (8, 8, 7),
        (9, 9, 8),
        (10, 10, 9),
        (11, 11, 10),
        (12, 12, 11),
    ])
    func months(inputMonth: Int, expected: Int, expectedZeroBased: Int) {
        let date = PlainDate(year: 2025, month: inputMonth, day: 1)!
        #expect(date.month == expected)
        #expect(date.month - 1 == expectedZeroBased)
    }

    @Test("PlainDateTests: Month symbols", arguments: [
        (1, Month.january),
        (2, Month.february),
        (3, Month.march),
        (4, Month.april),
        (5, Month.may),
        (6, Month.june),
        (7, Month.july),
        (8, Month.august),
        (9, Month.september),
        (10, Month.october),
        (11, Month.november),
        (12, Month.december),
    ])
    func symbols(month: Int, symbol: Month) {
        let date = PlainDate(year: 2025, month: month, day: 10)!
        #expect(date.monthSymbol == symbol)
    }
}

// MARK: - Weekday Tests

extension PlainDateTests {
    @Test("PlainDateTests: Weekday Symbol Calculation", arguments: [1, 2, 3, 4, 5, 6, 7])
    func weekdaySymbolCheck(day: Int) {
        let date = PlainDate(year: 2023, month: 5, day: day)!
        #expect(date.weekdaySymbol!.rawValue == date.weekday)
    }

    @Test("PlainDateTests: ISO Week Consistency")
    func isoWeekCheck() {
        // Thursday, Jan 1, 2026 is Week 1 of 2026
        let date = PlainDate(year: 2026, month: 1, day: 1)!
        #expect(date.isoWeek.year == 2026)

        // Monday, Dec 29, 2025 is also Week 1 of 2026
        let isoDate = PlainDate(year: 2025, month: 12, day: 29)!
        #expect(isoDate.isoWeek.week == 1)
    }
}

// MARK: - Day Tests

extension PlainDateTests {
    @Test("PlainDateTests: Day zero-based components")
    func zeroBasedProperties() {
        let date = PlainDate(year: 2025, month: 12, day: 25)!
        #expect(date.monthZeroBased == 11)
    }

    @Test("PlainDateTests: Unix Epoch Alignment")
    func unixEpoch() {
        let epoch = PlainDate(year: 1970, month: 1, day: 1)!
        #expect(epoch.daysSinceEpoch == 0)

        let beforeEpoch = PlainDate(year: 1969, month: 12, day: 31)!
        #expect(beforeEpoch.daysSinceEpoch == -1)
    }

    @Test("PlainDateTests: Days in month", arguments: [
        (2024, 2, 29), // Leap Feb
        (2025, 2, 28), // Standard Feb
        (2025, 4, 30), // April
        (2025, 1, 31) // January
    ])
    func daysInMonth(year: Int32, month: Int, expectedDays: Int) {
        let date = PlainDate(year: year, month: month, day: 1)!
        #expect(date.daysInMonth == expectedDays)
    }
}

// MARK: - Ordinal Tests

extension PlainDateTests {
    @Test("PlainDateTests: Ordinal day calculation")
    func ordinalDayCalculation() {
        let jan1 = PlainDate(year: 2025, month: 1, day: 1)!
        #expect(jan1.ordinal == 1, "Jan 1 ordinal should be 1")

        let feb1 = PlainDate(year: 2025, month: 2, day: 1)!
        #expect(feb1.ordinal == 32, "Feb 1 ordinal should be 32")

        let dec31 = PlainDate(year: 2024, month: 12, day: 31)!
        #expect(dec31.ordinal == 366, "Dec 31 on leap year ordinal should be 366")
    }

    @Test("PlainDateTests: Ordinal day zero-based calculation")
    func ordinalDayZeroBasedCalculation() {
        let jan1 = PlainDate(year: 2025, month: 1, day: 1)!
        #expect(jan1.ordinal == 1)
        #expect(jan1.ordinalZeroBased == 0)
    }
}

// MARK: - Modification Tests

extension PlainDateTests {
    @Test("PlainDateTests: Modify components using 'with'")
    func modificationWith() {
        let base = PlainDate(year: 2023, month: 5, day: 1)!

        #expect(base.with(year: 2025)!.year == 2025)
        #expect(base.with(month: 10)!.month == 10)
        #expect(base.with(monthZeroBased: 11)!.month == 12)
        #expect(base.with(monthSymbol: .january)!.month == 1)
        #expect(base.with(day: 31)!.day == 31)
        #expect(base.with(dayZeroBased: 10)!.day == 11)

        let leapDay = PlainDate(year: 2024, month: 2, day: 29)!
        #expect(leapDay.with(year: 2025) == nil)
    }

    @Test("PlainDateTests: Ordinal modifications and leap years")
    func ordinalModifications() {
        let commonYear = PlainDate(year: 2023, month: 1, day: 1)!
        let leapYear = PlainDate(year: 2024, month: 1, day: 1)!

        // Day 60 in common year is March 1
        let mar1 = commonYear.with(ordinal: 60)
        #expect(mar1?.month == 3 && mar1?.day == 1)

        // Day 60 in leap year is Feb 29
        let feb29 = leapYear.with(ordinalZeroBased: 59)
        #expect(feb29?.month == 2 && feb29?.day == 29)

        // Out of bounds
        #expect(commonYear.with(ordinal: 366) == nil)
        #expect(leapYear.with(ordinal: 366) != nil)
    }

    @Test("PlainDateTests: Modifying components to invalid states returns nil", arguments: [
        // Trying to set Feb 29 on a non-leap year
        (2025, 2, 29),
        // Trying to set April 31
        (2025, 4, 31),
        // Invalid month indices
        (2025, 13, 1)
    ])
    func invalidModifications(year: Int32, month: Int, day: Int) {
        let base = PlainDate(year: 2024, month: 1, day: 1)!

        // We test multiple paths to these invalid states
        #expect(base.with(year: year)?.with(month: month)?.with(day: day) == nil)
    }
}

// MARK: - Plain Date Time Conversion

extension PlainDateTests {
    @Test("PlainDateTests: Convert using PlainTime object")
    func toDateTimeWithTimeObject() {
        let baseDate = PlainDate(year: 2025, month: 12, day: 25)!
        let time = PlainTime(hour: 15, minute: 30, second: 0)!
        let dt = baseDate.at(time)

        #expect(dt.date == baseDate)
        #expect(dt.time == time)
        #expect(dt.hour == 15)
        #expect(dt.day == 25)
    }

    @Test("PlainDateTests: Convert using nanoseconds since midnight")
    func toDateTimeWithNanos() {
        // 1 hour = 3,600,000,000,000 nanoseconds
        let nanos: Int64 = 3_600_000_000_000
        let baseDate = PlainDate(year: 2025, month: 12, day: 25)!
        let dt = baseDate.at(nanosecondsSinceMidnight: nanos)

        #expect(dt.date == baseDate)
        #expect(dt.hour == 1)
        #expect(dt.minute == 0)
    }

    @Test("PlainDateTests: Convert using valid components")
    func toDateTimeWithValidComponents() {
        let baseDate = PlainDate(year: 2025, month: 12, day: 25)!
        let dt = baseDate.at(hour: 23, minute: 59, second: 59, nanosecond: 999)

        #expect(dt != nil)
        #expect(dt?.hour == 23)
        #expect(dt?.nanosecond == 999)
        #expect(dt?.year == 2025)
    }

    @Test("PlainDateTests: Convert using invalid components returns nil", arguments: [
        (24, 0, 0), // Invalid hour
        (12, 60, 0), // Invalid minute
        (12, 0, -1) // Invalid second
    ])
    func toDateTimeWithInvalidComponents(h: Int, m: Int, s: Int) {
        let baseDate = PlainDate(year: 2025, month: 12, day: 25)!
        let result = baseDate.at(hour: h, minute: m, second: s)
        #expect(result == nil)
    }

    @Test("PlainDateTests: Default nanosecond value")
    func toDateTimeDefaultNanos() {
        let baseDate = PlainDate(year: 2025, month: 12, day: 25)!
        let dt = baseDate.at(hour: 10, minute: 0, second: 0)
        #expect(dt?.nanosecond == 0)
    }
}
