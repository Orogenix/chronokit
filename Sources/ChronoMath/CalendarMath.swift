@inline(__always)
public func daysFromCivil(year: Int64, month: UInt8, day: UInt8) -> Int64 {
    precondition(month >= 1 && month <= 12, "Month must be between 1 and 12.")
    precondition(
        day >= 1 && day <= lastDayOfMonth(year, month),
        "Day must be between 1 and end of month (generalize to 31).",
    )

    let years = year - (month <= 2 ? 1 : 0)
    let months = Int64(month)
    let days = Int64(day)

    let era = floorDiv(years, CalendarConstants.yearsPerEra)
    let yoe = years - era * CalendarConstants.yearsPerEra

    let marchBasedMonth = months > 2
        ? months - 3
        : months + 9

    let doy = (CalendarConstants.monthHinnantDays * marchBasedMonth + 2) / CalendarConstants.monthHinnant + days - 1
    let doe = yoe * CalendarConstants.daysPerYear + yoe / 4 - yoe / 100 + doy

    return era * CalendarConstants.daysPerEra + doe - CalendarConstants.marchBasedUnixEpochCivilOffset
}

@inline(__always)
public func civilDate(from days: Int64) -> (year: Int64, month: UInt8, day: UInt8) {
    let unixDay = days + CalendarConstants.marchBasedUnixEpochCivilOffset

    let era = floorDiv(unixDay, CalendarConstants.daysPerEra)
    let doe = unixDay - era * CalendarConstants.daysPerEra

    let yoe = (doe
        - doe / CalendarConstants.daysPer4YearsMinusOne
        + doe / CalendarConstants.daysPer100Years
        - doe / CalendarConstants.daysPerEraMinusOne) / CalendarConstants.daysPerYear

    var year = yoe + era * CalendarConstants.yearsPerEra

    let doy = doe - (CalendarConstants.daysPerYear * yoe + yoe / 4 - yoe / 100)
    let marchBasedMonthIndex = (CalendarConstants.monthHinnant * doy + 2) / CalendarConstants.monthHinnantDays

    let day = doy - (CalendarConstants.monthHinnantDays * marchBasedMonthIndex + 2) / CalendarConstants.monthHinnant + 1

    let month = marchBasedMonthIndex < 10
        ? marchBasedMonthIndex + 3
        : marchBasedMonthIndex - 9

    year += (month <= 2) ? 1 : 0

    return (year, UInt8(month), UInt8(day))
}

@inline(__always)
public func isLeapYear(_ year: Int64) -> Bool {
    (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))
}

@inline(__always)
public func lastDayOfMonthCommonYear(_ month: UInt8) -> UInt8 {
    precondition(month >= 1 && month <= 12, "Month must be between 1 and 12.")
    return CalendarConstants.daysInMonthCommonYear[Int(month - 1)]
}

@inline(__always)
public func lastDayOfMonthLeapYear(_ month: UInt8) -> UInt8 {
    precondition(month >= 1 && month <= 12, "Month must be between 1 and 12.")
    return CalendarConstants.daysInMonthLeapYear[Int(month - 1)]
}

@inline(__always)
public func lastDayOfMonth(_ year: Int64, _ month: UInt8) -> UInt8 {
    month != 2 || !isLeapYear(year) ? lastDayOfMonthCommonYear(month) : 29
}

@inline(__always)
public func weekday(from days: Int64) -> Int {
    let weekday = days >= -4 ? (days + 4) % 7 : (days + 5) % 7 + 6
    return Int(weekday)
}

@inline(__always)
public func weekdayDifference(from lhs: Int, to rhs: Int) -> Int {
    precondition(lhs >= 0 && lhs <= 6, "Weekday lhs must be in range [0, 6]")
    precondition(rhs >= 0 && rhs <= 6, "Weekday rhs must be in range [0, 6]")

    // Add 7 to the difference to ensure the result is non-negative before the modulo operation.
    // Example: (0 - 3) = -3.  (-3 + 7) = 4.  4 % 7 = 4. (Correct)
    // Example: (5 - 2) = 3.   (3 + 7) = 10. 10 % 7 = 3. (Correct)
    return (lhs - rhs + 7) % 7
}

@inline(__always)
public func nextWeekday(_ wd: Int) -> Int {
    precondition(wd >= 0 && wd <= 6, "Weekday index must be in range [0, 6]")

    // If wd is not Saturday (6), return wd + 1.
    // If wd is Saturday (6), return Sunday (0)
    return wd < 6 ? wd + 1 : 0
}

@inline(__always)
public func prevWeekday(_ wd: Int) -> Int {
    precondition(wd >= 0 && wd <= 6, "Weekday index must be in range [0, 6]")

    // If wd is not Sunday (0), return wd - 1.
    // If wd is Sunday (0), return Saturday (6).
    return wd > 0 ? wd - 1 : 6
}
