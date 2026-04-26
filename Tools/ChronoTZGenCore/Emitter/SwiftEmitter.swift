import ChronoSystem
import ChronoTZ

struct SwiftEmitter {
    private func appendBytes<T>(_ value: T, to buffer: inout [UInt8]) {
        var val = value
        withUnsafeBytes(of: &val) { ptr in
            buffer.append(contentsOf: ptr)
        }
    }

    private func appendHeader(
        _ header: TZHeader,
        to buffer: inout [UInt8]
    ) {
        appendBytes(header.magic, to: &buffer)
        appendBytes(header.version.bigEndian, to: &buffer)
        appendBytes(header.count.bigEndian, to: &buffer)
    }

    private func appendIndexTable(
        _ table: [TZIndexEntry],
        to buffer: inout [UInt8]
    ) {
        for entry in table {
            appendBytes(entry.name, to: &buffer)
            appendBytes(entry.offset.bigEndian, to: &buffer)
            appendBytes(entry.size.bigEndian, to: &buffer)
        }
    }

    private func appendEntries(
        _ entries: [[UInt8]: UInt32],
        to buffer: inout [UInt8]
    ) {
        entries
            .sorted { $0.value < $1.value }
            .forEach { bytes, _ in
                buffer.append(contentsOf: bytes)
            }
    }

    private func writeBytesAsArray(_ fd: Int32, _ data: [UInt8], path _: String) throws {
        var output = ""

        for (idx, byte) in data.enumerated() {
            output += "0x" + String(byte, radix: 16, uppercase: true) + ", "

            // Flush to file every 16 bytes to keep memory usage low
            if (idx + 1) % 16 == 0 {
                output += "\n"
                try writeString(output, to: fd)
                output = ""
            }
        }

        if !output.isEmpty {
            try writeString(output, to: fd)
        }
    }
}

extension SwiftEmitter: Emitter {
    func emit(ctx: Packer.Context, to path: String) throws {
        let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(fd) }

        let header = """
        // swiftlint:disable:next all
        internal struct TZDatabase {
            internal static let bytes: [UInt8] = [\n
        """
        try writeString(header, to: fd)

        var buffer: [UInt8] = []
        let tzHeader: TZHeader = .iana(tableSize: ctx.indexTable.count)

        appendHeader(tzHeader, to: &buffer)
        appendIndexTable(ctx.indexTable, to: &buffer)
        appendEntries(ctx.blobCache, to: &buffer)

        try writeBytesAsArray(fd, buffer, path: path)

        let footer = "\n    ]\n}"
        try writeString(footer, to: fd)

        print("Swift source generation complete: \(path)")
    }
}
