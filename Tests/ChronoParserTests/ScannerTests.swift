import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - Date Scanning Tests

struct ScannerTests {
    @Test("ScannerTests: Scan valid dates", arguments: [
        ("2026-04-13", 2026, 4, 13),
        ("0001-01-01", 1, 1, 1),
        ("9999-12-31", 9999, 12, 31),
    ])
    func scanValidDate(input: String, year: Int, month: Int, day: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let result = ChronoScanner.scanDate(from: raw, at: &cursor)

            #expect(result != nil)
            #expect(result?.year == year)
            #expect(result?.month == month)
            #expect(result?.day == day)
            #expect(cursor == 10)
        }
    }

    @Test("ScannerTests: Scan date failures", arguments: [
        "2026/04/13", // Wrong separator
        "2026-4-13", // Missing padding
        "202-04-13", // Short year
        "ABC-DE-FG" // Garbage
    ])
    func scanDateFailures(input: String) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            #expect(ChronoScanner.scanDate(from: UnsafeRawBufferPointer(buffer), at: &cursor) == nil)
        }
    }
}

// MARK: - Time Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan valid times (with and without fractions)", arguments: [
        ("13:46:11", 13, 46, 11, 0, 8),
        ("13:46:11.123", 13, 46, 11, 123_000_000, 12),
        ("13:46:11,5", 13, 46, 11, 500_000_000, 10), // Comma support
        ("00:00:00.000000001", 0, 0, 0, 1, 18),
    ])
    // swiftlint:disable:next function_parameter_count
    func scanValidTime(input: String, h: Int, m: Int, s: Int, ns: Int64, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            var cursor = 0
            let result = ChronoScanner.scanTime(from: UnsafeRawBufferPointer(buffer), at: &cursor)
            #expect(result != nil)
            #expect(result?.hour == h)
            #expect(result?.minute == m)
            #expect(result?.second == s)
            #expect(result?.nanosecond == ns)
            #expect(cursor == expectedConsumed)
        }
    }
}

// MARK: - Offset Scanning Tests

extension ScannerTests {
    @Test("ScannerTests: Scan TimeZone Offsets", arguments: [
        ("Z", 0, 1),
        ("z", 0, 1),
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
        "GMT", // Non-RFC3339
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
