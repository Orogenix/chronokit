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
