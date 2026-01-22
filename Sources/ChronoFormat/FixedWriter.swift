import ChronoCore
import ChronoMath

@usableFromInline
enum FixedWriter {
    @usableFromInline
    @discardableResult
    @inline(__always)
    static func write2(
        _ value: some BinaryInteger,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard offset + 1 < buffer.count else { return 0 }
        let val = Int(value)
        buffer[offset] = ASCII.zero + UInt8((val / 10) % 10)
        buffer[offset + 1] = ASCII.zero + UInt8(val % 10)
        return 2
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    static func write4(
        _ value: some BinaryInteger,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard offset + 3 < buffer.count else { return 0 }
        let val = Int(value)
        buffer[offset] = ASCII.zero + UInt8((val / 1000) % 10)
        buffer[offset + 1] = ASCII.zero + UInt8((val / 100) % 10)
        buffer[offset + 2] = ASCII.zero + UInt8((val / 10) % 10)
        buffer[offset + 3] = ASCII.zero + UInt8(val % 10)
        return 4
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    static func writeFraction(
        _ value: some BinaryInteger,
        digits: Int,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard digits >= 0,
              digits <= 9,
              offset + digits <= buffer.count else { return 0 }

        let span = NanosecondMath.span(forDigits: digits)
        var val = Int(value) / Int(span)

        // Write backwards
        for index in (0 ..< digits).reversed() {
            buffer[offset + index] = ASCII.zero + UInt8(val % 10)
            val /= 10
        }

        return digits
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    static func writeOffset(
        _ value: some BinaryInteger,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard offset + 5 < buffer.count else { return 0 }

        let val = Int(value)
        let isNegative = val < 0
        let absVal = abs(val)
        let hours = absVal / Seconds.perHour
        let minutes = (absVal % Seconds.perHour) / Seconds.perMinute

        buffer[offset] = isNegative ? ASCII.dash : ASCII.plus
        write2(hours, to: buffer, at: offset + 1)
        buffer[offset + 3] = ASCII.colon
        write2(minutes, to: buffer, at: offset + 4)

        return 6
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    static func writeVarInt(
        _ value: some BinaryInteger,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        var val = Int(value)
        if val == 0 {
            if offset < buffer.count {
                buffer[offset] = ASCII.zero
                return 1
            }
            return 0
        }

        let isNegative = val < 0
        if isNegative { val = -val }

        // Find length of the number
        var temp = val
        var length = 0
        while temp > 0 {
            temp /= 10
            length += 1
        }

        let totalLength = length + (isNegative ? 1 : 0)
        guard offset + totalLength <= buffer.count else { return 0 }

        // Write digits backwards
        var writeIndex = offset + totalLength - 1
        var remaining = val
        while remaining > 0 {
            buffer[writeIndex] = ASCII.zero + UInt8(remaining % 10)
            remaining /= 10
            writeIndex -= 1
        }

        if isNegative {
            buffer[offset] = ASCII.dash
        }

        return totalLength
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    static func writeChar(
        _ char: UInt8,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard offset < buffer.count else { return 0 }
        buffer[offset] = char
        return 1
    }
}
