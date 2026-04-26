import ChronoSystem
import ChronoTZ

struct BinaryEmitter {
    private func writeHeader(
        _ header: TZHeader,
        to fd: Int32
    ) throws {
        try writeBytes(header.magic, to: fd)
        try writeBytes(header.version, to: fd)
        try writeBytes(header.count, to: fd)
    }

    private func writeIndexTable(
        _ table: [TZIndexEntry],
        to fd: Int32
    ) throws {
        for entry in table {
            try writeBytes(entry.name, to: fd)
            try writeBytes(entry.offset.bigEndian, to: fd)
            try writeBytes(entry.size.bigEndian, to: fd)
        }
    }

    private func writeEntries(
        _ entries: [[UInt8]: UInt32],
        to fd: Int32
    ) throws {
        let sorted = entries.sorted { $0.value < $1.value }

        for (bytes, _) in sorted {
            try bytes.withUnsafeBufferPointer { buffer in
                try FileSystem.writeFile(
                    fd,
                    buffer: buffer.baseAddress,
                    count: buffer.count
                )
            }
        }
    }
}

extension BinaryEmitter: Emitter {
    func emit(ctx: Packer.Context, to path: String) throws {
        let tempPath = path + ".tmp"

        let fd = try FileSystem.openFile(tempPath, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(fd) }

        let header: TZHeader = .iana(tableSize: ctx.indexTable.count)
        try writeHeader(header, to: fd)
        try writeIndexTable(ctx.indexTable, to: fd)
        try writeEntries(ctx.blobCache, to: fd)

        try FileSystem.fsyncFile(fd)
        try FileSystem.renameFile(from: tempPath, to: path)

        print("Binary packing complete: \(path)")
    }
}
