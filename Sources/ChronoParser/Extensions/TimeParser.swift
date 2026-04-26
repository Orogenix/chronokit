import ChronoCore

public extension PlainTime {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedTime? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = raw.scanTimeRFC3339(at: &cursor),
                  cursor == raw.count else { return nil }

            return result
        }

        guard let parsed else { return nil }

        self.init(
            hour: parsed.hour,
            minute: parsed.minute,
            second: parsed.second,
            nanosecond: Int(parsed.nanosecond)
        )
    }

    @inlinable
    init?(rfc5322 string: String) {
        var input = string

        let parsed: ParsedTime? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = raw.scanTimeRFC5322(at: &cursor),
                  cursor == raw.count else { return nil }

            return result
        }

        guard let parsed else { return nil }

        self.init(
            hour: parsed.hour,
            minute: parsed.minute,
            second: parsed.second,
            nanosecond: Int(parsed.nanosecond)
        )
    }

    @available(
        *,
        deprecated,
        renamed: "init(rfc5322:)",
        message: "Use init(rfc5322:) which provides full compatibility with RFC 2822."
    )
    @inlinable
    @inline(__always)
    init?(rfc2822 string: String) {
        self.init(rfc5322: string)
    }
}
