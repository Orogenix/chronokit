import ChronoCore
@testable import ChronoTZ
import Testing

struct IANAPlainDateTimeTests {
    let sample = PlainDateTime(year: 2026, month: 4, day: 24, hour: 10, minute: 0, second: 0)

    @Test("IANAPlainDateTimeTests: instant() conversion succeeds with valid provider")
    func instantConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: makePayload())
        mock.insertZones(tzName, tz: tz)

        let plainDateTime = try #require(sample, "Sample plain date time should valid")
        let result = try plainDateTime.instant(in: tzName, provider: mock)

        #expect(result.seconds >= 0)
    }

    @Test("IANAPlainDateTimeTests: dateTime() conversion succeeds with valid provider")
    func dateTimeConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: makePayload())
        mock.insertZones(tzName, tz: tz)

        let plainDateTime = try #require(sample, "Sample plain date time should valid")
        let result = try plainDateTime.dateTime(timezone: tzName, provider: mock)

        #expect(result.timezone.identifier == tzName)
    }

    @Test("IANAPlainDateTimeTests: throws error when TimeZone name is invalid")
    func conversionThrowsOnInvalidZone() throws {
        let mock = MockTimeZoneProvider()
        let plainDateTime = try #require(sample, "Sample plain date time should valid")

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try plainDateTime.instant(in: "Invalid/Zone", provider: mock)
        }

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try plainDateTime.dateTime(timezone: "Invalid/Zone", provider: mock)
        }
    }
}

// MARK: - Helpers

extension IANAPlainDateTimeTests {
    private func makePayload(
        transitions: [Transition] = [],
        types: [TypeDefinition] = [TypeDefinition(offset: 0, isDST: 0)],
        posixRule: String? = nil
    ) -> TZDataPayload {
        return TZDataPayload(
            transitionCount: UInt32(transitions.count),
            typeCount: UInt32(types.count),
            transitions: transitions,
            types: types,
            posixRule: posixRule
        )
    }
}
