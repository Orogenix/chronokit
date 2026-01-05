#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(WinSDK)
    import WinSDK
#endif

public protocol Clock: Sendable {
    func now() -> Instant
}

public struct SystemClock: Clock {
    public static let shared: Self = .init()

    @inlinable
    public init() {}

    public func now() -> Instant {
        #if os(Windows)
            // Windows uses 100-nanosecond intervals since January 1, 1601.
            var fileTime = FILETIME()
            GetSystemTimePreciseAsFileTime(&fileTime)

            // Convert to a 64-bit integer
            let high = UInt64(fileTime.dwHighDateTime) << 32
            let low = UInt64(fileTime.dwLowDateTime)
            let total100ns = Int64(high | low)

            // Shift epoch from 1601 to 1970 (134,774 days)
            let windowsEpochToUnixEpoch: Int64 = 116_444_736_000_000_000
            let unixTotal100ns = total100ns - windowsEpochToUnixEpoch

            return Instant(
                seconds: unixTotal100ns / 10_000_000,
                nanoseconds: Int32((unixTotal100ns % 10_000_000) * 100),
            )
        #else
            // macOS and Linux (POSIX)
            var ts = timespec()

            #if os(Linux)
                // Using the explicit clock_id_t cast ensures compatibility across different Glibc versions
                clock_gettime(Int32(CLOCK_REALTIME), &ts)
            #else
                clock_gettime(CLOCK_REALTIME, &ts)
            #endif

            return Instant(
                seconds: Int64(ts.tv_sec),
                nanoseconds: Int32(ts.tv_nsec),
            )
        #endif
    }
}
