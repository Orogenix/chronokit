import ChronoMath

public struct NaiveTime: Equatable, Hashable, Sendable {
    @usableFromInline
    let nanosecondsSinceMidnight: Int64

    public let hour: Int
    public let minute: Int
    public let second: Int
    public let nanosecond: Int

    @inlinable
    public init(nanosecondsSinceMidnight: Int64) {
        precondition(
            nanosecondsSinceMidnight >= 0 && nanosecondsSinceMidnight < NanoSeconds.perDay64,
            "Time out of bounds",
        )

        self.nanosecondsSinceMidnight = nanosecondsSinceMidnight

        let hour = nanosecondsSinceMidnight / NanoSeconds.perHour64
        let remAfterHours = nanosecondsSinceMidnight % NanoSeconds.perHour64

        let minute = remAfterHours / NanoSeconds.perMinute64
        let remAfterMinutes = remAfterHours % NanoSeconds.perMinute64

        let second = remAfterMinutes / NanoSeconds.perSecond64
        let nanos = remAfterMinutes % NanoSeconds.perSecond64

        self.hour = Int(hour)
        self.minute = Int(minute)
        self.second = Int(second)
        nanosecond = Int(nanos)
    }

    @inlinable
    public init?(hour: Int, minute: Int, second: Int, nanosecond: Int = 0) {
        guard hour >= 0, hour < 24,
              minute >= 0, minute < 60,
              second >= 0, second < 60,
              nanosecond >= 0, nanosecond < NanoSeconds.perSecond64
        else { return nil }

        self.hour = hour
        self.minute = minute
        self.second = second
        self.nanosecond = nanosecond

        nanosecondsSinceMidnight = Int64(hour) * NanoSeconds.perHour64
            + Int64(minute) * NanoSeconds.perMinute64
            + Int64(second) * NanoSeconds.perSecond64
            + Int64(nanosecond)
    }
}

extension NaiveTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.nanosecondsSinceMidnight < rhs.nanosecondsSinceMidnight
    }
}

// MARK: - Constructors

public extension NaiveTime {
    static let min: Self = .init(nanosecondsSinceMidnight: 0)
    static let max: Self = .init(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)
    static let midnight: Self = .min

    static func now(in timezone: some TimeZoneProtocol) -> Self {
        NaiveDateTime.now(in: timezone).time
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}

// MARK: - Arithmetic

public extension NaiveTime {
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        let deltaNanos = (seconds * NanoSeconds.perSecond64) + nanoseconds
        let totalNanos = nanosecondsSinceMidnight + deltaNanos
        let wrappedNanos = floorMod(totalNanos, NanoSeconds.perDay64)
        return Self(nanosecondsSinceMidnight: wrappedNanos)
    }

    @inlinable
    func advanced(by duration: Duration) -> Self {
        advanced(
            bySeconds: duration.seconds,
            nanoseconds: Int64(duration.nanoseconds),
        )
    }
}

// MARK: - Addition

public extension NaiveTime {
    @inlinable
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    @inlinable
    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension NaiveTime {
    @inlinable
    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds),
        )
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }
}

extension NaiveTime: TimeProtocol {
    @inlinable
    public func with(hour: Int) -> Self? {
        Self(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }

    @inlinable
    public func with(minute: Int) -> Self? {
        Self(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }

    @inlinable
    public func with(second: Int) -> Self? {
        Self(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }

    @inlinable
    public func with(nanosecond: Int) -> Self? {
        Self(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }
}

extension NaiveTime: SubsecondRoundable {
    @inlinable
    public func roundSubseconds(_ digits: Int) -> NaiveTime {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = nanosecondsSinceMidnight

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        let finalNanos: Int64 = if deltaUp <= deltaDown {
            floorMod(nanos + deltaUp, NanoSeconds.perDay64)
        } else {
            nanos - deltaDown
        }

        return Self(nanosecondsSinceMidnight: finalNanos)
    }

    @inlinable
    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = nanosecondsSinceMidnight

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        return Self(nanosecondsSinceMidnight: nanos - deltaDown)
    }
}

public extension NaiveTime {
    @inlinable
    func on(_ date: NaiveDate) -> NaiveDateTime {
        NaiveDateTime(date: date, time: self)
    }

    @inlinable
    func on(daysSinceEpoch days: Int64) -> NaiveDateTime {
        NaiveDateTime(
            date: NaiveDate(daysSinceEpoch: days),
            time: self,
        )
    }

    @inlinable
    func on(year: Int32, month: UInt8, day: UInt8) -> NaiveDateTime? {
        guard let date = NaiveDate(year: year, month: month, day: day) else { return nil }
        return NaiveDateTime(
            date: date,
            time: self,
        )
    }

    @inlinable
    func on(year: Int32, month: Int, day: Int) -> NaiveDateTime? {
        guard let date = NaiveDate(year: year, month: month, day: day) else { return nil }
        return NaiveDateTime(
            date: date,
            time: self,
        )
    }
}
