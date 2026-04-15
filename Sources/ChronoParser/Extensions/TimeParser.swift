import ChronoCore

public extension NaiveTime {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedTime? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            guard let result = ChronoScanner.scanTime(from: raw, at: 0),
                  result.consumed == raw.count else { return nil }
            return result.parsed
        }

        guard let parsed else { return nil }

        self.init(
            hour: parsed.hour,
            minute: parsed.minute,
            second: parsed.second,
            nanosecond: Int(parsed.nanosecond)
        )
    }
}
