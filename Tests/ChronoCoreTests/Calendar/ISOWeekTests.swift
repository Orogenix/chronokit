@testable import ChronoCore
import Testing

@Suite("ISOWeek Tests")
struct ISOWeekTests {
    // MARK: - Initialization Tests

    @Test("ISOWeekTests: Standard week calculation", arguments: [
        (2025, 6, 15, 2025, 24), // June 15, 2025 is Week 24
        (2025, 1, 1, 2025, 1), // Jan 1, 2025 is Week 1
    ])
    func standardWeeks(y: Int64, m: UInt8, d: UInt8, expectedYear: Int64, expectedWeek: Int) {
        let iso = ISOWeek(year: y, month: m, day: d)
        #expect(iso.year == expectedYear)
        #expect(iso.week == expectedWeek)
    }

    @Test("ISOWeekTests: Year boundary transitions", arguments: [
        // Dec 29, 2024 is Sunday. Dec 30, 2024 is Monday (Start of Week 1, 2025)
        (2024, 12, 29, 2024, 52),
        (2024, 12, 30, 2025, 1),
        (2024, 12, 31, 2025, 1),

        // Jan 1, 2021 (Friday) belongs to Week 53 of 2020
        (2021, 1, 1, 2020, 53),
        (2021, 1, 3, 2020, 53),
        (2021, 1, 4, 2021, 1) // Monday Jan 4 starts Week 1
    ])
    func boundaryTransitions(y: Int64, m: UInt8, d: UInt8, expectedYear: Int64, expectedWeek: Int) {
        let iso = ISOWeek(year: y, month: m, day: d)
        #expect(iso.year == expectedYear)
        #expect(iso.week == expectedWeek)
    }

    @Test("ISOWeekTests: 53-week years")
    func longYears() {
        // 2020 is a 53-week year because it is a leap year starting on Wednesday
        // or a year starting on Thursday.
        let lastDay = ISOWeek(year: 2020, month: 12, day: 31)
        #expect(lastDay.year == 2020)
        #expect(lastDay.week == 53)
    }

    @Test("ISOWeekTests: Count weeks in year (52 vs 53)", arguments: [
        (2023, 52), // Starts Sunday (7) -> 52
        (2024, 52), // Leap year, starts Monday (1) -> 52
        (2026, 53), // Starts Thursday (4) -> 53
        (2020, 53), // Leap year, starts Wednesday (3) -> 53
        (2015, 53), // Starts Thursday (4) -> 53
        (2025, 52) // Starts Wednesday (3), but not leap year -> 52
    ])
    func weeksInYear(year: Int64, expectedWeeks: Int) {
        #expect(ISOWeek.isoWeeksInYear(year) == expectedWeeks)
    }

    @Test("ISOWeekTests: Weekday conversion logic")
    func iSOWeekdayConversion() {
        #expect(ISOWeek.isoWeeksInYear(2026) == 53)
    }
}

// MARK: - Comparison Tests

extension ISOWeekTests {
    @Test("ISOWeekTests: Basic inequality")
    func inequality() {
        let earlyWeek = ISOWeek(year: 2024, month: 1, day: 1) // 2020-W01 (Approx)
        let laterWeek = ISOWeek(year: 2024, month: 2, day: 1)

        #expect(earlyWeek < laterWeek)
        #expect(laterWeek > earlyWeek)
    }

    @Test("ISOWeekTests: Year takes precedence over week", arguments: [
        // Even if the week number is higher, a lower year is "less than"
        (2023, 52, 2024, 1, true),
        (2024, 1, 2023, 52, false),
        // Same year, different weeks
        (2025, 10, 2025, 20, true),
        (2025, 20, 2025, 10, false)
    ])
    func comparisonLogic(y1: Int64, w1: Int, y2: Int64, w2: Int, expected: Bool) {
        let lhs = ISOWeek(year: y1, week: w1)
        let rhs = ISOWeek(year: y2, week: w2)

        #expect((lhs < rhs) == expected)
    }

    @Test("ISOWeekTests: Sorting behavior")
    func sorting() {
        let w1 = ISOWeek(year: 2025, week: 1)
        let w2 = ISOWeek(year: 2024, week: 52)
        let w3 = ISOWeek(year: 2025, week: 2)

        let sorted = [w1, w2, w3].sorted()

        #expect(sorted == [w2, w1, w3])
    }
}
