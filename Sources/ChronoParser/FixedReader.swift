import ChronoCore
import ChronoMath

@usableFromInline
enum FixedReader {
    @usableFromInline
    @inline(__always)
    static func read2(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int? {
        guard cursor + 1 < raw.count else { return nil }

        // ASCII '0' is 48. We subtract 48 from each byte
        let d1 = raw[cursor] &- 48
        let d2 = raw[cursor + 1] &- 48

        // Validate they are actually digits
        guard d1 <= 9, d2 <= 9 else { return nil }

        cursor += 2
        return Int(d1) * 10 + Int(d2)
    }

    @usableFromInline
    @inline(__always)
    static func read4(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int? {
        guard cursor + 3 < raw.count else { return nil }

        // ASCII '0' is 48. We subtract 48 from each byte
        let d1 = raw[cursor] &- 48
        let d2 = raw[cursor + 1] &- 48
        let d3 = raw[cursor + 2] &- 48
        let d4 = raw[cursor + 3] &- 48

        // Validate they are actually digits
        guard d1 <= 9,
              d2 <= 9,
              d3 <= 9,
              d4 <= 9 else { return nil }

        cursor += 4
        return Int(d1) * 1000 + Int(d2) * 100 + Int(d3) * 10 + Int(d4)
    }

    @usableFromInline
    @inline(__always)
    static func readFraction(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int64? {
        guard cursor < raw.count else { return nil }

        let separator = raw[cursor]
        guard separator == ASCII.dot || separator == ASCII.comma else { return nil }

        var value: Int64 = 0
        var count = 0
        var index = cursor + 1

        while index < raw.count {
            let digit = Int64(raw[index]) &- 48
            guard digit >= 0, digit <= 9 else { break }

            if count < 9 {
                value = (value * 10) + digit
                count += 1
            }

            index += 1
        }

        guard count > 0 else { return nil }

        cursor = index

        let scale = NanosecondMath.span(forDigits: count)
        return value * scale
    }

    @usableFromInline
    @inline(__always)
    static func readVarInt(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int64? {
        let start = cursor
        var value: Int64 = 0

        while cursor < raw.count {
            let digit = Int64(raw[cursor]) &- 48
            guard digit >= 0, digit <= 9 else { break }

            // Check for potential overflow before multiplying
            // (Standard for high-performance parsers)
            value = (value * 10) + digit
            cursor += 1
        }

        // If we didn't consume any digits, it's not a valid number
        guard cursor > start else { return nil }

        return value
    }
}

extension UnsafeRawBufferPointer {
    @discardableResult
    @inline(__always)
    func read2(_ cursor: inout Int) -> Int? {
        FixedReader.read2(from: self, at: &cursor)
    }

    @discardableResult
    @inline(__always)
    func read4(_ cursor: inout Int) -> Int? {
        FixedReader.read4(from: self, at: &cursor)
    }

    @discardableResult
    @inline(__always)
    func expect(_ byte: UInt8, _ cursor: inout Int) -> Bool {
        guard cursor < count, self[cursor] == byte else { return false }
        cursor += 1
        return true
    }

    @discardableResult
    @inline(__always)
    func readFraction(_ cursor: inout Int) -> Int64? {
        FixedReader.readFraction(from: self, at: &cursor)
    }
}
