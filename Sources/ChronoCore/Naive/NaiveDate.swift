import ChronoMath

public struct NaiveDate: Equatable, Hashable, Sendable {
    @usableFromInline
    let daysSinceEpoch: Int64

    public let year: Int32
    public let month: Int
    public let day: Int

    @inlinable
    public init(daysSinceEpoch days: Int64) {
        precondition(
            days >= CalendarConstants.minInputDay && days <= CalendarConstants.maxInputDay,
            "Day since epoch exceeds maximum supported calendar range."
        )

        let civil = civilDate(from: days)

        daysSinceEpoch = days
        year = Int32(civil.year)
        month = Int(civil.month)
        day = Int(civil.day)
    }

    @inlinable
    public init?(year: Int32, month: UInt8, day: UInt8) {
        guard month >= 1, month <= 12 else { return nil }

        guard day >= 1, day <= lastDayOfMonth(Int64(year), month)
        else { return nil }

        daysSinceEpoch = daysFromCivil(year: Int64(year), month: month, day: day)
        self.year = year
        self.month = Int(month)
        self.day = Int(day)
    }

    @inlinable
    public init?(year: Int32, month: Int, day: Int) {
        guard month >= 1, month <= 12 else { return nil }

        let months = UInt8(month)
        let days = UInt8(day)

        guard day >= 1, day <= lastDayOfMonth(Int64(year), months)
        else { return nil }

        daysSinceEpoch = daysFromCivil(year: Int64(year), month: months, day: days)
        self.year = year
        self.month = Int(month)
        self.day = Int(day)
    }
}

// MARK: - Constructors

public extension NaiveDate {
    static let min: Self = .init(daysSinceEpoch: CalendarConstants.minInputDay)
    static let max: Self = .init(daysSinceEpoch: CalendarConstants.maxInputDay)
    static let unixEpoch: Self = .init(daysSinceEpoch: 0)

    @usableFromInline
    internal var jan1: Int64 {
        daysFromCivil(year: Int64(year), month: 1, day: 1)
    }
}

extension NaiveDate: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.daysSinceEpoch < rhs.daysSinceEpoch
    }
}

// MARK: - Arithmetic

public extension NaiveDate {
    @inlinable
    func advanced(byDays days: Int64) -> Self {
        Self(daysSinceEpoch: daysSinceEpoch + days)
    }
}

// MARK: - Addition

public extension NaiveDate {
    @inlinable
    static func + (lhs: Self, rhs: Int64) -> Self {
        lhs.advanced(byDays: rhs)
    }

    @inlinable
    static func + (lhs: Int64, rhs: Self) -> Self {
        rhs.advanced(byDays: lhs)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Int64) {
        lhs = lhs + rhs
    }

    @inlinable
    static func + (lhs: Self, rhs: CalendarInterval) -> Self {
        var newYear = Int64(lhs.year)
        var newMonth = Int64(lhs.month) + Int64(rhs.month)

        // Normalize months using your floor math (1-based: 1...12)
        // Subtract 1 to make it 0-indexed for the math, then add 1 back.
        let yearAdjustment = floorDiv(newMonth - 1, 12)
        newYear += yearAdjustment
        newMonth = floorMod(newMonth - 1, 12) + 1

        // Saturate/Clamp the day
        // Example: Jan 31 + 1 Month -> Feb 28 (or 29)
        let maxDayInMonth = lastDayOfMonth(newYear, UInt8(newMonth))
        let clampedDay = Swift.min(Int64(lhs.day), Int64(maxDayInMonth))

        let baseDays = daysFromCivil(year: newYear, month: UInt8(newMonth), day: UInt8(clampedDay))

        return Self(daysSinceEpoch: baseDays + Int64(rhs.day))
    }
}

// MARK: - Substraction

public extension NaiveDate {
    @inlinable
    static func - (lhs: Self, rhs: Int64) -> Self {
        lhs.advanced(byDays: -rhs)
    }

    @inlinable
    static func - (lhs: Self, rhs: Self) -> Int64 {
        lhs.daysSinceEpoch - rhs.daysSinceEpoch
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Int64) {
        lhs = lhs - rhs
    }
}
