import ChronoCore
import ChronoMath

extension CalendarInterval {
    @usableFromInline
    static func parse(from buffer: UnsafeRawBufferPointer) -> ParsedInterval? {
        guard !buffer.isEmpty else { return nil }

        var cursor = 0

        var sign: Int64 = 1
        if buffer.expect(ASCII.dash, &cursor) {
            sign = -1
            // index += 1
        } else {
            buffer.expect(ASCII.plus, &cursor)
            // index += 1
        }

        guard buffer.expect(ASCII.charP, &cursor) else { return nil }

        var parts = ParsedInterval()
        var isTimeSection = false
        var sawAnyComponent = false
        var fractionUsed = false

        // Track the "rank" of the last designator to enforce strict ISO order
        // Y=0, M=1, D=2, H=3, M(time)=4, S=5
        var lastRank = -1

        while cursor < buffer.count {
            if buffer.expect(ASCII.charT, &cursor) {
                guard !isTimeSection, cursor < buffer.count else { return nil }
                isTimeSection = true
                continue
            }

            guard let unsignedValue = FixedReader.readVarInt(from: buffer, at: &cursor) else { return nil }
            let value = unsignedValue * sign

            var fractionalNanos: Int64 = 0
            if let nanos = buffer.readFraction(&cursor) {
                guard !fractionUsed else { return nil }
                fractionalNanos = nanos * sign
                fractionUsed = true
            }

            guard cursor < buffer.count else { return nil }
            let designator = buffer[cursor]
            cursor += 1

            let currentRank: Int
            switch (designator, isTimeSection) {
            case (ASCII.charY, false):
                currentRank = 0
                guard !fractionUsed, parts.sumChecked(year: value) else { return nil }

            case (ASCII.charM, false):
                currentRank = 1
                guard !fractionUsed, parts.sumChecked(month: value) else { return nil }

            case (ASCII.charD, false):
                currentRank = 2
                guard !fractionUsed, parts.sumChecked(day: value) else { return nil }

            case (ASCII.charH, true):
                currentRank = 3
                guard !fractionUsed, parts.sumChecked(hour: value) else { return nil }

            case (ASCII.charM, true):
                currentRank = 4
                guard !fractionUsed, parts.sumChecked(minute: value) else { return nil }

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
            if fractionUsed, cursor < buffer.count { return nil }
        }

        return sawAnyComponent ? parts : nil
    }
}

extension CalendarInterval {
    @usableFromInline
    init?(from parts: ParsedInterval) {
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
