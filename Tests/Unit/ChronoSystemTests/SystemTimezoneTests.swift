import ChronoCore
@testable import ChronoSystem
import Testing

struct SystemTimeZoneTests {
    @Test("SystemTimeZoneTests: System identifier is not empty")
    func identifierRetrieval() {
        let tz = SystemTimeZone()
        let id = tz.identifier

        print("Detected System TimeZone: \(id)")
        #expect(!id.isEmpty)
        #expect(id != "Unknown")
    }

    @Test("SystemTimeZoneTests: Test Round-trip Consistency")
    func roundTrip() {
        let tz = SystemTimeZone()
        let instant = Instant(seconds: 1_777_636_800, nanoseconds: 0)

        let offset = tz.offset(for: instant)
        let plain = instant.plainDateTime(in: FixedOffset(offset))
        let resolvedOffset = tz.offset(for: plain)

        if case let .unique(metadata) = resolvedOffset {
            #expect(metadata.duration == offset)
        }
    }

    @Test("SystemTimeZoneTests: Plain to Instant mapping via SystemTimeZone")
    func plainToOffsetMapping() throws {
        let tz = SystemTimeZone()
        // Use a known 'safe' date (not near DST changes)
        let plain = try PlainDateTime(
            date: #require(.init(year: 2026, month: 6, day: 1)),
            time: #require(.init(hour: 12, minute: 0, second: 0))
        )

        let result = tz.offset(for: plain)

        // On most systems, this should be unique for June
        if case let .unique(metadata) = result {
            #expect(metadata.duration != .zero || tz.identifier == "UTC")
        }
    }
}
