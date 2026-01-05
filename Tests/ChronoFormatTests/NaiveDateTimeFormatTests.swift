import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("Naive Date Time Format Tests")
struct NaiveDateTimeFormatTests {
    let dt = NaiveDateTime(
        year: 2025, month: 12, day: 29,
        hour: 15, minute: 30, second: 0,
        nanosecond: 500_000_000
    )!

    @Test("NaiveDateTimeFormatTests: Default combined string uses ISO 8601")
    func defaultCombinedFormatting() {
        // This should trigger the 'DateProtocol where Self: TimeProtocol' extension
        // Default strategy is .iso8601() which is T-separated, no fraction, no offset
        #expect(dt.string() == "2025-12-29T15:30:00")
    }

    @Test("NaiveDateTimeFormatTests: Combined string with custom precision", arguments: [
        (3, "2025-12-29T15:30:00.500"),
        (0, "2025-12-29T15:30:00")
    ])
    func combinedPrecision(digits: Int, expected: String) {
        let formatter = ChronoFormatter.iso8601(digits: digits)
        #expect(dt.string(with: formatter) == expected)
    }

    @Test("NaiveDateTimeFormatTests: Combined string with space separator")
    func combinedSpaceStrategy() {
        // Verifies that 'self' is passed correctly as both date and time provider
        let formatter = ChronoFormatter.dateTimeSpace(digits: 0)
        #expect(dt.string(with: formatter) == "2025-12-29 15:30:00")
    }

    @Test("NaiveDateTimeFormatTests: Overload Priority: Combined vs Date-only")
    func overloadPriority() {
        // This is a meta-test to ensure the compiler picked the right extension.
        // If it picked the DateProtocol extension, it would return "2025-12-29"
        // because that extension defaults to .dateHyphen.

        let result = dt.string()

        #expect(result != "2025-12-29", "Should not have used the disfavored DateProtocol extension")
        #expect(result.contains("T"), "Should have used the ISO 8601 default from the combined extension")
    }
}
