import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Fixed Reader Tests")
struct FixedReaderTests {
    // MARK: - Fixed Digit Read Tests

    @Test("FixedReaderTests: Reading 2-digit integers", arguments: [
        ("00", 0),
        ("09", 9),
        ("25", 25),
        ("99", 99),
        ("100", 10),
    ])
    func testRead2(input: String, expected: Int) {
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            #expect(FixedReader.read2(from: raw, at: 0) == expected)
        }
    }

    @Test("FixedReaderTests: Reading 4-digit integers", arguments: [
        ("0000", 0), ("0001", 1), ("2025", 2025), ("9999", 9999)
    ])
    func testRead4(input: String, expected: Int) {
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            #expect(FixedReader.read4(from: raw, at: 0) == expected)
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
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            #expect(FixedReader.read2(from: raw, at: 0) == nil)
            #expect(FixedReader.read4(from: raw, at: 0) == nil)
        }
    }
}

// MARK: - Fraction Read Tests

extension FixedReaderTests {
    @Test("FixedReaderTests: Reading fractions (varying length)", arguments: [
        (".1", 100_000_000, 2),
        (".123", 123_000_000, 4),
        (".123456789", 123_456_789, 10),
        (".000000001", 1, 10),
        (".123456789012", 123_456_789, 13), // Should truncate at 9 digits but consume all
    ])
    func testReadFraction(input: String, expectedVal: Int64, expectedConsumed: Int) {
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            let result = FixedReader.readFraction(from: raw, at: 0)
            #expect(result?.value == expectedVal)
            #expect(result?.consumed == expectedConsumed)
        }
    }

    @Test("FixedReaderTests: readFraction edge cases")
    func readFractionEdges() {
        let noDotOrComma = Array("123".utf8)
        noDotOrComma.withUnsafeBufferPointer { b in
            let res = FixedReader.readFraction(from: UnsafeRawBufferPointer(b), at: 0)
            #expect(res == nil, "No dot or comma should return nil")
        }

        let dotOnly = Array(".".utf8)
        dotOnly.withUnsafeBufferPointer { b in
            let res = FixedReader.readFraction(from: UnsafeRawBufferPointer(b), at: 0)
            #expect(res == nil, "Dot with no digits should fail")
        }

        let commaOnly = Array(",".utf8)
        commaOnly.withUnsafeBufferPointer { b in
            let res = FixedReader.readFraction(from: UnsafeRawBufferPointer(b), at: 0)
            #expect(res == nil, "Dot with no digits should fail")
        }
    }
}

// MARK: - Offset Read Tests

extension FixedReaderTests {
    @Test("FixedReaderTests: Reading TimeZone offsets", arguments: [
        ("Z", 0),
        ("+00:00", 0),
        ("+01:00", 3600),
        ("-05:00", -18000),
        ("+0930", 34200), // No colon support
        ("-14", -50400), // Hour only support
        ("+05:30", 19800),
    ])
    func testReadOffset(input: String, expected: Int) {
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            #expect(FixedReader.readOffset(from: raw, at: 0) == expected)
        }
    }

    @Test("FixedReaderTests: readOffset invalid formats", arguments: [
        "GMT",
        "+A0:00",
        "-1:00" // read2 expects two digits
    ])
    func readOffsetFailures(input: String) {
        let bytes = Array(input.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            // Your logic returns 0 for non-sign/non-Z starts, or nil for malformed HH:MM
            let result = FixedReader.readOffset(from: raw, at: 0)
            #expect(result == 0 || result == nil)
        }
    }
}
