import ChronoSystem

func readFileBytes(path: String) throws -> [UInt8] {
    let fd = try FileSystem.openFile(path, mode: .read)
    defer { FileSystem.closeFile(fd) }

    let size = try FileSystem.getFileSize(fd)
    var buffer = [UInt8](repeating: 0, count: Int(size))
    let bytesRead = try FileSystem.readFile(fd, buffer: &buffer, count: Int(size))

    guard bytesRead == size else { throw PackerError.cannotReadFile(path: path) }
    return buffer
}

func writeBytes<T>(
    _ value: T,
    to fd: Int32
) throws {
    var val = value
    try withUnsafeBytes(of: &val) { ptr in
        try FileSystem.writeFile(
            fd,
            buffer: ptr.baseAddress,
            count: MemoryLayout<T>.size
        )
    }
}

func writeString(
    _ value: String,
    to fd: Int32
) throws {
    var val = value
    try val.withUTF8 { buffer in
        try FileSystem.writeFile(
            fd,
            buffer: buffer.baseAddress,
            count: buffer.count
        )
    }
}

func writeFixedString(
    _ name: String,
    to fd: Int32,
    length: Int = 32
) throws {
    let bytes = Array(name.utf8)
    let truncated = bytes.prefix(length)

    try truncated.withUnsafeBufferPointer { buffer in
        try FileSystem.writeFile(fd, buffer: buffer.baseAddress, count: buffer.count)
    }

    if truncated.count < length {
        let padding = [UInt8](repeating: 0, count: length - truncated.count)
        try padding.withUnsafeBufferPointer { buffer in
            try FileSystem.writeFile(fd, buffer: buffer.baseAddress, count: buffer.count)
        }
    }
}
