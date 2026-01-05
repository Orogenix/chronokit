@testable import ChronoMath
import Testing

@Suite("Nanosecond Math Tests")
struct NanosecondMathTests {
    @Test("NanosecondMathTests: Calculates correct power of 10 for all valid digits", arguments: [
        (0, 1),
        (1, 10),
        (2, 100),
        (3, 1000),
        (4, 10000),
        (5, 100_000),
        (6, 1_000_000),
        (7, 10_000_000),
        (8, 100_000_000),
        (9, 1_000_000_000),
    ])
    func pow10Mapping(n: Int, expected: Int) {
        #expect(NanosecondMath.pow10(n) == expected)
    }

    @Test("NanosecondMathTests: Span for digits mapping", arguments: [
        (0, 1_000_000_000), // 0 digits = 1 second
        (3, 1_000_000), // 3 digits = 1 millisecond
        (6, 1000), // 6 digits = 1 microsecond
        (9, 1), // 9 digits = 1 nanosecond
        (12, 1), // Cap at 1
    ])
    func spanMapping(digits: Int, expected: Int64) {
        #expect(NanosecondMath.span(forDigits: digits) == expected)
    }

    @Test("NanosecondMathTests: Time padding format", arguments: [
        (0, "00"),
        (9, "09"),
        (10, "10"),
        (59, "59")
    ])
    func padding(value: Int, expected: String) {
        #expect(value.paddedTwoDigit == expected)
    }
}
