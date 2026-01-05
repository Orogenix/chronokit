@usableFromInline
struct RawDateTimeParts {
    @usableFromInline var year: Int = 0
    @usableFromInline var month: Int = 0
    @usableFromInline var day: Int = 0
    @usableFromInline var hour: Int = 0
    @usableFromInline var minute: Int = 0
    @usableFromInline var second: Int = 0
    @usableFromInline var nanosecond: Int64 = 0
    @usableFromInline var offset: Int?

    @usableFromInline
    @inline(__always)
    init() {}
}

@usableFromInline
struct RawIntervalParts {
    @usableFromInline var month: Int64 = 0
    @usableFromInline var day: Int64 = 0
    @usableFromInline var nanosecond: Int64 = 0

    @usableFromInline
    @inline(__always)
    init() {}
}
