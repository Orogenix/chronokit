import ChronoMath

public struct Instant: Equatable, Hashable, Sendable {
    public let seconds: Int64
    public let nanoseconds: Int32

    @inlinable
    public init(seconds: Int64, nanoseconds: Int32 = 0) {
        precondition(
            nanoseconds >= 0 && nanoseconds < NanoSeconds.perSecond32,
            "nanoseconds exceeds supported Instant's fraction range.",
        )

        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }
}

// MARK: - Constructors

public extension Instant {
    static let zero: Self = .init(seconds: 0, nanoseconds: 0)

    @inlinable
    static func now() -> Self {
        SystemClock.shared.now()
    }
}

// MARK: - Comparability

extension Instant: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.seconds == rhs.seconds {
            return lhs.nanoseconds < rhs.nanoseconds
        }
        return lhs.seconds < rhs.seconds
    }
}

// MARK: - Core Accessor

public extension Instant {
    @inlinable
    var timestamp: Int64 {
        seconds
    }

    @inlinable
    var timestampMicroseconds: Int64 {
        seconds * MicroSeconds.perSecond64 + Int64(nanoseconds) / NanoSeconds.perMicroSecond64
    }

    @inlinable
    var timestampNanoseconds: Int64 {
        seconds * NanoSeconds.perSecond64 + Int64(nanoseconds)
    }

    @inlinable
    var timestampNanosecondsChecked: Int64? {
        let (secPart, overflowMul) = seconds.multipliedReportingOverflow(by: NanoSeconds.perSecond64)
        if overflowMul { return nil }

        let (total, overflowSum) = secPart.addingReportingOverflow(Int64(nanoseconds))
        if overflowSum { return nil }

        return total
    }
}

// MARK: - Arithmetic

public extension Instant {
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        let totalNanos = Int64(self.nanoseconds) + nanoseconds
        let extraSeconds = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perSecond64)
        return Self(
            seconds: self.seconds + seconds + extraSeconds,
            nanoseconds: Int32(remNanos),
        )
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

public extension Instant {
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

public extension Instant {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Duration {
        let secDiff = lhs.seconds - rhs.seconds
        let nanoDiff = Int64(lhs.nanoseconds) - Int64(rhs.nanoseconds)

        let extraSec = floorDiv(nanoDiff, NanoSeconds.perSecond64)
        let normalizedNanos = floorMod(nanoDiff, NanoSeconds.perSecond64)

        return Duration(
            seconds: secDiff + extraSec,
            nanoseconds: normalizedNanos,
        )
    }

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

// MARK: - Subsecond Rounding

extension Instant: SubsecondRoundable {
    @inlinable
    public func roundSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = Int64(nanoseconds)

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        if deltaUp <= deltaDown {
            return advanced(bySeconds: 0, nanoseconds: deltaUp)
        } else {
            return advanced(bySeconds: 0, nanoseconds: -deltaDown)
        }
    }

    @inlinable
    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = Int64(nanoseconds)

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: -deltaDown)
    }
}

// MARK: - Duration Rounding

extension Instant: DurationRoundable {
    public typealias RoundingError = TimeRoundingError

    @inlinable
    public func round(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        if deltaUp <= deltaDown {
            return advanced(bySeconds: 0, nanoseconds: deltaUp)
        } else {
            return advanced(bySeconds: 0, nanoseconds: -deltaDown)
        }
    }

    @inlinable
    public func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: -deltaDown)
    }

    @inlinable
    public func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: span - deltaDown)
    }
}

// MARK: - Naive Conversion

public extension Instant {
    @inlinable
    func naiveDateTime(in timezone: some TimeZoneProtocol) -> NaiveDateTime {
        let offset = timezone.offset(for: self)

        let totalSecs = seconds + offset.seconds
        let totalNanos = Int64(nanoseconds) + Int64(offset.nanoseconds)

        let extraSecs = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let finalNanos = floorMod(totalNanos, NanoSeconds.perSecond64)

        let localSeconds = totalSecs + extraSecs

        let days = floorDiv(localSeconds, Seconds.perDay64)
        let secondsOfDay = floorMod(localSeconds, Seconds.perDay64)

        let nanosSinceMidnight = secondsOfDay * NanoSeconds.perSecond64 + finalNanos

        return NaiveDateTime(
            date: NaiveDate(daysSinceEpoch: days),
            time: NaiveTime(nanosecondsSinceMidnight: nanosSinceMidnight),
        )
    }

    @inlinable
    func naiveDateTimeUTC() -> NaiveDateTime {
        naiveDateTime(in: FixedOffset.utc)
    }
}

// MARK: - Date Time Conversion

public extension Instant {
    @inlinable
    func dateTime<TZ: TimeZoneProtocol>(in timezone: TZ) -> DateTime<TZ> {
        DateTime(instant: self, timezone: timezone)
    }

    @inlinable
    func dateTimeUTC() -> DateTime<FixedOffset> {
        dateTime(in: FixedOffset.utc)
    }
}
