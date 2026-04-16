import ChronoCore

public extension NaiveTime {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedTime? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = ChronoScanner.scanTime(from: raw, at: &cursor),
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
}
