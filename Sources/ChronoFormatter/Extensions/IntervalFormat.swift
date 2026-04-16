import ChronoCore
import ChronoMath

public extension CalendarInterval {
    @inlinable
    func iso8601(to buffer: UnsafeMutableRawBufferPointer) -> Int {
        var currentOffset = 0

        @inline(__always)
        func writeByte(_ byte: UInt8) {
            if currentOffset < buffer.count {
                buffer[currentOffset] = byte
                currentOffset += 1
            }
        }

        @inline(__always)
        func writeComponents(_ value: some BinaryInteger, to byte: UInt8) {
            if value != 0 {
                currentOffset += FixedWriter.writeVarInt(value, to: buffer, at: currentOffset)
                writeByte(byte)
            }
        }

        writeByte(ASCII.charP)

        let years = floorDiv(Int64(month), 12)
        let remMonths = floorMod(Int64(month), 12)

        writeComponents(years, to: ASCII.charY)
        writeComponents(remMonths, to: ASCII.charM)
        writeComponents(day, to: ASCII.charD)

        if nanosecond != 0 {
            writeByte(ASCII.charT)

            let hours = nanosecond / NanoSeconds.perHour64
            let minutes = (nanosecond % NanoSeconds.perHour64) / NanoSeconds.perMinute64
            let seconds = (nanosecond % NanoSeconds.perMinute64) / NanoSeconds.perSecond64
            let nanos = nanosecond % NanoSeconds.perSecond64

            writeComponents(hours, to: ASCII.charH)
            writeComponents(minutes, to: ASCII.charM)

            if seconds != 0 || nanos != 0 {
                currentOffset += FixedWriter.writeVarInt(seconds, to: buffer, at: currentOffset)

                if nanos != 0 {
                    writeByte(ASCII.dot)

                    FixedWriter.writeFraction(nanos, digits: 9, to: buffer, at: currentOffset)
                    currentOffset += 9
                }

                writeByte(ASCII.charS)
            }
        }

        // Edge case: Interval is zero
        if currentOffset == 1 {
            currentOffset += FixedWriter.writeVarInt(0, to: buffer, at: currentOffset)
            writeByte(ASCII.charD) // "P0D"
        }

        return currentOffset
    }
}

extension CalendarInterval: CustomStringConvertible {
    public var description: String {
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 64) { buffer in
            let length = iso8601(to: UnsafeMutableRawBufferPointer(buffer))
            return String(decoding: buffer[..<length], as: UTF8.self)
        }
    }
}
