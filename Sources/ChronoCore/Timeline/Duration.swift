import ChronoMath

public struct Duration: Equatable, Hashable, Sendable {
    public let seconds: Int64
    public let nanoseconds: Int32

    @inlinable
    public init(seconds: Int64, nanoseconds: Int64 = 0) {
        if nanoseconds >= 0, nanoseconds < NanoSeconds.perSecond64 {
            self.seconds = seconds
            self.nanoseconds = Int32(nanoseconds)
            return
        }

        var sec = seconds
        var nano = nanoseconds

        sec += floorDiv(nano, NanoSeconds.perSecond64)
        nano = floorMod(nano, NanoSeconds.perSecond64)

        if nano < 0 {
            sec -= 1
            nano += NanoSeconds.perSecond64
        }

        self.seconds = sec
        self.nanoseconds = Int32(nano)
    }
}

public extension Duration {
    static let zero: Self = .init(seconds: .zero)

    @inlinable
    static func nanoseconds(_ value: Int) -> Duration {
        Duration(seconds: 0, nanoseconds: Int64(value))
    }

    @inlinable
    static func nanoseconds(_ value: Int64) -> Duration {
        Duration(seconds: 0, nanoseconds: value)
    }

    @inlinable
    static func microseconds(_ value: Int) -> Duration {
        Duration(seconds: 0, nanoseconds: Int64(value) * NanoSeconds.perMicroSecond64)
    }

    @inlinable
    static func microseconds(_ value: Int64) -> Duration {
        Duration(seconds: 0, nanoseconds: value * NanoSeconds.perMicroSecond64)
    }

    @inlinable
    static func milliseconds(_ value: Int) -> Duration {
        Duration(seconds: 0, nanoseconds: Int64(value) * NanoSeconds.perMilliSecond64)
    }

    @inlinable
    static func milliseconds(_ value: Int64) -> Duration {
        Duration(seconds: 0, nanoseconds: value * NanoSeconds.perMilliSecond64)
    }

    @inlinable
    static func seconds(_ value: Int) -> Duration {
        Duration(seconds: Int64(value), nanoseconds: 0)
    }

    @inlinable
    static func seconds(_ value: Int64) -> Duration {
        Duration(seconds: value, nanoseconds: 0)
    }

    @inlinable
    static func seconds(_ value: Double) -> Duration {
        let secs = Int64(value)
        let nanos = Int64((value - Double(secs)) * Double(NanoSeconds.perSecond64))
        return Duration(seconds: secs, nanoseconds: nanos)
    }

    @inlinable
    static func minutes(_ value: Int) -> Duration {
        Duration(seconds: Int64(value) * Seconds.perMinute64, nanoseconds: 0)
    }

    @inlinable
    static func minutes(_ value: Int64) -> Duration {
        Duration(seconds: value * Seconds.perMinute64, nanoseconds: 0)
    }

    @inlinable
    static func hours(_ value: Int) -> Duration {
        Duration(seconds: Int64(value) * Seconds.perHour64, nanoseconds: 0)
    }

    @inlinable
    static func hours(_ value: Int64) -> Duration {
        Duration(seconds: value * Seconds.perHour64, nanoseconds: 0)
    }

    @inlinable
    static func days(_ value: Int) -> Duration {
        Duration(seconds: Int64(value) * Seconds.perDay64, nanoseconds: 0)
    }

    @inlinable
    static func days(_ value: Int64) -> Duration {
        Duration(seconds: value * Seconds.perDay64, nanoseconds: 0)
    }

    @inlinable
    static func weeks(_ value: Int) -> Duration {
        Duration(seconds: Int64(value) * Seconds.perWeek64, nanoseconds: 0)
    }

    @inlinable
    static func weeks(_ value: Int64) -> Duration {
        Duration(seconds: value * Seconds.perWeek64, nanoseconds: 0)
    }
}

public extension Duration {
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

extension Duration: Comparable {
    public static func < (lhs: Duration, rhs: Duration) -> Bool {
        if lhs.seconds != rhs.seconds {
            return lhs.seconds < rhs.seconds
        }
        return lhs.nanoseconds < rhs.nanoseconds
    }
}

public extension Duration {
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        let totalNanos = Int64(lhs.nanoseconds) + Int64(rhs.nanoseconds)
        let extraSec = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perSecond64)
        return Self(
            seconds: lhs.seconds + rhs.seconds + extraSec,
            nanoseconds: remNanos,
        )
    }

    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        let totalNanos = Int64(lhs.nanoseconds) - Int64(rhs.nanoseconds)
        let extraSec = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perSecond64)
        return Self(
            seconds: lhs.seconds - rhs.seconds + extraSec,
            nanoseconds: remNanos,
        )
    }

    @inlinable
    static func * (lhs: Self, rhs: Int64) -> Self {
        let totalNanos = Int64(lhs.nanoseconds) * rhs
        let extraSec = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perSecond64)
        return Self(
            seconds: (lhs.seconds * rhs) + extraSec,
            nanoseconds: remNanos,
        )
    }

    @inlinable
    static func / (lhs: Self, rhs: Self) -> Double {
        let lhsTotalNanos = Double(lhs.seconds) * Double(NanoSeconds.perSecond64) + Double(lhs.nanoseconds)
        let rhsTotalNanos = Double(rhs.seconds) * Double(NanoSeconds.perSecond64) + Double(rhs.nanoseconds)
        return lhsTotalNanos / rhsTotalNanos
    }

    @inlinable
    static func / (lhs: Self, rhs: Int64) -> Self {
        precondition(rhs != 0, "Duration division by zero")

        let (secNanos, overflow) = lhs.seconds.multipliedReportingOverflow(by: NanoSeconds.perSecond64)

        if !overflow {
            let totalNanos = secNanos + Int64(lhs.nanoseconds)
            let quotientNanos = floorDiv(totalNanos, rhs)

            return Self(
                seconds: floorDiv(quotientNanos, NanoSeconds.perSecond64),
                nanoseconds: floorMod(quotientNanos, NanoSeconds.perSecond64),
            )
        } else {
            let quotientSec = floorDiv(lhs.seconds, rhs)
            let remainderSec = floorMod(lhs.seconds, rhs)

            let totalRemainderNanos = (remainderSec * NanoSeconds.perSecond64) + Int64(lhs.nanoseconds)
            let quotientNanos = floorDiv(totalRemainderNanos, rhs)

            return Self(
                seconds: quotientSec + floorDiv(quotientNanos, NanoSeconds.perSecond64),
                nanoseconds: floorMod(quotientNanos, NanoSeconds.perSecond64),
            )
        }
    }
}

public extension Duration {
    @inlinable
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    @inlinable
    static func *= (lhs: inout Self, rhs: Int64) {
        lhs = lhs * rhs
    }

    @inlinable
    static func /= (lhs: inout Self, rhs: Int64) {
        lhs = lhs / rhs
    }
}
