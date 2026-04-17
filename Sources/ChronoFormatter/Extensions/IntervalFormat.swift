import ChronoCore
import ChronoMath

public extension CalendarInterval {
    @inlinable
    @discardableResult
    func parse(_ raw: UnsafeMutableRawBufferPointer, at cursor: inout Int) -> Int {
        let start = cursor

        raw.writeByte(ASCII.charP, at: &cursor)

        let years = floorDiv(Int64(month), 12)
        let remMonths = floorMod(Int64(month), 12)

        if years != 0 {
            raw.writeVarInt(years, at: &cursor)
            raw.writeByte(ASCII.charY, at: &cursor)
        }

        if remMonths != 0 {
            raw.writeVarInt(remMonths, at: &cursor)
            raw.writeByte(ASCII.charM, at: &cursor)
        }

        if day != 0 {
            raw.writeVarInt(day, at: &cursor)
            raw.writeByte(ASCII.charD, at: &cursor)
        }

        if nanosecond != 0 {
            raw.writeByte(ASCII.charT, at: &cursor)

            let hours = nanosecond / NanoSeconds.perHour64
            let minutes = (nanosecond % NanoSeconds.perHour64) / NanoSeconds.perMinute64
            let seconds = (nanosecond % NanoSeconds.perMinute64) / NanoSeconds.perSecond64
            let nanos = nanosecond % NanoSeconds.perSecond64

            if hours != 0 {
                raw.writeVarInt(hours, at: &cursor)
                raw.writeByte(ASCII.charH, at: &cursor)
            }

            if minutes != 0 {
                raw.writeVarInt(minutes, at: &cursor)
                raw.writeByte(ASCII.charM, at: &cursor)
            }

            if seconds != 0 || nanos != 0 {
                raw.writeVarInt(seconds, at: &cursor)

                if nanos != 0 {
                    raw.writeByte(ASCII.dot, at: &cursor)
                    raw.writeFraction(nanos, digits: 9, at: &cursor)
                }

                raw.writeByte(ASCII.charS, at: &cursor)
            }
        }

        // Edge case: Interval is zero
        if cursor == 1 {
            raw.writeVarInt(0, at: &cursor)
            raw.writeByte(ASCII.charD, at: &cursor) // "P0D"
        }

        return cursor - start
    }
}

extension CalendarInterval: CustomStringConvertible {
    public var description: String {
        let capacity = 64

        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                parse(raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                let length = parse(raw, at: &cursor)
                return String(decoding: buffer[..<length], as: UTF8.self)
            }
        }
    }
}
