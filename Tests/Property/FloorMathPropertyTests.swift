import ChronoMath
import Testing

struct FloorMathPropertyTests {
    @Test("FloorMathPropertyTests: Floor Div/Mod Identity: num == denom * quotient + remainder")
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
