#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif canImport(WinSDK)
    import WinSDK
#endif

public struct SystemTimeZone: TimeZoneProtocol {
    public init() {}

    public var identifier: String {
        #if os(Windows)
            var tzInfo = DYNAMIC_TIME_ZONE_INFORMATION()
            GetDynamicTimeZoneInformation(&tzInfo)

            // Mirroring the tuple to a pointer to read as UTF-16
            return withUnsafePointer(to: tzInfo.TimeZoneKeyName) { ptr in
                ptr.withMemoryRebound(to: UInt16.self, capacity: 128) { utf16Ptr in
                    String(decodingCString: utf16Ptr, as: UTF16.self)
                }
            }
        #elseif os(Linux) || os(macOS) || os(iOS)
            if let tzEnv = getenv("TZ") { return String(cString: tzEnv) }

            let path = "/etc/localtime"
            var buffer = [Int8](repeating: 0, count: 1024)
            let count = readlink(path, &buffer, buffer.count - 1)

            if count > 0 {
                let bytes = buffer.prefix(count).map { UInt8(bitPattern: $0) }
                let link = String(decoding: bytes, as: UTF8.self)
                let parts = link.split(separator: "/")

                // link example: /usr/share/zoneinfo/Asia/Jakarta
                if let zoneInfoIndex = parts.firstIndex(of: "zoneinfo"),
                   zoneInfoIndex + 1 < parts.count
                {
                    return parts[(zoneInfoIndex + 1)...].joined(separator: "/")
                }

                return parts.last.map(String.init) ?? "Local"
            }

            return "Local"
        #else
            return "UTC"
        #endif
    }

    public func offset(for instant: Instant) -> Duration {
        #if os(Windows)
            var tzInfo = DYNAMIC_TIME_ZONE_INFORMATION()
            let status = GetDynamicTimeZoneInformation(&tzInfo)

            let bias = switch status {
            case 1: tzInfo.StandardBias // TIME_ZONE_ID_STANDARD
            case 2: tzInfo.DaylightBias // TIME_ZONE_ID_DAYLIGHT
            default: 0
            }

            let totalBias = Int64(tzInfo.Bias) + Int64(bias)
            return .minutes(-totalBias)

        #elseif canImport(Darwin) || canImport(Glibc) || canImport(Musl)
            var tt = time_t(instant.seconds)
            var lt = tm()

            // localtime_r is thread-safe and populates 'lt' based on 'tt'
            localtime_r(&tt, &lt)

            // tm_gmtoff: seconds EAST of UTC (e.g., +07:00 is 25200)
            // Available on Darwin and Glibc/Musl.
            return .seconds(lt.tm_gmtoff)
        #else
            return .zero
        #endif
    }

    public func offset(for local: NaiveDateTime) -> LocalOffset {
        let rawInstant = local.instant(offset: .utc)
        let systemOffset = offset(for: rawInstant)
        let correctedInstant = local.instant(offset: FixedOffset(systemOffset))
        let finalOffset = offset(for: correctedInstant)
        return .unique(finalOffset)
    }
}
