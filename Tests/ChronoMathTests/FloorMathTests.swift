@testable import ChronoMath
import Testing

@Suite("Floor Math Tests")
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

    @Test("FloorMathTests: Floor Div/Mod Identity: num == denom * quotient + remainder")
    func floorDivModIdentity() {
        // Critical numerators to test division boundaries (max/min/zero/near-limit)
        let criticalNumerators: [Int64] = [
            0, 1, -1, // Simple values
            42, -42, // Non-powers-of-two
            .max / 2, .min / 2, // Test near 50% capacity
        ]

        let criticalDenominators: [Int64] = [
            1, -1,
            2, -2,
            7, -7, // Weekdays/modulo 7
            400, -400, // Era cycles (YEARS_PER_ERA)
            146_097, -146_097, // DAYS_PER_ERA
            1_000_000_000, -1_000_000_000, // Large divisors
        ]

        // Test a wide range of inputs
        // Ensuring the identity holds: n == d * floorDiv(n, d) + floorMod(n, d)
        for num: Int64 in criticalNumerators {
            for denom: Int64 in criticalDenominators where denom != 0 {
                // Skip overflow
                if num == .min, denom == -1 { continue }

                let div = floorDiv(num, denom)
                let mod = floorMod(num, denom)

                let (product, overflowProduct) = denom.multipliedReportingOverflow(by: div)
                #expect(!overflowProduct, "Multiplication overflowed for num=\(num), denom=\(denom)")

                let (calculatedNum, overflowedSum) = product.addingReportingOverflow(mod)
                #expect(!overflowedSum, "Addition overflowed for num=\(num), denom=\(denom)")
                #expect(num == calculatedNum, "Identity failed for num=\(num), denom=\(denom)")

                if denom > 0 {
                    #expect(mod >= 0 && mod < denom, "Mod range failed for positive denom=\(denom)")
                } else {
                    #expect(mod <= 0 && mod > denom, "Mod range failed for negative denom=\(denom)")
                }
            }
        }
    }
}
