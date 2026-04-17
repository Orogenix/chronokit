import ChronoCore
@testable import ChronoFormatter
import Testing

// MARK: - RFC 3339 Tests

struct InstantFormatterTests {
    @Test("InstantFormatterTests: RFC 3339 unix epoch")
    func epoch_rfc3339() {
        let epoch = Instant(seconds: 0, nanoseconds: 0)
        // Default (no digits) should be YYYY-MM-DDTHH:MM:SSZ
        #expect(epoch.rfc3339() == "1970-01-01T00:00:00Z")
        #expect(epoch.description == "1970-01-01T00:00:00Z")
        #expect("Today is \(epoch)" == "Today is 1970-01-01T00:00:00Z")
    }

    @Test("InstantFormatterTests: Recent RFC 3339 Date with Milliseconds")
    func recentDate_rfc3339() {
        // 2026-04-16T12:00:00.500Z
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 500_000_000)
        #expect(instant.rfc3339(digits: 3) == "2026-04-16T12:00:00.500Z")
        #expect(instant.rfc3339(digits: 0) == "2026-04-16T12:00:00Z")
    }

    @Test("InstantFormatterTests: RFC 3339 Full Nanosecond Precision")
    func nanosecondPrecision_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 123_456_789)
        #expect(instant.rfc3339(digits: 9) == "2026-04-16T12:00:00.123456789Z")
        #expect(instant.rfc3339(digits: 6) == "2026-04-16T12:00:00.123456Z")
    }

    @Test("InstantFormatterTests: RFC 3339 trailing Zeroes in Fractions")
    func trailingZeroes_rfc3339() {
        let instant = Instant(seconds: 100, nanoseconds: 0)
        // Ensure it correctly pads zeroes even when the fraction value is 0
        #expect(instant.rfc3339(digits: 3) == "1970-01-01T00:01:40.000Z")
    }

    @Test("InstantFormatterTests: Pre-Epoch RFC 3339 Date")
    func preEpoch_rfc3339() {
        let earlyDate = Instant(seconds: -2_208_988_800, nanoseconds: 0)
        #expect(earlyDate.rfc3339() == "1900-01-01T00:00:00Z")
    }

    @Test("InstantFormatterTests: RFC 3339 Capacity Safety check")
    func maxPossibleLength_rfc3339() {
        // Max theoretical length:
        // 10 (date) + 1 (T) + 8 (time) + 1 (.) + 9 (nanos) + 1 (Z) = 30 bytes.
        // Your capacity is 32, so this should never overflow.
        let instant = Instant(seconds: 253_402_300_799, nanoseconds: 999_999_999) // Year 9999
        #expect(instant.rfc3339(digits: 9).count <= 32)
        #expect(instant.rfc3339(digits: 9) == "9999-12-31T23:59:59.999999999Z")
    }
}

// MARK: - RFC 5322 Tests

extension InstantFormatterTests {
    @Test("InstantFormatterTests: RFC 5322 standard formatting (UTC)", arguments: [
        (0, 0, "Thu, 01 Jan 1970 00:00:00 +0000"),
        (1_773_748_800, 0, "Tue, 17 Mar 2026 12:00:00 +0000"),
    ])
    func formatting_rfc5322(seconds: Int64, nanoseconds: Int32, expected: String) {
        let epoch = Instant(seconds: seconds, nanoseconds: nanoseconds)
        #expect(epoch.rfc5322() == expected)
    }

    @Test("InstantFormatterTests: RFC 5322 Year boundaries", arguments: [
        (946_684_800, 0, "Sat, 01 Jan 2000 00:00:00 +0000"), // Y2K
        (946_684_799, 0, "Fri, 31 Dec 1999 23:59:59 +0000") // End of a century
    ])
    func yearBoundaries_rfc5322(seconds: Int64, nanoseconds: Int32, expected: String) {
        let boundaries = Instant(seconds: seconds, nanoseconds: nanoseconds)
        #expect(boundaries.rfc5322() == expected)
    }

    @Test("InstantFormatterTests: Pre-Epoch RFC5 5322 Date")
    func preEpoch_rfc5322() {
        let earlyDate = Instant(seconds: -2_208_988_800, nanoseconds: 0)
        #expect(earlyDate.rfc5322() == "Mon, 01 Jan 1900 00:00:00 +0000")
    }

    @Test("InstantFormatterTests: Maximum Capacity RFC 5322")
    func capacity_rfc5322() {
        // Max theoretical length for RFC 5322:
        // "Wed, 31 Dec 9999 23:59:59 +0000" = 31 bytes
        let instant = Instant(seconds: 253_402_300_799, nanoseconds: 0)
        let result = instant.rfc5322()
        #expect(result != nil)
        #expect(result?.count == 31)
        #expect(result == "Fri, 31 Dec 9999 23:59:59 +0000")
    }
}
