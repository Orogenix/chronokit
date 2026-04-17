import ChronoCore

// MARK: - Fixed writer extension

extension UnsafeMutableRawBufferPointer {
    @usableFromInline
    @inline(__always)
    func write2(_ value: some BinaryInteger, at cursor: inout Int) {
        FixedWriter.write2(value, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func write4(_ value: some BinaryInteger, at cursor: inout Int) {
        FixedWriter.write4(value, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func writeFraction(_ value: some BinaryInteger, digits: Int, at cursor: inout Int) {
        FixedWriter.writeFraction(value, digits: digits, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func writeOffset(_ value: some BinaryInteger, at cursor: inout Int) {
        FixedWriter.writeOffset(value, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func writeByte(_ value: UInt8, at cursor: inout Int) {
        FixedWriter.writeByte(value, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func writeVarInt(_ value: some BinaryInteger, at cursor: inout Int) {
        FixedWriter.writeVarInt(value, to: self, at: &cursor)
    }
}

// MARK: - Printer extension

extension UnsafeMutableRawBufferPointer {
    @usableFromInline
    @inline(__always)
    func printDate(_ date: some DateProtocol, at cursor: inout Int) {
        ChronoPrinter.printDate(date, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func printTime(_ time: some TimeProtocol, at cursor: inout Int) {
        ChronoPrinter.printTime(time, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func printFraction(_ value: some BinaryInteger, digits: Int, at cursor: inout Int) {
        ChronoPrinter.printFraction(value, digits: digits, to: self, at: &cursor)
    }

    @usableFromInline
    @inline(__always)
    func printOffset(_ value: some BinaryInteger, at cursor: inout Int) {
        ChronoPrinter.printOffset(value, to: self, at: &cursor)
    }
}
