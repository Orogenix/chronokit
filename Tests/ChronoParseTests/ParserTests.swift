import ChronoMath
@testable import ChronoParse
import Testing

@Suite("ChronoParser Integration Tests")
struct ChronoParserTests {
    @Test("ChronoParserTests: Separator strategies", arguments: [
        (ChronoParser.Strategy.compact, "2025-12-29T15:30:45"),
        (ChronoParser.Strategy.expanded, "2025-12-29 15:30:45"),
        (ChronoParser.Strategy.custom(separator: ASCII.colon), "2025-12-29:15:30:45"),
    ])
    func strategies(strategy: ChronoParser.Strategy, input: String) {
        let parser = ChronoParser(strategy: strategy)
        let parts = parser.parse(input)!

        #expect(parts.year == 2025)
        #expect(parts.month == 12)
        #expect(parts.day == 29)
        #expect(parts.hour == 15)
        #expect(parts.minute == 30)
        #expect(parts.second == 45)
    }

    @Test("ChronoParserTests: Date-only parsing (Truncated input)")
    func dateOnly() {
        let parser: ChronoParser = .compact
        let input = "2025-12-29" // Exactly 10 chars
        let parts = parser.parse(input)!

        #expect(parts.year == 2025)
        #expect(parts.month == 12)
        #expect(parts.day == 29)
        // Time components should remain default (likely 0)
        #expect(parts.hour == 0)
        #expect(parts.nanosecond == 0)
    }

    @Test("ChronoParserTests: Full ISO 8601 with Fraction and Offset", arguments: [
        ("2025-12-29T15:30:45.5Z", 500_000_000, 0),
        ("2025-12-29T15:30:45.123+07:00", 123_000_000, 25200),
        ("2025-12-29T15:30:45.999999999-05:00", 999_999_999, -18000)
    ])
    func complexISO(input: String, expectedNano: Int64, expectedOffset: Int) {
        let parser: ChronoParser = .compact
        let parts = parser.parse(input)!

        #expect(parts.nanosecond == expectedNano)
        #expect(parts.offset == expectedOffset)
    }

    @Test("ChronoParserTests: Invalid formats should return nil", arguments: [
        "2025/12/29", // Wrong year/month separator
        "2025-12-29X15", // Wrong T/Space separator
        "202-12-29T15", // Short year
        "2025-13-01", // Month out of range (Note: parseParts validates digits, not calendar logic)
        "2025-12-29T15:3" // Truncated time
    ])
    func failures(input: String) {
        let parser: ChronoParser = .compact
        #expect(parser.parse(input) == nil)
    }
}
