@testable import ChronoCore
import Testing

@Suite("Weekday Tests")
struct WeekdayTests {
    @Test("WeekdayTests: Circular navigation")
    func navigation() {
        #expect(Weekday.monday.next() == .tuesday)
        #expect(Weekday.sunday.next() == .monday) // Wrap around

        #expect(Weekday.monday.prev() == .sunday) // Wrap back
        #expect(Weekday.friday.prev() == .thursday)
    }

    @Test("WeekdayTests: daysUntil calculation", arguments: [
        (Weekday.monday, Weekday.wednesday, 2), // Mon -> Wed
        (Weekday.friday, Weekday.monday, 3), // Fri -> Mon (Wrap: Sat, Sun, Mon)
        (Weekday.sunday, Weekday.sunday, 0), // Same day
        (Weekday.sunday, Weekday.monday, 1) // Sun -> Mon
    ])
    func testDaysUntil(start: Weekday, end: Weekday, expected: Int) {
        #expect(start.daysUntil(end) == expected)
    }

    @Test("WeekdayTests: 1-based and 0-based numbering")
    func numbering() {
        let wed = Weekday.wednesday

        // Monday is 0. Wed is 2.
        // Wed until Mon is 5 days. (Thu, Fri, Sat, Sun, Mon)
        // Wait, check the logic:
        #expect(wed.numDayFromMonday == 5)
        #expect(wed.numberFromMonday == 6)

        let mon = Weekday.monday
        #expect(mon.numDayFromMonday == 0)
        #expect(mon.numberFromMonday == 1)
    }

    @Test("WeekdayTests: Comparable")
    func comparison() {
        #expect(Weekday.monday < Weekday.sunday)
        #expect(Weekday.thursday > Weekday.tuesday)
    }
}
