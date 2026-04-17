import ChronoCore
import ChronoMath

public extension NaiveDate {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: ParsedDate? = input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let result = ChronoScanner.scanDateRFC3339(from: raw, at: &cursor),
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

            if ChronoScanner.scanWeekday(from: raw, at: &cursor) != nil {
                guard raw.expect(ASCII.comma, &cursor) else { return nil }
            }

            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let result = ChronoScanner.scanDateRFC5322(from: raw, at: &cursor),
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
