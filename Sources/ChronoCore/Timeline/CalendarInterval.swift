import ChronoMath

public struct CalendarInterval: Equatable, Hashable, Sendable {
    public var month: Int32
    public var day: Int32
    public var nanosecond: Int64

    @inlinable
    public init(
        month: Int32,
        day: Int32 = 0,
        nanosecond: Int64 = 0
    ) {
        let extraDay = floorDiv(nanosecond, NanoSeconds.perDay64)
        let remainingNanos = floorMod(nanosecond, NanoSeconds.perDay64)

        self.month = month
        self.day = day + Int32(extraDay)
        self.nanosecond = remainingNanos
    }
}

public extension CalendarInterval {
    @inlinable
    static func years(_ count: Int) -> Self {
        Self(month: Int32(count) * 12)
    }

    @inlinable
    static func years(_ count: Int32) -> Self {
        Self(month: count * 12)
    }

    @inlinable
    static func months(_ count: Int) -> Self {
        Self(month: Int32(count))
    }

    @inlinable
    static func months(_ count: Int32) -> Self {
        Self(month: count)
    }

    @inlinable
    static func days(_ count: Int) -> Self {
        Self(month: 0, day: Int32(count))
    }

    @inlinable
    static func days(_ count: Int32) -> Self {
        Self(month: 0, day: count)
    }

    @inlinable
    static func hours(_ count: Int) -> Self {
        Self(month: 0, day: 0, nanosecond: Int64(count) * NanoSeconds.perHour64)
    }

    @inlinable
    static func hours(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perHour64)
    }

    @inlinable
    static func minutes(_ count: Int) -> Self {
        Self(month: 0, day: 0, nanosecond: Int64(count) * NanoSeconds.perMinute64)
    }

    @inlinable
    static func minutes(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perMinute64)
    }

    @inlinable
    static func seconds(_ count: Int) -> Self {
        Self(month: 0, day: 0, nanosecond: Int64(count) * NanoSeconds.perSecond64)
    }

    @inlinable
    static func seconds(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perSecond64)
    }
}

public extension CalendarInterval {
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(
            month: lhs.month + rhs.month,
            day: lhs.day + rhs.day,
            nanosecond: lhs.nanosecond + rhs.nanosecond
        )
    }

    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(
            month: lhs.month - rhs.month,
            day: lhs.day - rhs.day,
            nanosecond: lhs.nanosecond - rhs.nanosecond
        )
    }

    @inlinable
    static prefix func - (value: Self) -> Self {
        Self(
            month: -value.month,
            day: -value.day,
            nanosecond: -value.nanosecond
        )
    }

    @inlinable
    static func * (lhs: Self, rhs: Int) -> Self {
        Self(
            month: lhs.month * Int32(rhs),
            day: lhs.day * Int32(rhs),
            nanosecond: lhs.nanosecond * Int64(rhs)
        )
    }

    @inlinable
    static func * (lhs: Int, rhs: Self) -> Self {
        Self(
            month: Int32(lhs) * rhs.month,
            day: Int32(lhs) * rhs.day,
            nanosecond: Int64(lhs) * rhs.nanosecond
        )
    }

    @inlinable
    static func / (lhs: Self, rhs: Int) -> Self {
        precondition(rhs != 0, "CalendarInterval: division by zero")
        let denominator = Int64(rhs)

        let monthQuotient = floorDiv(Int64(lhs.month), denominator)
        let monthRemainder = floorMod(Int64(lhs.month), denominator)

        // Carry month remainder to days (using 30 days as a standard conversion factor)
        // Note: 30 is the industry standard for "Inter-component" interval math.
        let totalDays = Int64(lhs.day) + monthRemainder * 30
        let dayQuotient = floorDiv(totalDays, denominator)
        let dayRemainder = floorMod(totalDays, denominator)

        let totalNanos = lhs.nanosecond + dayRemainder * NanoSeconds.perDay64
        let nanoQuotient = floorDiv(totalNanos, denominator)

        return Self(
            month: Int32(monthQuotient),
            day: Int32(dayQuotient),
            nanosecond: nanoQuotient
        )
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    @inlinable
    static func *= (lhs: inout Self, rhs: Int) {
        lhs = lhs * rhs
    }
}
