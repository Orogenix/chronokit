import ChronoMath

public typealias Period = CalendarInterval

public struct CalendarInterval: Equatable, Hashable, Sendable {
    public var month: Int32
    public var day: Int32
    public var nanosecond: Int64

    @inlinable
    public init(
        month: Int32,
        day: Int32 = 0,
        nanosecond: Int64 = 0,
    ) {
        let extraDay = nanosecond / NanoSeconds.perDay64
        let remainingNanos = nanosecond % NanoSeconds.perDay64

        self.month = month
        self.day = day + Int32(extraDay)
        self.nanosecond = remainingNanos
    }
}

public extension CalendarInterval {
    @inlinable
    static func years(_ count: Int) -> Self {
        .years(Int32(count))
    }

    @inlinable
    static func years(_ count: Int32) -> Self {
        Self(month: count * 12)
    }

    @inlinable
    static func months(_ count: Int) -> Self {
        .months(Int32(count))
    }

    @inlinable
    static func months(_ count: Int32) -> Self {
        Self(month: count)
    }

    @inlinable
    static func days(_ count: Int) -> Self {
        .days(Int32(count))
    }

    @inlinable
    static func days(_ count: Int32) -> Self {
        Self(month: 0, day: count)
    }

    @inlinable
    static func hours(_ count: Int) -> Self {
        .hours(Int64(count))
    }

    @inlinable
    static func hours(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perHour64)
    }

    @inlinable
    static func minutes(_ count: Int) -> Self {
        .minutes(Int64(count))
    }

    @inlinable
    static func minutes(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perMinute64)
    }

    @inlinable
    static func seconds(_ count: Int) -> Self {
        .seconds(Int64(count))
    }

    @inlinable
    static func seconds(_ count: Int64) -> Self {
        Self(month: 0, day: 0, nanosecond: count * NanoSeconds.perSecond64)
    }
}

public extension CalendarInterval {
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        let result = Self(
            month: lhs.month + rhs.month,
            day: lhs.day + rhs.day,
            nanosecond: lhs.nanosecond + rhs.nanosecond,
        )

        if (result.day > 0 && result.nanosecond < 0) || (result.day < 0 && result.nanosecond > 0) {
            let normalized = result.normalized
            return Self(
                month: normalized.month,
                day: normalized.day,
                nanosecond: normalized.nanosecond,
            )
        }

        return result
    }

    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs + -rhs
    }

    @inlinable
    static prefix func - (value: Self) -> Self {
        Self(
            month: -value.month,
            day: -value.day,
            nanosecond: -value.nanosecond,
        )
    }

    @inlinable
    static func * (lhs: Self, rhs: Int) -> Self {
        let factor = Int64(rhs)

        let month = Int64(lhs.month) * factor
        let day = Int64(lhs.day) * factor
        let nanos = lhs.nanosecond * factor

        let result = Self(
            month: Int32(month),
            day: Int32(day),
            nanosecond: nanos,
        )

        if (result.day > 0 && result.nanosecond < 0) || (result.day < 0 && result.nanosecond > 0) {
            let normalized = result.normalized
            return Self(month: normalized.month, day: normalized.day, nanosecond: normalized.nanosecond)
        }

        return result
    }

    @inlinable
    static func * (lhs: Int, rhs: Self) -> Self {
        rhs * lhs
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

extension CalendarInterval {
    @inlinable
    var normalized: (month: Int32, day: Int32, nanosecond: Int64) {
        let extraDay = floorDiv(nanosecond, NanoSeconds.perDay64)
        let remainingNanos = floorMod(nanosecond, NanoSeconds.perDay64)

        let totalDays = Int64(day) + extraDay

        return (
            month: month,
            day: Int32(totalDays),
            nanosecond: remainingNanos,
        )
    }
}
