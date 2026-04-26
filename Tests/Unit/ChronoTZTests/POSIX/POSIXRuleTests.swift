@testable import ChronoTZ
import Testing

struct POSIXRuleTests {
    @Test("POSIXRuleTests: Initialization succeeds with valid POSIX string")
    func initSuccess() {
        let input = "EST5EDT,M3.2.0,M11.1.0"
        let rule = POSIXRule(rawValue: input)

        #expect(rule != nil)
        #expect(rule?.stdOffset == -18000)

        if case let .month(month, _, _) = rule?.startRule.type {
            #expect(month == 3)
        } else {
            Issue.record("Expected .month rule type")
        }
    }

    @Test("POSIXRuleTests: Initialization fails (returns nil) with invalid string")
    func initFailure() {
        let invalidInput = "INVALID_FORMAT_STRING"
        let rule = POSIXRule(rawValue: invalidInput)

        #expect(rule == nil)
    }

    @Test("POSIXRuleTests: Equatable and Hashable conformance")
    func equality() {
        let rule1 = POSIXRule(rawValue: "EST5EDT,M3.2.0,M11.1.0")
        let rule2 = POSIXRule(rawValue: "EST5EDT,M3.2.0,M11.1.0")
        let rule3 = POSIXRule(rawValue: "PST8PDT,M3.2.0,M11.1.0")

        #expect(rule1 == rule2)
        #expect(rule1 != rule3)
        // Note: rule1 and rule2 are optionals, ensure unwrapping or use ==
        #expect(rule1?.hashValue == rule2?.hashValue)
    }

    @Test("POSIXRuleTests: Empty rule constant")
    func defaultRuleValue() {
        let rule: POSIXRule.RuleTransition = .defaultStart

        if case let .month(month, _, _) = rule.type {
            #expect(month == 4)
        } else {
            Issue.record("Expected .month rule type")
        }

        #expect(rule.timeSeconds == 7200)
    }

    @Test("POSIXRuleTests: Verify POSIX sign inversion (EST5 is UTC-5)")
    func verifySignInversion() {
        let rule = POSIXRule(rawValue: "EST5EDT")
        #expect(rule?.stdOffset == -18000)
        #expect(rule?.dstOffset == -14400)
    }

    @Test("POSIXRuleTests: Verify J-format (Julian) parsing")
    func verifyJulianFormat() {
        let rule = POSIXRule(rawValue: "UTC0,J60,J300")

        if case let .julian(day) = rule?.startRule.type {
            #expect(day == 60)
        } else {
            Issue.record("Expected .julian rule type")
        }
    }

    @Test("POSIXRuleTests: Verify Zero-based (n) format parsing")
    func verifyZeroBasedFormat() {
        let rule = POSIXRule(rawValue: "UTC0,59,300")

        if case let .dayOfYear(day) = rule?.startRule.type {
            #expect(day == 59)
        } else {
            Issue.record("Expected .dayOfYear rule type")
        }
    }

    @Test("POSIXRuleTests: Verify default transition time (02:00:00)")
    func verifyDefaultTime() {
        let rule = POSIXRule(rawValue: "UTC0,M3.2.0,M11.1.0")
        #expect(rule?.startRule.timeSeconds == 7200)
        #expect(rule?.endRule.timeSeconds == 7200)
    }

    @Test("POSIXRuleTests: Verify Extended Name format")
    func verifyExtendedName() {
        let rule = POSIXRule(rawValue: "<UTC+5:30>-5:30")
        #expect(rule != nil)
        let expectedOffset = Int32(5 * 3600 + 30 * 60)
        #expect(rule?.stdOffset == expectedOffset)
    }

    @Test("POSIXRuleTests: Invalid inputs return nil", arguments: [
        "EST5,J999",
        "EST5,M13.1.0",
        "EST5,M1.1.7",
        "INVALID"
    ])
    func initInvalidInputs(input: String) {
        #expect(POSIXRule(rawValue: input) == nil)
    }
}
