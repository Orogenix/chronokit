import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - RFC 3339 Tests

struct InstantParserTests {
    @Test("InstantParserTests: RFC 3339 correctly normalizes different timezones to the UTC", arguments: [
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

    @Test("InstantParserTests: Handles various fraction lengths RFC 3339", arguments: [
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

    @Test("InstantParserTests: Handles different decimal separators RFC 3339", arguments: [
        "2025-12-29T10:00:00.5Z", // Dot (Standard)
        "2025-12-29T10:00:00,5Z" // Comma (Technically allowed by ISO 8601)
    ])
    func decimalSeparators_rfc3339(input: String) {
        let instant = Instant(rfc3339: input)
        #expect(instant?.nanoseconds == 500_000_000)
    }

    @Test("InstantParserTests: RFC 3339 excessive precision (Trimming)", arguments: [
        "2025-12-29T10:00:00.123456789123Z"
    ])
    func excessivePrecision_rfc3339(input: String) {
        let instant = Instant(rfc3339: input)
        #expect(instant?.nanoseconds == 123_456_789, "Should still equal the max 9-digit precision")
    }

    @Test("InstantParserTests: RFC 3339 fails on invalid strings", arguments: [
        "2025-12-29", // Date only (ambiguous for Instant)
        "2025-12-29T10:00:00", // Missing offset (ambiguous unless DateTime defaults to UTC)
        "InvalidString"
    ])
    func failures_rfc3339(input: String) {
        #expect(Instant(rfc3339: input) == nil)
    }
}

// MARK: - RFC 5322 Tests

extension InstantParserTests {
    @Test("InstantParserTests: Valid RFC 5322 Instant strings", arguments: [
        // All represent 2026-04-13 13:46:00 UTC
        ("13 Apr 2026 13:46:00 +0000", 1_776_087_960),
        ("Mon, 13 Apr 2026 13:46 +0000", 1_776_087_960), // Optional sec/weekday
        ("13 Apr 2026 20:46:00 +0700", 1_776_087_960), // Positive offset
        ("13 Apr 2026 08:46:00 -0500", 1_776_087_960), // Negative offset
        ("Mon, 13 Apr 2026 13:46:00 UT", 1_776_087_960), // 'UT' alias (if scanOffset supports)
    ])
    func validInstant_rfc5322(input: String, expectedSeconds: Int64) {
        let instant = Instant(rfc5322: input)
        #expect(instant != nil)
        #expect(instant?.seconds == expectedSeconds)
    }

    @Test("InstantParserTests: RFC 5322 Fractional and case-sensitivity", arguments: [
        ("13 APR 2026 13:46:00.500 Z", 500_000_000),
        ("mon, 13 apr 2026 13:46:00.123456789 -0000", 123_456_789),
    ])
    func fractionsAndCase_rfc5322(input: String, expectedNanos: Int32) {
        let instant = Instant(rfc5322: input)
        #expect(instant != nil)
        #expect(instant?.nanoseconds == expectedNanos)
    }

    @Test("InstantParserTests: RFC 5322 Folding White Space normalization", arguments: [
        "Mon, 13 Apr 2026 13:46:00 +0000",
        "Mon,\r\n 13 Apr 2026\r\n 13:46:00\r\n +0000", // FWS at every possible boundary
        "13 Apr 2026 13:46:00    +0000", // Multiple spaces
    ])
    func fwsNormalization_rfc5322(input: String) {
        let instant = Instant(rfc5322: input)
        #expect(instant != nil)
        #expect(instant?.seconds == 1_776_087_960)
    }

    @Test("InstantParserTests: RFC 5322 Failure Cases", arguments: [
        "Mon 13 Apr 2026 13:46:00 +0000", // Missing comma after weekday
        "13 Apr 2026 13:46:00", // Missing offset (Instant requires it)
        "13 April 2026 13:46:00 +0000", // Full month name (invalid triple)
        "13-04-2026 13:46:00 +0000", // Wrong date format
    ])
    func failures_rfc5322(input: String) {
        #expect(Instant(rfc5322: input) == nil)
    }
}
