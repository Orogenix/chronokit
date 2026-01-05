@testable import ChronoCore
import Testing

@Suite("Month Tests")
struct MonthTests {
    @Test("MonthTests: Raw value mapping", arguments: [
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
    func rawValues(value: Int, expected: Month) {
        #expect(Month(rawValue: value) == expected)
    }

    @Test("MonthTests: Next month logic (Circular)")
    func nextMonth() {
        #expect(Month.january.next() == .february)
        #expect(Month.june.next() == .july)
        #expect(Month.december.next() == .january, "December should wrap to January")
    }

    @Test("MonthTests: Previous month logic (Circular)")
    func prevMonth() {
        #expect(Month.february.prev() == .january)
        #expect(Month.january.prev() == .december, "January should wrap to December")
    }

    @Test("MonthTests: Comparable implementation")
    func comparable() {
        #expect(Month.january < Month.february)
        #expect(Month.march > Month.february)
        #expect(Month.december > Month.january)
    }
}
