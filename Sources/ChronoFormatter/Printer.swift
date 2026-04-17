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
    static func printOffsetRFC3339(
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

    @usableFromInline
    @inline(__always)
    static func printOffsetRFC5322(
        _ value: some BinaryInteger,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        let isNegative = value < 0
        let absSeconds = abs(Int64(value))
        let hours = absSeconds / Seconds.perHour64
        let minutes = (absSeconds % Seconds.perHour64) / Seconds.perMinute64

        raw.writeByte(isNegative ? ASCII.dash : ASCII.plus, at: &cursor)
        raw.write2(hours, at: &cursor)
        raw.write2(minutes, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    static func printMonth(
        _ value: Month,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor + 2 < raw.count else { return }
        let bytes: (UInt8, UInt8, UInt8) = switch value {
        case .january: (ASCII.charJ, ASCII.lowerA, ASCII.lowerN)
        case .february: (ASCII.charF, ASCII.lowerE, ASCII.lowerB)
        case .march: (ASCII.charM, ASCII.lowerA, ASCII.lowerR)
        case .april: (ASCII.charA, ASCII.lowerP, ASCII.lowerR)
        case .may: (ASCII.charM, ASCII.lowerA, ASCII.lowerY)
        case .june: (ASCII.charJ, ASCII.lowerU, ASCII.lowerN)
        case .july: (ASCII.charJ, ASCII.lowerU, ASCII.lowerL)
        case .august: (ASCII.charA, ASCII.lowerU, ASCII.lowerG)
        case .september: (ASCII.charS, ASCII.lowerE, ASCII.lowerP)
        case .october: (ASCII.charO, ASCII.lowerC, ASCII.lowerT)
        case .november: (ASCII.charN, ASCII.lowerO, ASCII.lowerV)
        case .december: (ASCII.charD, ASCII.lowerE, ASCII.lowerC)
        }
        raw[cursor] = bytes.0
        raw[cursor + 1] = bytes.1
        raw[cursor + 2] = bytes.2
        cursor += 3
    }

    @usableFromInline
    @inline(__always)
    static func printWeekday(
        _ value: Weekday,
        to raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        guard cursor + 2 < raw.count else { return }
        let bytes: (UInt8, UInt8, UInt8) = switch value {
        case .monday: (ASCII.charM, ASCII.lowerO, ASCII.lowerN)
        case .tuesday: (ASCII.charT, ASCII.lowerU, ASCII.lowerE)
        case .wednesday: (ASCII.charW, ASCII.lowerE, ASCII.lowerD)
        case .thursday: (ASCII.charT, ASCII.lowerH, ASCII.lowerU)
        case .friday: (ASCII.charF, ASCII.lowerR, ASCII.lowerI)
        case .saturday: (ASCII.charS, ASCII.lowerA, ASCII.lowerT)
        case .sunday: (ASCII.charS, ASCII.lowerU, ASCII.lowerN)
        }
        raw[cursor] = bytes.0
        raw[cursor + 1] = bytes.1
        raw[cursor + 2] = bytes.2
        cursor += 3
    }
}
