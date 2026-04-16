import ChronoCore
import ChronoMath

@usableFromInline
enum ChronoPrinter {
    @usableFromInline
    @inline(__always)
    static func printDate(
        date: some DateProtocol,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        cursor += FixedWriter.write4(date.year, to: raw, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.dash, to: raw, at: cursor)
        cursor += FixedWriter.write2(date.month, to: raw, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.dash, to: raw, at: cursor)
        cursor += FixedWriter.write2(date.day, to: raw, at: cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printTime(
        time: some TimeProtocol,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        cursor += FixedWriter.write2(time.hour, to: raw, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.colon, to: raw, at: cursor)
        cursor += FixedWriter.write2(time.minute, to: raw, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.colon, to: raw, at: cursor)
        cursor += FixedWriter.write2(time.second, to: raw, at: cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printFraction(
        _ value: some BinaryInteger,
        digits: Int,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard digits > 0 else { return }
        cursor += FixedWriter.writeChar(ASCII.dot, to: raw, at: cursor)
        cursor += FixedWriter.writeFraction(value, digits: digits, to: raw, at: cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printOffset(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        if value == 0 {
            cursor += FixedWriter.writeChar(ASCII.charZ, to: raw, at: cursor)
        } else {
            cursor += FixedWriter.writeOffset(value, to: raw, at: cursor)
        }
    }
}
