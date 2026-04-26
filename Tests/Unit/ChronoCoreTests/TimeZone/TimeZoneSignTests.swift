@testable import ChronoCore
import Testing

@Suite("Time Zone Sign Tests")
struct TimeZoneSignTests {
    @Test("TimeZoneSignTests: Multiplier and Apply", arguments: [
        (TimeZoneSign.plus, 1, 3600, 3600),
        (TimeZoneSign.minus, -1, 3600, -3600),
    ])
    func signMath(sign: TimeZoneSign, expectedMult: Int, input: Int, expectedApply: Int) {
        #expect(sign.multiplier == expectedMult)
        #expect(sign.apply(to: input) == expectedApply)

        // Test generic application (Int64)
        let bigValue: Int64 = 7200
        #expect(sign.apply(to: bigValue) == Int64(expectedApply == 3600 ? 7200 : -7200))
    }

    @Test("TimeZoneSignTests: String Initializer")
    func signStringInit() {
        #expect(TimeZoneSign(symbol: "+") == .plus)
        #expect(TimeZoneSign(symbol: "-") == .minus)
        #expect(TimeZoneSign(symbol: "plus") == nil)
        #expect(TimeZoneSign(symbol: "") == nil)
    }
}
