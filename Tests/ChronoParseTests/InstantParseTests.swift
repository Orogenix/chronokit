import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Instant Parse Tests")
struct InstantParseTests {
    @Test("InstantParseTests: Instant correctly normalizes different timezones to the same moment", arguments: [
        // All these represent the same moment: 2025-12-29 10:00:00 UTC
        "2025-12-29T10:00:00Z",
        "2025-12-29T11:00:00+01:00",
        "2025-12-29T05:00:00-05:00",
        "2025-12-29T17:00:00+07:00",
    ])
    func instantNormalization(input: String) {
        let instant = Instant(input)

        #expect(instant != nil)
        // Verify against a known epoch second if your Instant stores seconds
        // or simply ensure they are all equal to each other
        let expectedEpochSeconds: Int64 = 1_767_002_400
        #expect(instant!.seconds == expectedEpochSeconds)
    }

    @Test("InstantParseTests: Handles various fraction lengths", arguments: [
        ("2025-12-29T10:00:00Z", 0), // No fraction
        ("2025-12-29T10:00:00.5Z", 500_000_000), // 1 digit (Deciseconds)
        ("2025-12-29T10:00:00.12Z", 120_000_000), // 2 digits (Centiseconds)
        ("2025-12-29T10:00:00.123Z", 123_000_000), // 3 digits (Milliseconds)
        ("2025-12-29T10:00:00.123456Z", 123_456_000), // 6 digits (Microseconds)
        ("2025-12-29T10:00:00.123456789Z", 123_456_789), // 9 digits (Nanoseconds)
        ("2025-12-29T10:00:00.000000001Z", 1), // Minimum nanoseconds
        ("2025-12-29T10:00:00.999999999Z", 999_999_999) // Maximum nanoseconds
    ])
    func fractionalPrecision(input: String, expectedNanos: Int) {
        let instant = Instant(input)
        #expect(instant != nil)
        #expect(instant!.nanoseconds == expectedNanos)
    }

    @Test("InstantParseTests: Handles different decimal separators", arguments: [
        "2025-12-29T10:00:00.5Z", // Dot (Standard)
        "2025-12-29T10:00:00,5Z" // Comma (Technically allowed by ISO 8601)
    ])
    func decimalSeparators(input: String) {
        let instant = Instant(input)
        #expect(instant?.nanoseconds == 500_000_000)
    }

    @Test("InstantParseTests: Excessive precision (Trimming)", arguments: [
        "2025-12-29T10:00:00.123456789123Z"
    ])
    func excessivePrecision(input: String) {
        let instant = Instant(input)
        #expect(instant!.nanoseconds == 123_456_789, "Should still equal the max 9-digit precision")
    }

    @Test("InstantParseTests: Fails on invalid strings", arguments: [
        "2025-12-29", // Date only (ambiguous for Instant)
        "2025-12-29T10:00:00", // Missing offset (ambiguous unless DateTime defaults to UTC)
        "InvalidString"
    ])
    func failures(input: String) {
        #expect(Instant(input) == nil)
    }

    @Test("InstantParseTests: Consistency with expanded strategy")
    func instantExpanded() {
        // Test with "YYYY-MM-DD HH:MM:SSZ"
        let input = "2025-12-29 10:00:00Z"
        let instant = Instant(input, with: .expanded)

        #expect(instant!.seconds == 1_767_002_400)
    }
}
