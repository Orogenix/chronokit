@testable import ChronoTZ
import Testing

struct POSIXRuleParserTests {
    @Test("POSIXRuleParserTests: Parses standard EST5EDT format correctly")
    func parseStandardFormat() {
        let input = "EST5EDT,M3.2.0,M11.1.0"
        let rule = POSIXRuleParser.parse(from: input)

        #expect(rule != nil)
        #expect(rule?.stdOffset == -18000)
        #expect(rule?.dstOffset == -14400)
    }

    @Test("POSIXRuleParserTests: Parses Eastern Hemisphere format correctly (CET)")
    func parseEasternHemisphereFormat() {
        let input = "CET-1CEST,M3.5.0,M10.5.0"
        let rule = POSIXRuleParser.parse(from: input)

        #expect(rule != nil)
        #expect(rule?.stdOffset == 3600)
        #expect(rule?.dstOffset == 7200)
    }

    @Test("POSIXRuleParserTests: Extended format with complex offsets parses correctly")
    func extendedFormat() {
        let input = "<UTC+1>-1<UTC-1>,J60/23:00,J300/1:00"
        let rule = POSIXRuleParser.parse(from: input)

        #expect(rule != nil)
        #expect(rule?.stdOffset == 3600)
        #expect(rule?.dstOffset == 7200)

        // Validate Start Rule (Julian)
        if case let .julian(day) = rule?.startRule.type {
            #expect(day == 60)
            #expect(rule?.startRule.timeSeconds == 82800)
        } else {
            Issue.record("Expected Julian rule type for start")
        }

        // Validate End Rule (Julian)
        if case let .julian(day) = rule?.endRule.type {
            #expect(day == 300)
            #expect(rule?.endRule.timeSeconds == 3600)
        } else {
            Issue.record("Expected Julian rule type for end")
        }
    }

    @Test("POSIXRuleParserTests: Parses Julian 'J' format (No Feb 29)")
    func parseJulianFormat() {
        let input = "EST5EDT,J10,J300"
        let rule = POSIXRuleParser.parse(from: input)

        // Verify Start
        if case let .julian(day) = rule?.startRule.type {
            #expect(day == 10)
        } else {
            Issue.record("Expected Julian rule type")
        }

        // Verify End
        if case let .julian(day) = rule?.endRule.type {
            #expect(day == 300)
        } else {
            Issue.record("Expected Julian rule type")
        }
    }

    @Test("POSIXRuleParserTests: Parses Day of Year 'n' format (With Feb 29)")
    func parseDayOfYearFormat() {
        let input = "EST5EDT,10,300"
        let rule = POSIXRuleParser.parse(from: input)

        if case let .dayOfYear(day) = rule?.startRule.type {
            #expect(day == 10)
        } else {
            Issue.record("Expected DayOfYear rule type")
        }

        if case let .dayOfYear(day) = rule?.endRule.type {
            #expect(day == 300)
        } else {
            Issue.record("Expected DayOfYear rule type")
        }
    }

    @Test("POSIXRuleParserTests: Parses Month.Week.Day 'M' format")
    func parseMonthWeekDayFormat() {
        let input = "EST5EDT,M3.2.0,M11.1.0"
        let rule = POSIXRuleParser.parse(from: input)

        if case let .month(m, w, d) = rule?.startRule.type {
            #expect(m == 3)
            #expect(w == 2)
            #expect(d == 0)
        } else {
            Issue.record("Expected Month rule type")
        }

        if case let .month(m, w, d) = rule?.endRule.type {
            #expect(m == 11)
            #expect(w == 1)
            #expect(d == 0)
        } else {
            Issue.record("Expected Month rule type")
        }
    }

    @Test("POSIXRuleParserTests: Handles explicit time offsets in transition")
    func parseTimeWithSeconds() {
        let input = "EST5EDT,M3.2.0/2:30:00,M11.1.0"
        let rule = POSIXRuleParser.parse(from: input)

        #expect(rule?.startRule.timeSeconds == 9000)
    }

    @Test("POSIXRuleParserTests: Handles defaults for missing times")
    func defaultTime() {
        let input = "EST5EDT,M3.2.0,M11.1.0"
        let rule = POSIXRuleParser.parse(from: input)

        #expect(rule?.startRule.timeSeconds == 7200)
    }

    @Test("POSIXRuleParserTests: Invalid inputs return nil", arguments: [
        "INVALID",
        "EST5,J999",
        "EST5,M13.1.0",
        "EST5,M1.6.0",
        "EST5,M1.1.7",
        ""
    ])
    func invalidInputsReturnNil(input: String) {
        let rule = POSIXRuleParser.parse(from: input)
        #expect(rule == nil)
    }
}
