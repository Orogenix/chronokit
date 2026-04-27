import ChronoCore
import ChronoSystem
@testable import ChronoTZ
import Testing

struct IANADateTimeTests {
    @Test("IANADateTimeTests: Initializer uses injected provider")
    func initializerUsesInjectedProvider() throws {
        // Create data payload
        let types = try [TypeDefinition(offset: 3600, isDST: 0)]
        let transitions = try [Transition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "Mock/Zone"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        let instant = Instant(seconds: 0, nanoseconds: 0)
        let dt = try DateTime(instant: instant, timezone: tzName, provider: mock)

        #expect(dt.timezone.identifier == tzName)
    }

    @Test("IANADateTimeTests: Initializer propagates provider errors")
    func initializerPropagatesErrors() throws {
        let failingMock = MockTimeZoneProvider()

        #expect(throws: TimeZoneError.zoneNotFound("Bad/Zone")) {
            _ = try DateTime(instant: .now(), timezone: "Bad/Zone", provider: failingMock)
        }
    }
}
