import ChronoCore

public extension NaiveDate {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedDate? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = ChronoScanner.scanDate(from: raw, at: &cursor),
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
}
