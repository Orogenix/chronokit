@testable import ChronoKit
import Testing

@Suite("Calendar Interval Tests")
struct CalendarIntervalTests {
    // MARK: - Initialization Tests

    static var positiveUnderflowCases: [(ns: Int64, expectedDays: Int32, expectedNanos: Int64)] {
        [
            // 1 nanosecond (No overflow)
            (ns: 1, expectedDays: 0, expectedNanos: 1),
            // Exactly 1 day in nanoseconds
            (ns: NanoSeconds.perDay64, expectedDays: 1, expectedNanos: 0),
            // 25 hours (1 day, 1 hour)
            (ns: NanoSeconds.perHour64 * 25, expectedDays: 1, expectedNanos: NanoSeconds.perHour64),
            // Large overflow (10 days)
            (ns: NanoSeconds.perDay64 * 10 + 500, expectedDays: 10, expectedNanos: 500),
        ]
    }

    static var negativeUnderflowCases: [(ns: Int64, expectedDays: Int32, expectedNanos: Int64)] {
        [
            // -1 nanosecond -> -1 Day, +86,399,999,999,999 nanos
            (ns: -1, expectedDays: -1, expectedNanos: NanoSeconds.perDay64 - 1),
            // -25 hours -> -2 Days, +23 hours
            (ns: -(NanoSeconds.perHour64 * 25), expectedDays: -2, expectedNanos: NanoSeconds.perHour64 * 23),
            // Exactly -1 day
            (ns: -NanoSeconds.perDay64, expectedDays: -1, expectedNanos: 0),
            // -10 days and 500 nanos -> -11 days and (perDay - 500) nanos
            (ns: -(NanoSeconds.perDay64 * 10 + 500), expectedDays: -11, expectedNanos: NanoSeconds.perDay64 - 500),
        ]
    }

    @Test(
        "CalendarIntervalTests: Positive nanosecond overflow into days",
        arguments: positiveUnderflowCases
    )
    func positiveOverflow(ns: Int64, expectedDays: Int32, expectedNanos: Int64) {
        let interval = CalendarInterval(month: 0, day: 0, nanosecond: ns)

        #expect(interval.day == expectedDays)
        #expect(interval.nanosecond == expectedNanos)
    }

    @Test(
        "CalendarIntervalTests: Negative nanosecond underflow (The floorDiv/floorMod Test)",
        arguments: negativeUnderflowCases
    )
    func negativeUnderflow(ns: Int64, expectedDays: Int32, expectedNanos: Int64) {
        let interval = CalendarInterval(month: 0, day: 0, nanosecond: ns)

        #expect(interval.day == expectedDays)
        #expect(interval.nanosecond >= 0) // Nanoseconds must ALWAYS be positive
        #expect(interval.nanosecond == expectedNanos)
    }

    @Test("CalendarIntervalTests: Day and Month passthrough")
    func passthrough() {
        let interval = CalendarInterval(month: 12, day: 31, nanosecond: 100)

        #expect(interval.month == 12)
        #expect(interval.day == 31)
        #expect(interval.nanosecond == 100)
    }

    @Test("CalendarIntervalTests: Cumulative Day addition")
    func cumulativeDays() {
        // Start with 1 day, but add 24 hours worth of nanoseconds
        let interval = CalendarInterval(month: 0, day: 1, nanosecond: NanoSeconds.perDay64)

        // Should result in 2 days total
        #expect(interval.day == 2)
        #expect(interval.nanosecond == 0)
    }

    @Test("CalendarIntervalTests: Years and Months factory")
    func calendarFactories() {
        let twoYears = CalendarInterval.years(2)
        #expect(twoYears.month == 24)
        #expect(twoYears.day == 0)

        let negativeYear = CalendarInterval.years(Int32(-1))
        #expect(negativeYear.month == -12)

        let threeMonths = CalendarInterval.months(3)
        #expect(threeMonths.month == 3)
        #expect(threeMonths.day == 0)
    }

    @Test("CalendarIntervalTests: Days factory")
    func dayFactories() {
        let tenDays = CalendarInterval.days(10)
        #expect(tenDays.month == 0)
        #expect(tenDays.day == 10)
        #expect(tenDays.nanosecond == 0)

        let negativeDays = CalendarInterval.days(-5)
        #expect(negativeDays.day == -5)
    }

    @Test("CalendarIntervalTests: Hours factory with normalization")
    func hourFactories() {
        // 24 hours should normalize to 1 day
        let oneDay = CalendarInterval.hours(24)
        #expect(oneDay.day == 1)
        #expect(oneDay.nanosecond == 0)

        // 25 hours should be 1 day, 1 hour
        let moreThanDay = CalendarInterval.hours(Int64(25))
        #expect(moreThanDay.day == 1)
        #expect(moreThanDay.nanosecond == NanoSeconds.perHour64)
    }

