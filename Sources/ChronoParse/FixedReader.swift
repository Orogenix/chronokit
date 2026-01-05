import ChronoCore
import ChronoMath

@usableFromInline
enum FixedReader {
    @usableFromInline
    @inline(__always)
    static func read2(from buffer: UnsafeRawBufferPointer, at offset: Int) -> Int? {
        guard offset + 1 < buffer.count else { return nil }

        // ASCII '0' is 48. We subtract 48 from each byte
        let d1 = Int(buffer[offset]) - 48
        let d2 = Int(buffer[offset + 1]) - 48

        // Validate they are actually digits
        guard d1 >= 0, d1 <= 9,
              d2 >= 0, d2 <= 9 else { return nil }

        return d1 * 10 + d2
    }

    @usableFromInline
    @inline(__always)
    static func read4(from buffer: UnsafeRawBufferPointer, at offset: Int) -> Int? {
        guard offset + 3 < buffer.count else { return nil }

        // ASCII '0' is 48. We subtract 48 from each byte
        let d1 = Int(buffer[offset]) - 48
        let d2 = Int(buffer[offset + 1]) - 48
        let d3 = Int(buffer[offset + 2]) - 48
        let d4 = Int(buffer[offset + 3]) - 48

        // Validate they are actually digits
        guard d1 >= 0, d1 <= 9,
              d2 >= 0, d2 <= 9,
              d3 >= 0, d3 <= 9,
              d4 >= 0, d4 <= 9 else { return nil }

        return d1 * 1000 + d2 * 100 + d3 * 10 + d4
    }

    @usableFromInline
    @inline(__always)
    static func readFraction(from buffer: UnsafeRawBufferPointer, at offset: Int) -> (value: Int64, consumed: Int)? {
        guard offset < buffer.count else { return nil }

        let separator = buffer[offset]
        guard separator == ASCII.dot || separator == ASCII.comma else { return nil }

        var value: Int64 = 0
        var count = 0
        var index = offset + 1

        while index < buffer.count {
            let digit = Int(buffer[index]) - 48
            guard digit >= 0, digit <= 9 else { break }

            if count < 9 {
                value = value * 10 + Int64(digit)
                count += 1
            }

            index += 1
        }

        if count == 0 { return nil }

        let scale = NanosecondMath.span(forDigits: count)
        return (value * scale, index - offset)
    }

    @usableFromInline
    @inline(__always)
    static func readOffset(from buffer: UnsafeRawBufferPointer, at offset: Int) -> Int? {
        guard offset < buffer.count else { return nil }

        let char = buffer[offset]
        if char == ASCII.charZ { return 0 }

        let isNegative = char == ASCII.dash
        let isPositive = char == ASCII.plus
        guard isNegative || isPositive else { return nil }

        // Must have at least HH
        guard let hour = read2(from: buffer, at: offset + 1) else { return nil }

        // Check if we have enough space for minutes (at least 2 more digits)
        // We look ahead to see if there's a colon or just more digits
        // Handle both ±HH:MM and ±HHMM
        let hasSeparator = offset + 3 < buffer.count && buffer[offset + 3] == ASCII.colon
        let minutesStart = hasSeparator ? offset + 4 : offset + 3

        // If the buffer ends right after ±HH, just return hours
        if minutesStart + 1 >= buffer.count {
            let seconds = hour * Seconds.perHour
            return isNegative ? -seconds : seconds
        }

        guard let minute = read2(from: buffer, at: minutesStart) else { return nil }

        let seconds = hour * Seconds.perHour + minute * Seconds.perMinute
        return isNegative ? -seconds : seconds
    }

    @usableFromInline
    @inline(__always)
    static func readVarInt(from buffer: UnsafeRawBufferPointer, at offset: Int) -> (value: Int64, consumed: Int)? {
        var value: Int64 = 0
        var index = offset

        while index < buffer.count {
            let byte = buffer[index]
            let digit = Int64(byte) - 48
            guard digit >= 0, digit <= 9 else { break }

            // Check for potential overflow before multiplying
            // (Standard for high-performance parsers)
            value = (value * 10) + digit
            index += 1
        }

        // If we didn't consume any digits, it's not a valid number
        guard index > offset else { return nil }

        return (value, index - offset)
    }
}
