@testable import ChronoCore
import Testing

@Suite("System Time Zone Tests")
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
        let instant = Instant.now()

        let offset = tz.offset(for: instant)
        let local = instant.naiveDateTime(in: FixedOffset(offset))
        let resolvedOffset = tz.offset(for: local)

        if case let .unique(finalDuration) = resolvedOffset {
            #expect(finalDuration == offset)
        }
    }

    @Test("SystemTimeZoneTests: Local to Instant mapping via SystemTimeZone")
    func localToOffsetMapping() {
        let tz = SystemTimeZone()
        // Use a known 'safe' date (not near DST changes)
        let local = NaiveDateTime(
            date: .init(year: 2026, month: 6, day: 1)!,
            time: .init(hour: 12, minute: 0, second: 0)!
        )

        let result = tz.offset(for: local)

        // On most systems, this should be unique for June
        if case let .unique(duration) = result {
            #expect(duration != .zero || tz.identifier == "UTC")
        }
    }
}
