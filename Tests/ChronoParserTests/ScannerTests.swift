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
            let result = ChronoScanner.scanDate(from: raw, at: 0)

            #expect(result != nil)
            #expect(result?.parsed.year == year)
            #expect(result?.parsed.month == month)
            #expect(result?.parsed.day == day)
            #expect(result?.consumed == 10)
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
            #expect(ChronoScanner.scanDate(from: UnsafeRawBufferPointer(buffer), at: 0) == nil)
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
            let result = ChronoScanner.scanTime(from: UnsafeRawBufferPointer(buffer), at: 0)
            #expect(result != nil)
            #expect(result?.parsed.hour == h)
            #expect(result?.parsed.minute == m)
            #expect(result?.parsed.second == s)
            #expect(result?.parsed.nanosecond == ns)
            #expect(result?.consumed == expectedConsumed)
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
            let result = ChronoScanner.scanOffset(from: UnsafeRawBufferPointer(buffer), at: 0)
            #expect(result != nil)
            #expect(result?.second == expectedSeconds)
            #expect(result?.consumed == expectedConsumed)
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
            #expect(ChronoScanner.scanOffset(from: UnsafeRawBufferPointer(buffer), at: 0) == nil)
        }
    }
}