    @Test("CalendarIntervalTests: Minutes and Seconds factory")
    func smallTimeUnitFactories() {
        // 1440 minutes = 24 hours = 1 day
        let dailyMinutes = CalendarInterval.minutes(1440)
        #expect(dailyMinutes.day == 1)
        #expect(dailyMinutes.nanosecond == 0)

        // 90 seconds = 1 minute, 30 seconds
        let ninetySecs = CalendarInterval.seconds(90)
        #expect(ninetySecs.day == 0)
        #expect(ninetySecs.nanosecond == 90 * NanoSeconds.perSecond64)
    }

    @Test("CalendarIntervalTests: Negative time unit normalization")
    func negativeTimeFactories() {
        // -1 hour should be -1 day + 23 hours (based on your floorDiv/floorMod logic)
        let minusOneHour = CalendarInterval.hours(-1)

        #expect(minusOneHour.day == -1)
        #expect(minusOneHour.nanosecond == NanoSeconds.perHour64 * 23)
    }
}

// MARK: - Addition & Subtraction Tests

extension CalendarIntervalTests {
    @Test("CalendarIntervalTests: Basic addition and subtraction")
    func additionSubtraction() {
        let a = CalendarInterval(month: 1, day: 10, nanosecond: 0)
        let b = CalendarInterval(month: 0, day: 5, nanosecond: NanoSeconds.perHour64)

        let sum = a + b
        #expect(sum.month == 1)
        #expect(sum.day == 15)
        #expect(sum.nanosecond == NanoSeconds.perHour64)

        let diff = a - b
        #expect(diff.month == 1)
        #expect(diff.day == 4)
        #expect(diff.nanosecond == NanoSeconds.perHour64 * 23)
    }

    @Test("CalendarIntervalTests: Unary minus")
    func unaryMinus() {
        let val = CalendarInterval(month: 1, day: 1, nanosecond: 100)
        let negative = -val

        #expect(negative.month == -1)
        #expect(negative.day == -2) // -1 day from nanosecond normalization
        #expect(negative.nanosecond == NanoSeconds.perDay64 - 100)
    }
}

// MARK: - Multiplication Tests

extension CalendarIntervalTests {
    @Test("CalendarIntervalTests: Multiplication (Commutative)")
    func multiplication() {
        let interval = CalendarInterval.hours(6) // day: 0, ns: 6h

        let doubled = interval * 2
        #expect(doubled.day == 0)
        #expect(doubled.nanosecond == NanoSeconds.perHour64 * 12)

        let quadrupled = 4 * interval
        #expect(quadrupled.day == 1) // 24 hours becomes 1 day
        #expect(quadrupled.nanosecond == 0)
    }
}

// MARK: - Division (Carry Logic) Tests

extension CalendarIntervalTests {
    @Test("CalendarIntervalTests: Division with month-to-day carry")
    func divisionCarry() {
        // 1 Month / 2 = 15 Days
        let halfMonth = CalendarInterval.months(1) / 2
        #expect(halfMonth.month == 0)
        #expect(halfMonth.day == 15)
        #expect(halfMonth.nanosecond == 0)

        // 1 Day / 2 = 12 Hours
        let halfDay = CalendarInterval.days(1) / 2
        #expect(halfDay.day == 0)
        #expect(halfDay.nanosecond == NanoSeconds.perHour64 * 12)
    }

    @Test("CalendarIntervalTests: Negative division")
    func negativeDivision() {
        // -1 Month / 2
        // monthQuotient = floorDiv(-1, 2) = -1
        // monthRemainder = floorMod(-1, 2) = 1 (30 days carry)
        // totalDays = 0 + 30 = 30. dayQuotient = 30 / 2 = 15.
        let result = CalendarInterval.months(-1) / 2

        #expect(result.month == -1)
        #expect(result.day == 15)
        #expect(result.nanosecond == 0)
    }
}

// MARK: - In-place Mutation Tests

extension CalendarIntervalTests {
    @Test("CalendarIntervalTests: In-place mutations")
    func mutations() {
        var interval = CalendarInterval.months(1)

        interval += .days(5)
        #expect(interval.month == 1 && interval.day == 5)

        interval *= 2
        #expect(interval.month == 2 && interval.day == 10)

        interval -= .months(1)
        #expect(interval.month == 1 && interval.day == 10)
    }
}
