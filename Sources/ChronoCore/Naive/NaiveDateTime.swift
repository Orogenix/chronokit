import ChronoMath

public struct NaiveDateTime: Equatable, Hashable, Sendable {
    public let date: NaiveDate
    public let time: NaiveTime

    @inlinable
    public init(date: NaiveDate, time: NaiveTime) {
        self.date = date
        self.time = time
    }

    @inlinable
    public init?(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0
    ) {
        guard let date = NaiveDate(year: year, month: month, day: day),
              let time = NaiveTime(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        else { return nil }

        self.date = date
        self.time = time
    }
}

// MARK: - Comparability

extension NaiveDateTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.date == rhs.date {
            return lhs.time < rhs.time
        }

        return lhs.date < rhs.date
    }
}

// MARK: - Constructors

public extension NaiveDateTime {
    static let min: Self = .init(date: .min, time: .min)
    static let max: Self = .init(date: .max, time: .max)
}

// MARK: - Arithmetic

public extension NaiveDateTime {
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        let totalNanos = time.nanosecondsSinceMidnight + nanoseconds

        let extraDaysFromNanos = floorDiv(totalNanos, NanoSeconds.perDay64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perDay64)

        let extraDaysFromSecs = floorDiv(seconds, Seconds.perDay64)
        let remSecs = floorMod(seconds, Seconds.perDay64)

        let finalNanosTotal = remNanos + (remSecs * NanoSeconds.perSecond64)
        let finalDayDelta = floorDiv(finalNanosTotal, NanoSeconds.perDay64)
        let finalNanos = floorMod(finalNanosTotal, NanoSeconds.perDay64)

        return Self(
            date: date.advanced(byDays: extraDaysFromNanos + extraDaysFromSecs + finalDayDelta),
            time: NaiveTime(nanosecondsSinceMidnight: finalNanos)
        )
    }

    @inlinable
    func advanced(by duration: Duration) -> Self {
        advanced(
            bySeconds: duration.seconds,
            nanoseconds: Int64(duration.nanoseconds)
        )
    }
}

// MARK: - Addition

public extension NaiveDateTime {
    @inlinable
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    @inlinable
    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    @inlinable
    static func + (lhs: Self, rhs: CalendarInterval) -> Self {
        let newDate = lhs.date + rhs

        let currentNanos = lhs.time.nanosecondsSinceMidnight
        let totalNanos = currentNanos + rhs.nanosecond

        let dayAdjustment = floorDiv(totalNanos, NanoSeconds.perDay64)
        let finalNanos = floorMod(totalNanos, NanoSeconds.perDay64)

        let finalDate = NaiveDate(daysSinceEpoch: newDate.daysSinceEpoch + dayAdjustment)
        let finalTime = NaiveTime(nanosecondsSinceMidnight: finalNanos)

        return Self(date: finalDate, time: finalTime)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }

    @inlinable
    static func += (lhs: inout Self, rhs: CalendarInterval) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension NaiveDateTime {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Duration {
        let dayDiff = lhs.date.daysSinceEpoch - rhs.date.daysSinceEpoch
        let nanoDiff = lhs.time.nanosecondsSinceMidnight - rhs.time.nanosecondsSinceMidnight

        let totalSec = dayDiff * Seconds.perDay64

        let extraSec = floorDiv(nanoDiff, NanoSeconds.perSecond64)
        let normalizedNanos = floorMod(nanoDiff, NanoSeconds.perSecond64)

        return Duration(
            seconds: totalSec + extraSec,
            nanoseconds: normalizedNanos
        )
    }

    @inlinable
    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds)
        )
    }

    @inlinable
    static func - (lhs: Self, rhs: CalendarInterval) -> Self {
        return lhs + -rhs
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: CalendarInterval) {
        lhs = lhs - rhs
    }
}

// MARK: - Date Protocol

extension NaiveDateTime: DateProtocol {
    @inlinable
    public var year: Int32 {
        date.year
    }

    @inlinable
    public var month: Int {
        date.month
    }

    @inlinable
    public var day: Int {
        date.day
    }

    @inlinable
    public var ordinal: Int {
        date.ordinal
    }

    @inlinable
    public var weekday: Int {
        date.weekday
    }

    @inlinable
    public func with(year: Int32) -> Self? {
        guard let newDate = date.with(year: year) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(month: Int) -> Self? {
        guard let newDate = date.with(month: month) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(monthZeroBased value: Int) -> Self? {
        guard let newDate = date.with(monthZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(monthSymbol value: Month) -> Self? {
        guard let newDate = date.with(monthSymbol: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(day: Int) -> Self? {
        guard let newDate = date.with(day: day) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(dayZeroBased value: Int) -> Self? {
        guard let newDate = date.with(dayZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(ordinal: Int) -> Self? {
        guard let newDate = date.with(ordinal: ordinal) else { return nil }
        return Self(date: newDate, time: time)
    }

    @inlinable
    public func with(ordinalZeroBased value: Int) -> Self? {
        guard let newDate = date.with(ordinalZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }
}

// MARK: - Time Protocol

extension NaiveDateTime: TimeProtocol {
    @inlinable
    public var hour: Int {
        time.hour
    }

    @inlinable
    public var minute: Int {
        time.minute
    }

    @inlinable
    public var second: Int {
        time.second
    }

    @inlinable
    public var nanosecond: Int {
        time.nanosecond
    }

    @inlinable
    public func with(hour: Int) -> Self? {
        guard let newTime = time.with(hour: hour) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(minute: Int) -> Self? {
        guard let newTime = time.with(minute: minute) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(second: Int) -> Self? {
        guard let newTime = time.with(second: second) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(nanosecond: Int) -> Self? {
        guard let newTime = time.with(nanosecond: nanosecond) else { return nil }
        return Self(date: date, time: newTime)
    }
}

// MARK: - Rounding Helpers

extension NaiveDateTime {
    @usableFromInline
    func timestampNanosecondsChecked() -> Int64? {
        let (daysStamp, daysOverflow) = date
            .daysSinceEpoch
            .multipliedReportingOverflow(by: NanoSeconds.perDay64)
        if daysOverflow { return nil }

        let (stamp, stampOverflow) = daysStamp
            .addingReportingOverflow(time.nanosecondsSinceMidnight)
        if stampOverflow { return nil }

        return stamp
    }

    @usableFromInline
    static func fromTimestampNanoseconds(_ stamp: Int64) -> Self {
        let days = floorDiv(stamp, NanoSeconds.perDay64)
        let nanos = floorMod(stamp, NanoSeconds.perDay64)

        return Self(
            date: NaiveDate(daysSinceEpoch: days),
            time: NaiveTime(nanosecondsSinceMidnight: nanos)
        )
    }
}

// MARK: - Subsecond Rounding

extension NaiveDateTime: SubsecondRoundable {
    @inlinable
    public func roundSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        guard let stamp = timestampNanosecondsChecked() else { return self }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        let rounded = deltaUp <= deltaDown
            ? stamp + deltaUp
            : stamp - deltaDown

        return Self.fromTimestampNanoseconds(rounded)
    }

    @inlinable
    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        guard let stamp = timestampNanosecondsChecked() else { return self }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        let truncated = stamp - deltaDown

        return Self.fromTimestampNanoseconds(truncated)
    }
}
