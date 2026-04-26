#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

import ChronoCore

public struct SystemClock: Clock {
    public static let shared: Self = .init()

    @inlinable
    public init() {}

    public func now() -> Instant {
        var ts = timespec()

        #if os(Linux)
            // Using the explicit clock_id_t cast ensures compatibility across different Glibc versions
            clock_gettime(Int32(CLOCK_REALTIME), &ts)
        #else
            clock_gettime(CLOCK_REALTIME, &ts)
        #endif

        return Instant(
            seconds: Int64(ts.tv_sec),
            nanoseconds: Int32(ts.tv_nsec)
        )
    }
}
