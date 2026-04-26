#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

package enum FileMode {
    case read
    case writeCreateTruncate
}

extension FileMode {
    var flags: Int32 {
        switch self {
        case .read:
            return O_RDONLY
        case .writeCreateTruncate:
            return O_WRONLY | O_CREAT | O_TRUNC
        }
    }

    var mode: mode_t {
        switch self {
        case .read: return 0
        case .writeCreateTruncate: return 0o644
        }
    }
}
