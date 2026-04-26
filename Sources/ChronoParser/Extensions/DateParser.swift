import ChronoCore
import ChronoMath

public extension PlainDate {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedDate? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = raw.scanDateRFC3339(at: &cursor),
                  cursor == raw.count else { return nil }

            return result
        }

        guard let parsed else { return nil }

        self.init(
            year: Int32(parsed.year),
            month: UInt8(parsed.month),
            day: UInt8(parsed.day)
        )
    }

    @inlinable
    init?(rfc5322 string: String) {
        var input = string

        let parsed: ParsedDate? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            if raw.scanWeekday(at: &cursor) != nil {
                guard raw.expect(ASCII.comma, &cursor) else { return nil }
            }

            raw.scanFWS(at: &cursor)

            guard let result = raw.scanDateRFC5322(at: &cursor),
                  cursor == raw.count else { return nil }

            return result
        }

        guard let parsed else { return nil }

        self.init(
            year: Int32(parsed.year),
            month: UInt8(parsed.month),
            day: UInt8(parsed.day)
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
