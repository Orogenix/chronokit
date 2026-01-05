@usableFromInline
package enum NanoSeconds {
    @usableFromInline package static let perDay64: Int64 = 86_400_000_000_000
    @usableFromInline package static let perHour64: Int64 = 3_600_000_000_000
    @usableFromInline package static let perMinute64: Int64 = 60_000_000_000
    @usableFromInline package static let perSecond64: Int64 = 1_000_000_000
    @usableFromInline package static let perSecond32: Int32 = 1_000_000_000
    @usableFromInline package static let perMilliSecond64: Int64 = 1_000_000
    @usableFromInline package static let perMicroSecond64: Int64 = 1000
}

@usableFromInline
package enum MicroSeconds {
    @usableFromInline package static let perDay64: Int64 = 86_400_000_000
    @usableFromInline package static let perSecond64: Int64 = 1_000_000
}

@usableFromInline
package enum Seconds {
    @usableFromInline package static let perWeek64: Int64 = 604_800
    @usableFromInline package static let perDay64: Int64 = 86400
    @usableFromInline package static let perDay: Int = 86400
    @usableFromInline package static let perHour64: Int64 = 3600
    @usableFromInline package static let perHour: Int = 3600
    @usableFromInline package static let perMinute64: Int64 = 60
    @usableFromInline package static let perMinute: Int = 60
}
