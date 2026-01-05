import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Time Parse Tests")
struct TimeParseTests {
    @Test("TimeParseTests: Valid time extraction from ISO strings", arguments: [
        ("2025-12-29T15:30:45", 15, 30, 45, 0),
        ("1970-01-01T00:00:00", 0, 0, 0, 0),
        ("2025-12-29T23:59:59.999", 23, 59, 59, 999_000_000),
        ("2025-12-29T12:00:00.123456789", 12, 0, 0, 123_456_789),
    ])
    func validTimeInit(input: String, hour: Int, month: Int, second: Int, nano: Int) {
        // Uses default .compact parser (expects 'T')
        let time = NaiveTime(input)

        #expect(time != nil)
        #expect(time!.hour == UInt8(hour))
        #expect(time!.minute == UInt8(month))
        #expect(time!.second == UInt8(second))
        #expect(time!.nanosecond == nano)
    }

    @Test("TimeParseTests: Strategy switching (Space separator)")
    func expandedStrategy() {
        let input = "2025-12-29 15:30:45"
        let time = NaiveTime(input, with: .expanded)!

        #expect(time.hour == 15)
        #expect(time.minute == 30)
    }

    @Test("TimeParseTests: Fails on invalid time values", arguments: [
        "2025-12-29T24:00:00", // Hour 24 invalid
        "2025-12-29T15:60:00", // Minute 60 invalid
        "2025-12-29T15:30:61" // Second 61 invalid
    ])
    func invalidTimeBounds(input: String) {
        #expect(NaiveTime(input) == nil)
    }

    @Test("TimeParseTests: Fails when date portion is missing")
    func missingDateFailure() {
        // Since ChronoParser.parseParts mandates a 4-digit year + 2-digit month + 2-digit day
        // a time-only string like "15:30:45" should return nil.
        let input = "15:30:45"
        #expect(NaiveTime(input) == nil)
    }

    @Test("TimeParseTests: Fails on strategy mismatch")
    func separatorMismatch() {
        // Input has space, but default parser expects 'T'
        let input = "2025-12-29 15:30:45"
        #expect(NaiveTime(input) == nil)
    }
}
