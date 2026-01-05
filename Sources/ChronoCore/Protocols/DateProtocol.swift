import ChronoMath

public protocol DateProtocol: Equatable, Comparable {
    var year: Int32 { get }
    var yearCE: (isCE: Bool, year: UInt32) { get }
    var isLeapYear: Bool { get }

    var quarter: Int { get }

    var month: Int { get }
    var monthZeroBased: Int { get }
    var monthSymbol: Month? { get }

    var weekday: Int { get }
    var weekdaySymbol: Weekday? { get }
    var isoWeek: ISOWeek { get }

    var day: Int { get }
    var dayZeroBased: Int { get }
    var daysSinceUnixEpoch: Int { get }
    var daysInMonth: Int { get }

    var ordinal: Int { get }
    var ordinalZeroBased: Int { get }

    func with(year: Int32) -> Self?

    func with(month: Int) -> Self?
    func with(monthZeroBased value: Int) -> Self?
    func with(monthSymbol value: Month) -> Self?

    func with(day: Int) -> Self?
    func with(dayZeroBased value: Int) -> Self?

    func with(ordinal: Int) -> Self?
    func with(ordinalZeroBased value: Int) -> Self?
}

public extension DateProtocol {
    @inlinable
    var yearCE: (isCE: Bool, year: UInt32) {
        if year < 1 {
            (isCE: false, year: UInt32(1 - year))
        } else {
            (isCE: true, year: UInt32(year))
        }
    }

    @inlinable
    var isLeapYear: Bool {
        ChronoMath.isLeapYear(Int64(year))
    }

    @inlinable
    var quarter: Int {
        (month - 1) / 3 + 1
    }

    @inlinable
    var monthZeroBased: Int {
        month - 1
    }

    @inlinable
    var monthSymbol: Month? {
        Month(rawValue: month)
    }

    @inlinable
    var dayZeroBased: Int {
        day - 1
    }

    @inlinable
    var ordinalZeroBased: Int {
        ordinal - 1
    }

    @inlinable
    var weekdaySymbol: Weekday? {
        Weekday(rawValue: weekday)
    }

    @inlinable
    var isoWeek: ISOWeek {
        ISOWeek(year: Int64(year), month: UInt8(month), day: UInt8(day))
    }

    @inlinable
    var daysSinceUnixEpoch: Int {
        Int(daysFromCivil(
            year: Int64(year),
            month: UInt8(month),
            day: UInt8(day),
        ))
    }

    @inlinable
    var daysInMonth: Int {
        Int(lastDayOfMonth(Int64(year), UInt8(month)))
    }
}
