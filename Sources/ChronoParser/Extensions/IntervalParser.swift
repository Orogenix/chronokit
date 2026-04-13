import ChronoCore
import ChronoMath

extension CalendarInterval {
    @usableFromInline
    static func parse(from buffer: UnsafeRawBufferPointer) -> RawIntervalParts? {
        guard !buffer.isEmpty else { return nil }

        var index = 0
        var sign: Int64 = 1

        if buffer[index] == ASCII.dash {
            sign = -1
            index += 1
        } else if buffer[index] == ASCII.plus {
            index += 1
        }

        guard index < buffer.count,
              buffer[index] == ASCII.charP else { return nil }

        index += 1

        var parts = RawIntervalParts()
        var isTimeSection = false
        var sawAnyComponent = false
        var fractionUsed = false

        // Track the "rank" of the last designator to enforce strict ISO order
        // Y=0, M=1, D=2, H=3, M(time)=4, S=5
        var lastRank = -1

        while index < buffer.count {
            let char = buffer[index]

            if char == ASCII.charT {
                guard !isTimeSection else { return nil }

                // Forbid trailing T
                guard index + 1 < buffer.count else { return nil }

                isTimeSection = true
                index += 1

                continue
            }

            guard let (unsignedValue, consumed) = FixedReader.readVarInt(from: buffer, at: index)
            else { return nil }

            index += consumed

            let value = unsignedValue * sign

            var fractionalNanos: Int64 = 0
            let hasFraction: Bool = (index < buffer.count)
                && (buffer[index] == ASCII.dot || buffer[index] == ASCII.comma)

            if hasFraction {
                guard !fractionUsed else { return nil }

                guard let (unsignedNanos, nanosConsumed) = FixedReader.readFraction(from: buffer, at: index)
                else { return nil }

                fractionalNanos = unsignedNanos * sign
                index += nanosConsumed
                fractionUsed = true
            }

            guard index < buffer.count else { return nil }
            let designator = buffer[index]
            index += 1

            let currentRank: Int

            switch (designator, isTimeSection) {
            case (ASCII.charY, false):
                currentRank = 0
                guard !hasFraction,
                      parts.sumChecked(year: value) else { return nil }

            case (ASCII.charM, false):
                currentRank = 1
                guard !hasFraction,
                      parts.sumChecked(month: value) else { return nil }

            case (ASCII.charD, false):
                currentRank = 2
                guard !hasFraction,
                      parts.sumChecked(day: value) else { return nil }

            case (ASCII.charH, true):
                currentRank = 3
                guard !hasFraction,
                      parts.sumChecked(hour: value) else { return nil }

            case (ASCII.charM, true):
                currentRank = 4
                guard !hasFraction,
                      parts.sumChecked(minute: value) else { return nil }

            case (ASCII.charS, true):
                currentRank = 5
                guard parts.sumChecked(second: value),
                      parts.sumChecked(nanosecond: fractionalNanos) else { return nil }

            default:
                return nil
            }

            // Enforce ISO order (cannot go backwards, e.g., P1D1Y)
            guard currentRank > lastRank else { return nil }
            lastRank = currentRank
            sawAnyComponent = true

            // ISO 8601: If a fraction is used, it MUST be the last component
            if fractionUsed, index < buffer.count { return nil }
        }

        guard sawAnyComponent else { return nil }

        return parts
    }
}

extension CalendarInterval {
    @usableFromInline
    init?(from parts: RawIntervalParts) {
        guard
            parts.month >= Int32.min, parts.month <= Int32.max,
            parts.day >= Int32.min, parts.day <= Int32.max
        else { return nil }

        self.init(
            month: Int32(parts.month),
            day: Int32(parts.day),
            nanosecond: parts.nanosecond
        )
    }
}

public extension CalendarInterval {
    @inlinable
    init?(from buffer: UnsafeRawBufferPointer) {
        guard let parts = Self.parse(from: buffer) else { return nil }
        self.init(from: parts)
    }

    @inlinable
    init?(_ string: String) {
        let parts = string.utf8.withContiguousStorageIfAvailable { buffer in
            Self.parse(from: UnsafeRawBufferPointer(buffer))
        } ?? {
            var utf8 = [UInt8]()
            utf8.reserveCapacity(string.utf8.count)
            utf8.append(contentsOf: string.utf8)

            return utf8.withUnsafeBytes {
                Self.parse(from: $0)
            }
        }()

        guard let parts else { return nil }
        self.init(from: parts)
    }
}
