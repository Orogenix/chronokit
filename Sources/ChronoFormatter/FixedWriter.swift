import ChronoCore
import ChronoMath

@usableFromInline
enum FixedWriter {
    @usableFromInline
    @inline(__always)
    static func write2(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor + 1 < raw.count else { return }
        let val = Int(value)
        raw[cursor] = ASCII.zero + UInt8((val / 10) % 10)
        raw[cursor + 1] = ASCII.zero + UInt8(val % 10)
        cursor += 2
    }

    @usableFromInline
    @inline(__always)
    static func write4(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor + 3 < raw.count else { return }
        let val = Int(value)
        raw[cursor] = ASCII.zero + UInt8((val / 1000) % 10)
        raw[cursor + 1] = ASCII.zero + UInt8((val / 100) % 10)
        raw[cursor + 2] = ASCII.zero + UInt8((val / 10) % 10)
        raw[cursor + 3] = ASCII.zero + UInt8(val % 10)
        cursor += 4
    }

    @usableFromInline
    @inline(__always)
    static func writeFraction(
        _ value: some BinaryInteger,
        digits: Int,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard digits >= 0,
              digits <= 9,
              cursor + digits <= raw.count else { return }

        let span = NanosecondMath.span(forDigits: digits)
        var val = Int(value) / Int(span)

        // Write backward
        let start = cursor
        for index in (0 ..< digits).reversed() {
            raw[start + index] = ASCII.zero + UInt8(val % 10)
            val /= 10
        }

        cursor += digits
    }

    @usableFromInline
    @inline(__always)
    static func writeOffset(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor + 5 < raw.count else { return }

        let val = Int(value)
        let isNegative = val < 0
        let absVal = abs(val)
        let hours = absVal / Seconds.perHour
        let minutes = (absVal % Seconds.perHour) / Seconds.perMinute

        raw[cursor] = isNegative ? ASCII.dash : ASCII.plus
        cursor += 1

        write2(hours, to: raw, at: &cursor)

        raw[cursor] = ASCII.colon
        cursor += 1

        write2(minutes, to: raw, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    static func writeByte(
        _ value: UInt8,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor < raw.count else { return }
        raw[cursor] = value
        cursor += 1
    }

    @usableFromInline
    @inline(__always)
    static func writeVarInt(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        var val = Int(value)

        if val == 0 {
            guard cursor < raw.count else { return }
            raw[cursor] = ASCII.zero
            cursor += 1
            return
        }

        let isNegative = val < 0
        if isNegative { val = -val }

        // Find length of the number
        var temp = val
        var digitLength = 0
        while temp > 0 {
            temp /= 10
            digitLength += 1
        }

        let totalLength = digitLength + (isNegative ? 1 : 0)
        guard cursor + totalLength <= raw.count else { return }

        // Write digits backwards
        var writeIndex = cursor + totalLength - 1
        var remaining = val
        while remaining > 0 {
            raw[writeIndex] = ASCII.zero + UInt8(remaining % 10)
            remaining /= 10
            writeIndex -= 1
        }

        if isNegative {
            raw[cursor] = ASCII.dash
        }

        cursor += totalLength
    }
}
