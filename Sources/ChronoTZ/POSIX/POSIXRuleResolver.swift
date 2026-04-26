import ChronoCore
import ChronoMath
import Foundation

enum POSIXRuleResolver {
    static func offset(
        for rule: POSIXRule,
        at instant: Instant
    ) -> Duration {
        let instantDays = instant.timestamp / Seconds.perDay64
        let (year, _, _) = civilDate(from: instantDays)

        let startEpoch = resolveTransition(rule.startRule, in: year, offset: Int64(rule.stdOffset))
        let endEpoch = resolveTransition(rule.endRule, in: year, offset: Int64(rule.dstOffset))

        let isDST = isInDST(
            at: instant.timestamp,
            startEpoch: startEpoch,
            endEpoch: endEpoch
        )

        return isDST ? .seconds(rule.dstOffset) : .seconds(rule.stdOffset)
    }

    static func resolveState(
        at timestamp: Int64,
        rule: POSIXRule
    ) -> POSIXRule.TransitionState {
        let instantDays = timestamp / Seconds.perDay64
        let (year, _, _) = civilDate(from: instantDays)

        let startEpoch = resolveTransition(rule.startRule, in: year, offset: Int64(rule.stdOffset))
        let endEpoch = resolveTransition(rule.endRule, in: year, offset: Int64(rule.dstOffset))

        let inGap = isGapWindow(timestamp, transition: startEpoch)
        let inAmbiguity = isAmbiguousWindow(timestamp, transition: endEpoch)

        if inGap {
            return .gap
        }

        if inAmbiguity {
            return .ambiguous
        }

        let isDST = isInDST(at: timestamp, startEpoch: startEpoch, endEpoch: endEpoch)
        return isDST ? .dst : .standard
    }
}

private extension POSIXRuleResolver {
    private static func isGapWindow(
        _ timestamp: Int64,
        transition: Int64
    ) -> Bool {
        return timestamp >= transition && timestamp < (transition - Seconds.perHour64)
    }

    private static func isAmbiguousWindow(
        _ timestamp: Int64,
        transition: Int64
    ) -> Bool {
        return timestamp >= (transition - Seconds.perHour64) && timestamp < transition
    }

    private static func isInDST(
        at unixTimestamp: Int64,
        startEpoch: Int64,
        endEpoch: Int64
    ) -> Bool {
        // Compare (Standard Hemisphere logic vs Southern Hemisphere wrap-around)
        if startEpoch < endEpoch {
            return unixTimestamp >= startEpoch && unixTimestamp < endEpoch
        } else {
            return unixTimestamp >= startEpoch || unixTimestamp < endEpoch
        }
    }

    private static func isInDST(
        at unixTimestamp: Int64,
        rule: POSIXRule,
        offset: Int64
    ) -> Bool {
        let instantDays = unixTimestamp / Seconds.perDay64
        let (year, _, _) = civilDate(from: instantDays)

        // Resolve the specific start/end timestamps for this year
        let startEpoch = resolveTransition(rule.startRule, in: year, offset: offset)
        let endEpoch = resolveTransition(rule.endRule, in: year, offset: offset)

        // Compare (Standard Hemisphere logic vs Southern Hemisphere wrap-around)
        if startEpoch < endEpoch {
            return unixTimestamp >= startEpoch && unixTimestamp < endEpoch
        } else {
            return unixTimestamp >= startEpoch || unixTimestamp < endEpoch
        }
    }

    @inline(__always)
    private static func resolveTransition(
        _ rule: POSIXRule.RuleTransition,
        in year: Int64,
        offset: Int64
    ) -> Int64 {
        let days: Int64

        switch rule.type {
        case let .month(month, week, dayOfWeek):
            if week == 5 {
                // "Last" occurrence logic: Find last day of month, backtrack to weekday
                let lastDay = lastDayOfMonth(year, UInt8(month))
                let baseDays = daysFromCivil(year: year, month: UInt8(month), day: lastDay)
                let currentWd = weekday(from: baseDays)

                // Calculate how far to backtrack to hit target weekday
                let diff = (currentWd - dayOfWeek + 7) % 7
                days = baseDays - Int64(diff)
            } else {
                // "Nth" occurrence logic: Start at 1st of month, add days to hit weekday, then add weeks
                let baseDays = daysFromCivil(year: year, month: UInt8(month), day: 1)
                let currentWd = weekday(from: baseDays)

                // Calculate forward to first occurrence
                let diff = (dayOfWeek - currentWd + 7) % 7
                // Add weeks (rule.week is 1-indexed, so 0 weeks for 1st)
                days = baseDays + Int64(diff) + Int64((week - 1) * 7)
            }

        case let .julian(dayOfYear):
            let baseDays = daysFromCivil(year: year, month: 1, day: 1)
            var dayIndex = Int64(dayOfYear)

            // Handle Leap Year: J-format ignores Feb 29.
            // If leap year and target day >= 60 (March 1st or later),
            // add 1 to skip the leap day index.
            if isLeapYear(year) && dayOfYear >= 60 {
                dayIndex += 1
            }

            days = baseDays + dayIndex - 1

        case let .dayOfYear(dayOfYear):
            // n-format includes Feb 29; simply map directly
            days = daysFromCivil(year: year, month: 1, day: 1) + Int64(dayOfYear)
        }

        return (days * Seconds.perDay64) + Int64(rule.timeSeconds) - offset
    }
}
