import ChronoCore
@testable import ChronoTZ
import Testing

struct IANAInstantTests {
    let instant = Instant(seconds: 1_713_926_400)

    @Test("IANAInstantTests: PlainDateTime conversion succeeds with valid provider")
    func plainDateTimeSuccess() throws {
        // Create data payload
        let types = try [TypeDefinition(offset: 0, isDST: 0)]
        let transitions = try [Transition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        _ = try instant.plainDateTime(in: tzName, provider: mock)
    }

    @Test("IANAInstantTests: DateTime conversion succeeds with valid provider")
    func dateTimeSuccess() throws {
        // Create data payload
        let types = try [TypeDefinition(offset: 0, isDST: 0)]
        let transitions = try [Transition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        let result = try instant.dateTime(in: tzName, provider: mock)

        #expect(result.timezone.identifier == tzName)
    }

    @Test("IANAInstantTests: Methods throw error when TimeZone is not found")
    func conversionThrowsOnInvalidZone() throws {
        let mock = MockTimeZoneProvider()

        #expect(throws: (any Error).self) {
            try instant.plainDateTime(in: "Invalid/Zone", provider: mock)
        }

        #expect(throws: (any Error).self) {
            try instant.dateTime(in: "Invalid/Zone", provider: mock)
        }
    }
}
