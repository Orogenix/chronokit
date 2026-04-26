@testable import ChronoMath
import Testing

struct CalendarMathTests {
    // MARK: - Date Conversion

    @Test("CalendarMathTests: Civil Date conversions", arguments: [
        (1970, 1, 1, 0), // Unix Epoch
        (1969, 12, 31, -1), // Before Epoch
        (2000, 1, 1, 10957), // Y2K
        (2000, 2, 29, 11016), // Leap Day 2000
        (2000, 2, 28, 11015), // Day before Leap Day
        (2000, 3, 1, 11017), // Day after Leap Day
    ])
    func dateConversion(year: Int64, month: UInt8, day: UInt8, expectedDays: Int64) {
        let days = daysFromCivil(year: year, month: month, day: day)
        #expect(days == expectedDays)

        let date = civilDate(from: expectedDays)
        #expect(date.year == year)
        #expect(date.month == month)
        #expect(date.day == day)
    }

    @Test("CalendarMathTests: Era boundary check (Year 1600)")
    func eraStart() {
        let days = daysFromCivil(year: 1600, month: 1, day: 1)
        let date = civilDate(from: days)
        #expect(date.year == 1600)
    }

    @Test("CalendarMathTests: Century skip (2100 is not a leap year)")
    func centurySkip() {
        let days1 = daysFromCivil(year: 2099, month: 3, day: 1)
        let days2 = daysFromCivil(year: 2100, month: 3, day: 1)
        #expect(days2 - days1 == 365)
    }

    @Test("CalendarMathTests: Min/Max day value stability")
    func minMaxStability() {
        let values: [Int64] = [.min, .max - CalendarConstants.marchBasedUnixEpochCivilOffset]
        for days in values {
            let date = civilDate(from: days)
            #expect(daysFromCivil(year: date.year, month: date.month, day: date.day) == days)
        }
    }
}

// MARK: - Leap Year Logic

extension CalendarMathTests {
    @Test("CalendarMathTests: Leap year rules", arguments: [
        (1900, false), (2000, true), (2004, true),
        (2023, false), (2024, true), (2100, false),
    ])
    func leapYearLogic(year: Int64, expected: Bool) {
        #expect(isLeapYear(year) == expected)
    }
}

// MARK: - Weekday Logic

extension CalendarMathTests {
    @Test("CalendarMathTests: Weekday differences")
    func weekdayDiff() {
        let matrix: [[Int]] = [
            [0, 6, 5, 4, 3, 2, 1],
            [1, 0, 6, 5, 4, 3, 2],
            [2, 1, 0, 6, 5, 4, 3],
            [3, 2, 1, 0, 6, 5, 4],
            [4, 3, 2, 1, 0, 6, 5],
            [5, 4, 3, 2, 1, 0, 6],
            [6, 5, 4, 3, 2, 1, 0],
        ]

        for (from, row) in matrix.enumerated() {
            for (to, expected) in row.enumerated() {
                let actual = weekdayDifference(from: from, to: to)
                #expect(actual == expected, "From \(from) to \(to)")
                #expect((0 ... 6).contains(actual))
            }
        }
    }
}

// MARK: - Month Logic

extension CalendarMathTests {
    @Test("CalendarMathTests: Last day of month", arguments: [
        (2000, 2, 29), (2003, 2, 28), (2024, 1, 31), (2024, 4, 30),
    ])
    func monthEnd(year: Int64, month: UInt8, expected: UInt8) {
        #expect(lastDayOfMonth(year, month) == expected)
    }
}
