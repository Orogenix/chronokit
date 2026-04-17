import ChronoCore
import ChronoMath

@usableFromInline
enum ChronoPrinter {
    @usableFromInline
    @inline(__always)
    static func printDate(
        _ date: some DateProtocol,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.write4(date.year, at: &cursor)
        raw.writeByte(ASCII.dash, at: &cursor)
        raw.write2(date.month, at: &cursor)
        raw.writeByte(ASCII.dash, at: &cursor)
        raw.write2(date.day, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printTime(
        _ time: some TimeProtocol,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.write2(time.hour, at: &cursor)
        raw.writeByte(ASCII.colon, at: &cursor)
        raw.write2(time.minute, at: &cursor)
        raw.writeByte(ASCII.colon, at: &cursor)
        raw.write2(time.second, at: &cursor)
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
        raw.writeByte(ASCII.dot, at: &cursor)
        raw.writeFraction(value, digits: digits, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printOffset(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        if value == 0 {
            raw.writeByte(ASCII.charZ, at: &cursor)
        } else {
            raw.writeOffset(value, at: &cursor)
        }
    }
}
