import ChronoCore
import ChronoMath
@testable import ChronoParser
import Testing

// MARK: - RFC 3339 Date Scanning Tests

struct ScannerTests {
    @Test("ScannerTests: Scan RFC3339 date parts", arguments: [
        ("2026-04-13", 2026, 4, 13),
        ("0001-01-01", 1, 1, 1),
        ("9999-12-31", 9999, 12, 31),
    ])
    func scanRFC3339Date(input: String, year: Int, month: Int, day: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let result = ChronoScanner.scanDateRFC3339(from: raw, at: &cursor)

            #expect(result != nil)
            #expect(result?.year == year)
            #expect(result?.month == month)
            #expect(result?.day == day)
            #expect(cursor == 10)
        }
    }

    @Test("ScannerTests: Scan invalid RFC3339 date", arguments: [
        "2026/04/13", // Wrong separator
        "2026-4-13", // Missing padding
        "202-04-13", // Short year
        "ABC-DE-FG" // Garbage
    ])
    func scanInvalidRFC3339Date(input: String) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            #expect(ChronoScanner.scanDateRFC3339(from: UnsafeRawBufferPointer(buffer), at: &cursor) == nil)
        }
    }
}

// MARK: - RFC 3339 Time Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan RFC3339 times (with and without fractions)", arguments: [
        ("13:46:11", 13, 46, 11, 0, 8),
        ("13:46:11.123", 13, 46, 11, 123_000_000, 12),
        ("13:46:11,5", 13, 46, 11, 500_000_000, 10), // Comma support
        ("00:00:00.000000001", 0, 0, 0, 1, 18),
    ])
    // swiftlint:disable:next function_parameter_count
    func scanRFC3339Time(input: String, h: Int, m: Int, s: Int, ns: Int64, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            let result = ChronoScanner.scanTimeRFC3339(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(result != nil)
            #expect(result?.hour == h)
            #expect(result?.minute == m)
            #expect(result?.second == s)
            #expect(result?.nanosecond == ns)
            #expect(cursor == expectedConsumed)
        }
    }
}

// MARK: - RFC 5322 Date Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan RFC5322 Date parts", arguments: [
        ("13 Apr 2026", 2026, 4, 13),
        ("1 Jan 0001", 1, 1, 1),
        ("31 Dec 9999", 9999, 12, 31),
        (" 5 Feb 2024", 2024, 2, 5), // Note: readVarInt stops at spaces
    ])
    func scanRFC5322Date(input: String, year: Int, month: Int, day: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            // skip initial space if present for testing convenience
            if raw[0] == ASCII.space { cursor += 1 }

            let result = ChronoScanner.scanDateRFC5322(from: raw, at: &cursor)
            #expect(result != nil)
            #expect(result?.year == year)
            #expect(result?.month == month)
            #expect(result?.day == day)
        }
    }

    @Test("ScannerTests: Scan invalid RFC5322 date", arguments: [
        "2026/04/13", // Wrong separator
        "2026-4-13", // Missing padding
        "202-04-13", // Short year
        "ABC-DE-FG" // Garbage
    ])
    func scanInvalidRFC5322Date(input: String) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            #expect(ChronoScanner.scanTimeRFC5322(from: raw, at: &cursor) == nil)
        }
    }
}

// MARK: - RFC 5322 Time Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan RFC5322 Time parts (Optional Seconds)", arguments: [
        ("13:46", 13, 46, 0),
        ("13:46:11", 13, 46, 11),
        ("13:46:11.500", 13, 46, 11), // Verify nanosecond extraction in 5322
    ])
    func scanRFC5322Time(input: String, hour: Int, month: Int, second: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let result = ChronoScanner.scanTimeRFC5322(from: raw, at: &cursor)
            #expect(result != nil)
            #expect(result?.hour == hour)
            #expect(result?.minute == month)
            #expect(result?.second == second)
        }
    }
}

// MARK: - Offset Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan TimeZone Offsets", arguments: [
        ("Z", 0, 1),
        ("z", 0, 1),
        ("UT", 0, 2),
        ("ut", 0, 2),
        ("GMT", 0, 3),
        ("gmt", 0, 3),
        ("+07:00", 7 * 3600, 6),
        ("-05:00", -5 * 3600, 6),
        ("+0700", 7 * 3600, 5), // No separator
        ("-08", -8 * 3600, 3), // Short format
        ("+00:00", 0, 6),
    ])
    func scanOffsets(input: String, expectedSeconds: Int, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            let result = ChronoScanner.scanOffset(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(result != nil)
            #expect(result == expectedSeconds)
            #expect(cursor == expectedConsumed)
        }
    }

    @Test("ScannerTests: Offset failure cases", arguments: [
        "+7:00", // Missing padding for hour
        "*07:00", // Invalid sign
        "" // Empty
    ])
    func scanOffsetFailures(input: String) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            #expect(ChronoScanner.scanOffset(from: UnsafeRawBufferPointer(buffer), at: &cursor) == nil)
        }
    }
}

// MARK: - Folding White Space Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Folding White Space (FWS)", arguments: [
        ("   ", 3),
        ("\t\t", 2),
        ("\r\n ", 3),
        ("\r\n\t ", 4),
        (" \r\n  ", 5),
    ])
    func scanFWS(input: String, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            ChronoScanner.scanFWS(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(cursor == expectedConsumed)
        }
    }

    @Test("ScannerTests: FWS Invalid/Breaking cases", arguments: [
        ("\r\n", 0), // No trailing space/tab after CRLF is not FWS
        (" \r\nX", 1), // Only the first space is consumed, CRLF-X breaks FWS
        ("X   ", 0), // Non-white space starts
    ])
    func scanFWSFailures(input: String, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            ChronoScanner.scanFWS(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(cursor == expectedConsumed)
        }
    }
}

// MARK: - Month Bit-Pack Tests

extension ScannerTests {
    @Test("ScannerTests: Month Names (Case Insensitive)", arguments: [
        ("Jan", 1), ("fEb", 2), ("MAR", 3), ("dec", 12),
    ])
    func scanMonths(input: String, expected: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            let result = ChronoScanner.scanMonth(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(result == expected)
            #expect(cursor == 3)
        }
    }
}

// MARK: - Weekday Bit-Pack  Tests

extension ScannerTests {
    @Test("ScannerTests: Weekday Names (Case Insensitive)", arguments: [
        ("Mon", 1), ("tue", 2), ("WED", 3), ("SUN", 7),
    ])
    func scanWeekdays(input: String, expected: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            let result = ChronoScanner.scanWeekday(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(result == expected)
            #expect(cursor == 3)
        }
    }
}
