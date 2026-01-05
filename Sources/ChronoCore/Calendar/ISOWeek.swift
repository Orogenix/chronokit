import ChronoMath

public struct ISOWeek: Equatable, Hashable, Sendable {
    public let year: Int64
    public let week: Int

    @inline(__always)
    public init(year: Int64, week: Int) {
        self.year = year
        self.week = week
    }

    @inline(__always)
    public init(year civilYear: Int64, month: UInt8, day: UInt8) {
        let days = daysFromCivil(year: civilYear, month: month, day: day)

        // ISO weekday
        let wd = weekday(from: days)
        let isoWD = Self.isoWeekday(from: wd)

        // Thursday decides ISO year
        let thursdayDays = days + Int64(4 - isoWD)
        let (isoYear, _, _) = civilDate(from: thursdayDays)

        // Start of ISO week 1 (Monday of week containing Jan 4)
        let jan4 = daysFromCivil(year: isoYear, month: 1, day: 4)
        let jan4WD = weekday(from: jan4)
        let jan4ISOWD = Self.isoWeekday(from: jan4WD)

        let week1Start = jan4 - Int64(jan4ISOWD - 1)

        let week = Int((days - week1Start) / 7 + 1)

        assert(
            week >= 1 && week <= Self.isoWeeksInYear(isoYear),
            "Invalid ISO week computed",
        )

        year = isoYear
        self.week = week
    }
}

extension ISOWeek: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.year == rhs.year {
            return lhs.week < rhs.week
        }
        return lhs.year < rhs.year
    }
}

extension ISOWeek {
    @inline(__always)
    private static func isoWeekday(from weekday: Int) -> Int {
        // Convert 0=Sunday ... 6=Saturday
        // To ISO: 1=Monday ... 7=Sunday
        weekday == 0 ? 7 : weekday
    }

    @inline(__always)
    public static func isoWeeksInYear(_ year: Int64) -> Int {
        // Jan 1 decides
        let jan1 = daysFromCivil(year: year, month: 1, day: 1)
        let wd = weekday(from: jan1)
        let isoWD = isoWeekday(from: wd)

        // ISO-8601 rule:
        // 53 weeks if:
        //  - Jan 1 is Thursday
        //  - OR Jan 1 is Wednesday in a leap year
        if isoWD == 4 || (isoWD == 3 && isLeapYear(year)) {
            return 53
        }

        return 52
    }
}
