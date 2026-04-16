// import ChronoMath
//
// private func runFloorArithmeticIdentity(
//     nums: [Int64],
//     denoms: [Int64],
// ) -> Int {
//     for num in nums {
//         for denom in denoms where denom != 0 {
//             if num == .min, denom == -1 { continue }
//
//             let div = floorDiv(num, denom)
//             let mod = floorMod(num, denom)
//
//             let (product, overflowProduct) = denom.multipliedReportingOverflow(by: div)
//
//             if overflowProduct {
//                 preconditionFailure("Multiplication overflowed for num=\(num), denom=\(denom)")
//                 continue
//             }
//
//             let (calculatedNum, overflowedSum) = product.addingReportingOverflow(mod)
//
//             if overflowedSum {
//                 preconditionFailure("Addition overflowed for num=\(num), denom=\(denom)")
//                 continue
//             }
//
//             precondition(num == calculatedNum, "Identity failed for num=\(num), denom=\(denom)")
//
//             if denom > 0 {
//                 precondition(mod >= 0 && mod < denom, "Mod range failed for positive denom=\(denom)")
//             } else {
//                 precondition(mod <= 0 && mod > denom, "Mod range failed for negative denom=\(denom)")
//             }
//         }
//     }
//
//     return nums.count * denoms.count
// }
//
// func runArithmeticBenchmark() {
//     let criticalNumerators: [Int64] = [
//         0, 1, -1, // Simple values
//         42, -42, // Non-powers-of-two
//         .max / 2, .min / 2, // Test near 50% capacity
//     ]
//
//     let criticalDenominators: [Int64] = [
//         1, -1,
//         2, -2,
//         7, -7, // Weekdays/modulo 7
//         400, -400, // Era cycles (YEARS_PER_ERA)
//         146_097, -146_097, // DAYS_PER_ERA
//         1_000_000_000, -1_000_000_000, // Large divisors
//     ]
//
//     let t0 = getHighResTime()
//     let totalCombinationTested = runFloorArithmeticIdentity(nums: criticalNumerators, denoms: criticalDenominators)
//     let t1 = getHighResTime()
//
//     let timeElapsed = t1 - t0
//     let timePerCombination = timeElapsed / Double(totalCombinationTested)
//
//     print("✅ 84 Combinations Stress Test Complete.")
//     print("Time elapsed: \(timeElapsed) seconds")
//     print("Time per combination tested: \(timePerCombination) seconds")
// }
