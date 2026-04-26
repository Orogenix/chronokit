#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

public enum FileSystemError: Error, Hashable, Sendable {
    case openFileFailed(Int32)
    case syncFailed(Int32)
    case renameFailed(Int32)
    case readFileFailed(Int32)
    case writeFileFailed(Int32)
    case openDirectoryFailed(path: String, code: Int32)
    case fileNotFound(Int32)
    case outOfBounds
    case mmapFailed(Int32)
    case mappedFileClosed
}

extension FileSystemError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.openFileFailed, .openFileFailed),
             (.syncFailed, .syncFailed),
             (.renameFailed, .renameFailed),
             (.readFileFailed, .readFileFailed),
             (.writeFileFailed, .writeFileFailed),
             (.fileNotFound, .fileNotFound),
             (.outOfBounds, .outOfBounds),
             (.openDirectoryFailed, .openDirectoryFailed),
             (.mmapFailed, .mmapFailed),
             (.mappedFileClosed, .mappedFileClosed):
            return true
        default:
            return false
        }
    }
}

public extension FileSystemError {
    var message: String {
        func getErrnoMessage(_ code: Int32) -> String {
            var buffer = [Int8](repeating: 0, count: 256)
            _ = strerror_r(code, &buffer, buffer.count)
            let messageBytes = buffer.prefix { $0 != 0 }
            return String(decoding: messageBytes.map(UInt8.init), as: UTF8.self)
        }

        switch self {
        case let .openFileFailed(code):
            return "Failed to open file: \(getErrnoMessage(code))"
        case let .syncFailed(code):
            return "Failed to fsync: \(getErrnoMessage(code))"
        case let .renameFailed(code):
            return "Failed to rename file: \(getErrnoMessage(code))"
        case let .readFileFailed(code):
            return "Failed to read file: \(getErrnoMessage(code))"
        case let .writeFileFailed(code):
            return "Failed to write file: \(getErrnoMessage(code))"
        case let .openDirectoryFailed(path, code):
            return "Failed to open directory at '\(path)': \(getErrnoMessage(code))"
        case let .fileNotFound(code):
            return "File not found: \(getErrnoMessage(code))"
        case let .mmapFailed(code):
            return "Memory mapping failed: \(getErrnoMessage(code))"
        case .outOfBounds:
            return "Buffer access out of bounds"
        case .mappedFileClosed:
            return "Memory mapping file closed"
        }
    }
}
