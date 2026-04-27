import ChronoSystem
import ChronoTZ

struct CEmitter {
    private func appendBytes<T>(_ value: T, to buffer: inout [UInt8]) {
        withUnsafeBytes(of: value) { ptr in
            buffer.append(contentsOf: ptr)
        }
    }

    private func toHex(_ byte: UInt8) -> String {
        let hexChars: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
        let high = Int((byte >> 4) & 0x0F)
        let low = Int(byte & 0x0F)
        return "0x\(hexChars[high])\(hexChars[low])"
    }

    private func appendHeader(
        _ header: TZDBHeader,
        to buffer: inout [UInt8]
    ) {
        appendBytes(header.magic, to: &buffer)
        appendBytes(header.version.bigEndian, to: &buffer)
        appendBytes(header.count.bigEndian, to: &buffer)
    }

    private func appendIndexTable(
        _ table: [TZDBIndexEntry],
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
            output += toHex(byte) + ", "

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

extension CEmitter: Emitter {
    func emit(ctx: Packer.Context, to path: String) throws {
        let hPath = path + ".h"
        let cPath = path + ".c"

        // --- Header File ---
        let hfd = try FileSystem.openFile(hPath, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(hfd) }

        let headerContent = """
        #ifndef TZDB_H
        #define TZDB_H
        #include <stddef.h>
        extern const unsigned char tzdb_data[];
        extern const size_t tzdb_size;
        #endif
        """
        try writeString(headerContent, to: hfd)

        // --- Source File ---
        let cfd = try FileSystem.openFile(cPath, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(cfd) }

        let preamble = "#include \"tzdb.h\"\n\nconst unsigned char tzdb_data[] = {\n"
        try writeString(preamble, to: cfd)

        var buffer: [UInt8] = []
        let tzHeader: TZDBHeader = .iana(tableSize: ctx.indexTable.count)

        appendHeader(tzHeader, to: &buffer)
        appendIndexTable(ctx.indexTable, to: &buffer)
        appendEntries(ctx.blobCache, to: &buffer)

        try writeBytesAsArray(cfd, buffer, path: cPath)

        let footer = "\n};\nconst size_t tzdb_size = sizeof(tzdb_data);"
        try writeString(footer, to: cfd)
    }
}
