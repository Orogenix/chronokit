import ChronoCore
import ChronoMath

package struct POSIXRule: Equatable, Hashable {
    package let stdOffset: Int32
    package let dstOffset: Int32
    package let startRule: RuleTransition
    package let endRule: RuleTransition

    package enum RuleType: Equatable, Hashable {
        /// M format
        case month(
            month: Int, // 1-12
            week: Int, // 1-5 (5 = last)
            dayOfWeek: Int // 0-6 (Sun-Sat)
        )

        /// J format
        case julian(dayOfYear: Int)

        /// n format
        case dayOfYear(dayOfYear: Int)
    }

    package struct RuleTransition: Equatable, Hashable {
        package let type: RuleType
        package let timeSeconds: Int32 // Time of day
    }

    package enum TransitionState: Equatable, Hashable {
        case standard
        case dst
        case ambiguous
        case gap
    }
}

package extension POSIXRule {
    init?(rawValue: String) {
        guard let rule = POSIXRuleParser.parse(from: rawValue) else { return nil }
        stdOffset = rule.stdOffset
        dstOffset = rule.dstOffset
        startRule = rule.startRule
        endRule = rule.endRule
    }
}

package extension POSIXRule.RuleTransition {
    static let defaultStart: Self = .init(
        type: .month(
            month: 4,
            week: 1,
            dayOfWeek: 0
        ),
        timeSeconds: 7200
    )

    static let defaultEnd: Self = .init(
        type: .month(
            month: 10,
            week: 5,
            dayOfWeek: 0
        ),
        timeSeconds: 7200
    )
}
