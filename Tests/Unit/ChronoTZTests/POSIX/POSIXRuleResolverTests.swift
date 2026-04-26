import ChronoCore
import ChronoMath
@testable import ChronoTZ
import Testing

// MARK: - Northern Hemisphere Tests

struct POSIXRuleResolverTests {
    @Test("POSIXRuleResolverTests: Returns DST offset in Summer")
    func offsetInNorthernHemisphereSummer() throws {
        // EST5EDT,M3.2.0,M11.1.0
        // EST: -18000, EDT: -14400
        let rule = try #require(POSIXRule(rawValue: "EST5EDT,M3.2.0,M11.1.0"))

        // July 1st, 2026 (In DST)
        let instant = Instant(seconds: 1_782_873_600)
        let offset = POSIXRuleResolver.offset(for: rule, at: instant)

        #expect(offset == .seconds(-14400))
    }

    @Test("POSIXRuleResolverTests: Returns Standard offset in Winter")
    func offsetInNorthernHemisphereWinter() throws {
        let rule = try #require(POSIXRule(rawValue: "EST5EDT,M3.2.0,M11.1.0"))

        // January 1st, 2026 (Not in DST)
        let instant = Instant(seconds: 1_767_225_600)
        let offset = POSIXRuleResolver.offset(for: rule, at: instant)

        #expect(offset == .seconds(-18000))
    }
}

// MARK: - Edge Case Tests

extension POSIXRuleResolverTests {
    @Test("POSIXRuleResolverTests: Handles Southern Hemisphere wrap-around")
    func wrapAroundTransition() throws {
        // Simple rule: DST starts in Oct, ends in March (Southern Hemisphere)
        // Offset: Std: 0, DST: 3600
        let rule = try #require(POSIXRule(rawValue: "UTC0CEST,M10.1.0,M3.1.0"))

        // June (Winter) -> Standard
        let winter = Instant(seconds: 1_780_617_600)
        #expect(POSIXRuleResolver.offset(for: rule, at: winter) == .seconds(0))

        // December (Summer) -> DST
        let summer = Instant(seconds: 1_765_238_400)
        #expect(POSIXRuleResolver.offset(for: rule, at: summer) == .seconds(3600))
    }

    @Test("POSIXRuleResolverTests: Leap year J-format adjustment")
    func leapYearJulianAdjustment() throws {
        // J60 = March 1st. Rule defaults to 02:00:00 transition.
        let rule = try #require(POSIXRule(rawValue: "GMT0BST,J60,J300"))

        // 1_709_251_200 (March 1st, 00:00) + 10,800 seconds (3 hours)
        // This is 03:00:00 UTC, which is safely after the 02:00:00 transition.
        let transition = Instant(seconds: 1_709_262_000)

        let offset = POSIXRuleResolver.offset(for: rule, at: transition)
        #expect(offset == .seconds(3600), "Offset should be in DST (BST)")
    }
}
