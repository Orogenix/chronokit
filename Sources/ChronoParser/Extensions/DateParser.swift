import ChronoCore

public extension NaiveDate {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedDate? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            guard let result = ChronoScanner.scanDate(from: raw, at: 0),
                  result.consumed == raw.count else { return nil }
            return result.parsed
        }

        guard let parsed else { return nil }

        self.init(
            year: Int32(parsed.year),
            month: UInt8(parsed.month),
            day: UInt8(parsed.day)
        )
    }
}
