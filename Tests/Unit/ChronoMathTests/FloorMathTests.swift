@testable import ChronoMath
import Testing

struct FloorMathTests {
    @Test("FloorMathTests: floorDiv with various input", arguments: [
        // Positive Numbers
        (7, 3, 2), (6, 3, 2), (1, 3, 0), (0, 3, 0),
        // Negative Numerator
        (-1, 3, -1), (-2, 3, -1), (-3, 3, -1), (-4, 3, -2), (-7, 3, -3),
        // Negative Denominator
        (1, -3, -1), (2, -3, -1), (3, -3, -1), (4, -3, -2),
        // Both Negative
        (-1, -3, 0), (-2, -3, 0), (-3, -3, 1), (-4, -3, 1), (-7, -3, 2),
        // Large Values
        (1_000_000_000, 7, 142_857_142), (-1_000_000_000, 7, -142_857_143),
        // Exact Multiples
        (9, 3, 3), (-9, 3, -3), (9, -3, -3), (-9, -3, 3),
    ])
    func floorDivInputs(num: Int64, denom: Int64, expected: Int64) {
        #expect(floorDiv(num, denom) == expected)
    }

    @Test("FloorMathTests: floorMod with various input", arguments: [
        // Positive Numbers
        (7, 3, 1), (6, 3, 0), (1, 3, 1), (0, 3, 0),
        // Negative Numerator
        (-1, 3, 2), (-2, 3, 1), (-3, 3, 0), (-4, 3, 2), (-7, 3, 2),
        // Negative Denominator
        (1, -3, -2), (2, -3, -1), (3, -3, 0), (4, -3, -2),
        // Both Negative
        (-1, -3, -1), (-2, -3, -2), (-3, -3, 0), (-4, -3, -1), (-7, -3, -1),
        // Large Values
        (1_000_000_000, 7, 6), (-1_000_000_000, 7, 1),
        // Exact Multiples
        (9, 3, 0), (-9, 3, 0), (9, -3, 0), (-9, -3, 0)
    ])
    func floorModInputs(num: Int64, denom: Int64, expected: Int64) {
        #expect(floorMod(num, denom) == expected)
    }
}
