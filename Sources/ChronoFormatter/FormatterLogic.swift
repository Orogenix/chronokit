import ChronoCore
import ChronoMath

extension ChronoFormatter {
    @usableFromInline
    @discardableResult
    @inline(__always)
    func writeDate(
        date: some DateProtocol,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        var cursor = offset
        cursor += FixedWriter.write4(date.year, to: buffer, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.dash, to: buffer, at: cursor)
        cursor += FixedWriter.write2(date.month, to: buffer, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.dash, to: buffer, at: cursor)
        cursor += FixedWriter.write2(date.day, to: buffer, at: cursor)
        return cursor - offset
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func writeTime(
        time: some TimeProtocol,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        var cursor = offset
        cursor += FixedWriter.write2(time.hour, to: buffer, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.colon, to: buffer, at: cursor)
        cursor += FixedWriter.write2(time.minute, to: buffer, at: cursor)
        cursor += FixedWriter.writeChar(ASCII.colon, to: buffer, at: cursor)
        cursor += FixedWriter.write2(time.second, to: buffer, at: cursor)
        return cursor - offset
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func writeFraction(
        _ value: some BinaryInteger,
        digits: Int,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        guard digits > 0 else { return 0 }
        var cursor = offset
        cursor += FixedWriter.writeChar(ASCII.dot, to: buffer, at: cursor)
        cursor += FixedWriter.writeFraction(value, digits: digits, to: buffer, at: cursor)
        return cursor - offset
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func writeOffset(
        _ value: some BinaryInteger,
        useZulu: Bool,
        to buffer: UnsafeMutableRawBufferPointer,
        at offset: Int,
    ) -> Int {
        if useZulu, value == 0 {
            FixedWriter.writeChar(ASCII.charZ, to: buffer, at: offset)
        } else {
            FixedWriter.writeOffset(value, to: buffer, at: offset)
        }
    }
}

public extension ChronoFormatter {
    @inlinable
    func bufferCapacity(offset: Int? = nil) -> Int {
        switch strategy {
        case .dateHyphen:
            return 10
        case .timeHyphen:
            return 8
        case let .dateTimeSpace(digits):
            return 19 + (digits > 0 ? 1 + digits : 0)
        case let .iso8601(digits, inc, zulu):
            var len = 19 + (digits > 0 ? 1 + digits : 0)
            if inc {
                let isUTC = (offset ?? 0) == 0
                len += (zulu && isUTC) ? 1 : 6
            }
            return len
        }
    }

    @inlinable
    @discardableResult
    func format(
        date: some DateProtocol,
        time: some TimeProtocol,
        offset: Int? = nil,
        to buffer: UnsafeMutableRawBufferPointer,
    ) -> Int {
        switch strategy {
        case .dateHyphen:
            return writeDate(date: date, to: buffer, at: 0)

        case .timeHyphen:
            return writeTime(time: time, to: buffer, at: 0)

        case let .dateTimeSpace(digits):
            var cursor = 0
            cursor += writeDate(date: date, to: buffer, at: cursor)
            cursor += FixedWriter.writeChar(ASCII.space, to: buffer, at: cursor)
            cursor += writeTime(time: time, to: buffer, at: cursor)
            cursor += writeFraction(time.nanosecond, digits: digits, to: buffer, at: cursor)
            return cursor

        case let .iso8601(digits, includeOffset, useZulu):
            var cursor = 0
            cursor += writeDate(date: date, to: buffer, at: cursor)
            cursor += FixedWriter.writeChar(ASCII.charT, to: buffer, at: cursor)
            cursor += writeTime(time: time, to: buffer, at: cursor)
            cursor += writeFraction(time.nanosecond, digits: digits, to: buffer, at: cursor)
            if includeOffset {
                cursor += writeOffset(offset ?? 0, useZulu: useZulu, to: buffer, at: cursor)
            }
            return cursor
        }
    }

    @inlinable
    func string(
        date: some DateProtocol,
        time: some TimeProtocol,
        offset: Int? = nil,
    ) -> String {
        let capacity = bufferCapacity(offset: offset)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
            let raw = UnsafeMutableRawBufferPointer(buffer)
            let length = self.format(date: date, time: time, offset: offset, to: raw)
            return String(decoding: buffer[..<length], as: UTF8.self)
        }
    }
}
