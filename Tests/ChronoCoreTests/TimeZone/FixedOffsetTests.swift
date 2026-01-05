@testable import ChronoCore
import Testing

@Suite("Fixed Offset Tests")
struct FixedOffsetTests {
    @Test("FixedOffsetTests: Identifier formatting")
    func testIdentifier() {
        #expect(FixedOffset.utc.identifier == "UTC")
        #expect(FixedOffset(seconds: 3600).identifier == "+01:00")
        #expect(FixedOffset(seconds: -18000).identifier == "-05:00")
    }

    @Test("FixedOffsetTests: Static helpers")
    func helpers() {
        let east = FixedOffset.eastUTC(3600)!
        let west = FixedOffset.westUTC(3600)!

        #expect(east.duration.seconds == 3600)
        #expect(west.duration.seconds == -3600)

        #expect(FixedOffset.eastUTC(-10) == nil)
    }

    @Test("FixedOffsetTests: Component init")
    func componentInit() {
        let offset = FixedOffset(hours: 5, minutes: 30, sign: .minus)!
        #expect(offset.duration.seconds == -19800)
        #expect(offset.identifier == "-05:30")
    }
}
