
import ChronoCore

// MARK: - Fixed reader extension

extension UnsafeRawBufferPointer {
    @usableFromInline
    @discardableResult
    @inline(__always)
    func read2(_ cursor: inout Int) -> Int? {
        FixedReader.read2(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func read4(_ cursor: inout Int) -> Int? {
        FixedReader.read4(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func expect(_ byte: UInt8, _ cursor: inout Int) -> Bool {
        guard cursor < count, self[cursor] == byte else { return false }
        cursor += 1
        return true
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func readFraction(_ cursor: inout Int) -> Int64? {
        FixedReader.readFraction(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func readVarInt(_ cursor: inout Int) -> Int64? {
        FixedReader.readVarInt(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func pack3(_ cursor: inout Int) -> UInt32? {
        FixedReader.pack3(from: self, at: &cursor)
    }
}

// MARK: - Scanner extension

extension UnsafeRawBufferPointer {
    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanDateRFC3339(at cursor: inout Int) -> ParsedDate? {
        ChronoScanner.scanDateRFC3339(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanTimeRFC3339(at cursor: inout Int) -> ParsedTime? {
        ChronoScanner.scanTimeRFC3339(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanDateRFC5322(at cursor: inout Int) -> ParsedDate? {
        ChronoScanner.scanDateRFC5322(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanTimeRFC5322(at cursor: inout Int) -> ParsedTime? {
        ChronoScanner.scanTimeRFC5322(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanOffset(at cursor: inout Int) -> Int? {
        ChronoScanner.scanOffset(from: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func scanFWS(at cursor: inout Int) {
        ChronoScanner.scanFWS(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanMonth(at cursor: inout Int) -> Int? {
        ChronoScanner.scanMonth(from: self, at: &cursor)
    }

    @usableFromInline
    @discardableResult
    @inline(__always)
    func scanWeekday(at cursor: inout Int) -> Int? {
        ChronoScanner.scanWeekday(from: self, at: &cursor)
    }
}
