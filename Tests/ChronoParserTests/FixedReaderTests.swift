import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - Fixed Digit Reading Tests

struct FixedReaderTests {
    @Test("FixedReaderTests: Reading 2-digit integers", arguments: [
        ("00", 0),
        ("09", 9),
        ("25", 25),
        ("99", 99),
        ("100", 10),
    ])
    func testRead2(input: String, expected: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            #expect(FixedReader.read2(from: raw, at: &cursor) == expected)
        }
    }

    @Test("FixedReaderTests: Reading 4-digit integers", arguments: [
        ("0000", 0), ("0001", 1), ("2025", 2025), ("9999", 9999)
    ])
    func testRead4(input: String, expected: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            #expect(FixedReader.read4(from: raw, at: &cursor) == expected)
        }
    }

    @Test("FixedReaderTests: Read fixed-width failure cases", arguments: [
        "1", // Too short
        "1a", // Non-numeric
        "/0", // ASCII 47 (just before '0')
        ":0", // ASCII 58 (just after '9')
        "  " // Whitespace
    ])
    func readFixedFailures(input: String) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor2 = 0
            #expect(FixedReader.read2(from: raw, at: &cursor2) == nil)
            var cursor4 = 0
            #expect(FixedReader.read4(from: raw, at: &cursor4) == nil)
        }
    }
}

// MARK: - Fraction Reading Tests

extension FixedReaderTests {
    @Test("FixedReaderTests: Reading fractions (varying length)", arguments: [
        (".1", 100_000_000, 2),
        (".123", 123_000_000, 4),
        (".123456789", 123_456_789, 10),
        (".000000001", 1, 10),
        (".123456789012", 123_456_789, 13), // Should truncate at 9 digits but consume all
    ])
    func testReadFraction(input: String, expectedVal: Int64, expectedConsumed: Int) {
        var input = input
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let result = FixedReader.readFraction(from: raw, at: &cursor)
            #expect(result == expectedVal)
            #expect(cursor == expectedConsumed)
        }
    }

    @Test("FixedReaderTests: readFraction edge cases")
    func readFractionEdges() {
        var noDotOrComma = "123"
        noDotOrComma.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let res = FixedReader.readFraction(from: raw, at: &cursor)
            #expect(res == nil, "No dot or comma should return nil")
        }

        var dotOnly = "."
        dotOnly.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let res = FixedReader.readFraction(from: raw, at: &cursor)
            #expect(res == nil, "Dot with no digits should fail")
        }

        var commaOnly = ","
        commaOnly.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let res = FixedReader.readFraction(from: raw, at: &cursor)
            #expect(res == nil, "Dot with no digits should fail")
        }
    }
}
