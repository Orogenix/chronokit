import ChronoCore
@testable import ChronoParser
import Testing

// MARK: RFC3339 Tests

struct InstantParserTests {
    @Test("InstantParserTests: Instant correctly normalizes different timezones to the same moment", arguments: [
        // All these represent the same moment: 2025-12-29 10:00:00 UTC
        "2025-12-29T10:00:00Z",
        "2025-12-29T11:00:00+01:00",
        "2025-12-29T05:00:00-05:00",
        "2025-12-29T17:00:00+07:00",
    ])
    func instantNormalization_rfc3339(input: String) {
        let instant = Instant(rfc3339: input)
        #expect(instant != nil)
        // Verify against a known epoch second if your Instant stores seconds
        // or simply ensure they are all equal to each other
        let expectedEpochSeconds: Int64 = 1_767_002_400
        #expect(instant?.seconds == expectedEpochSeconds)
    }

    @Test("InstantParserTests: Handles various fraction lengths", arguments: [
        ("2025-12-29T10:00:00Z", 0), // No fraction
        ("2025-12-29T10:00:00.5Z", 500_000_000), // 1 digit (Deciseconds)
        ("2025-12-29T10:00:00.12Z", 120_000_000), // 2 digits (Centiseconds)
        ("2025-12-29T10:00:00.123Z", 123_000_000), // 3 digits (Milliseconds)
        ("2025-12-29T10:00:00.123456Z", 123_456_000), // 6 digits (Microseconds)
        ("2025-12-29T10:00:00.123456789Z", 123_456_789), // 9 digits (Nanoseconds)
        ("2025-12-29T10:00:00.000000001Z", 1), // Minimum nanoseconds
        ("2025-12-29T10:00:00.999999999Z", 999_999_999) // Maximum nanoseconds
    ])
    func fractionalPrecision_rfc3339(input: String, expectedNanos: Int32) {
        let instant = Instant(rfc3339: input)
        #expect(instant != nil)
        #expect(instant?.nanoseconds == expectedNanos)
    }

    @Test("InstantParserTests: Handles different decimal separators", arguments: [
        "2025-12-29T10:00:00.5Z", // Dot (Standard)
        "2025-12-29T10:00:00,5Z" // Comma (Technically allowed by ISO 8601)
    ])
    func decimalSeparators_rfc3339(input: String) {
        let instant = Instant(rfc3339: input)
        #expect(instant?.nanoseconds == 500_000_000)
    }

    @Test("InstantParserTests: Excessive precision (Trimming)", arguments: [
        "2025-12-29T10:00:00.123456789123Z"
    ])
    func excessivePrecision_rfc3339(input: String) {
        let instant = Instant(rfc3339: input)
        #expect(instant?.nanoseconds == 123_456_789, "Should still equal the max 9-digit precision")
    }

    @Test("InstantParserTests: Fails on invalid strings", arguments: [
        "2025-12-29", // Date only (ambiguous for Instant)
        "2025-12-29T10:00:00", // Missing offset (ambiguous unless DateTime defaults to UTC)
        "InvalidString"
    ])
    func failures_rfc3339(input: String) {
        #expect(Instant(rfc3339: input) == nil)
    }
}
