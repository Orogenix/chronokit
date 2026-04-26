import ChronoCore
@testable import ChronoTZ
import Testing

struct IANANaiveDateTimeTests {
    let sample = NaiveDateTime(year: 2026, month: 4, day: 24, hour: 10, minute: 0, second: 0)

    @Test("IANANaiveDateTimeTests: instant() conversion succeeds with valid provider")
    func instantConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: makePayload())
        mock.insertZones(tzName, tz: tz)

        let naiveDateTime = try #require(sample, "Sample naive date time should valid")
        let result = try naiveDateTime.instant(in: tzName, provider: mock)

        #expect(result.seconds >= 0)
    }

    @Test("IANANaiveDateTimeTests: dateTime() conversion succeeds with valid provider")
    func dateTimeConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: makePayload())
        mock.insertZones(tzName, tz: tz)

        let naiveDateTime = try #require(sample, "Sample naive date time should valid")
        let result = try naiveDateTime.dateTime(timezone: tzName, provider: mock)

        #expect(result.timezone.identifier == tzName)
    }

    @Test("IANANaiveDateTimeTests: throws error when TimeZone name is invalid")
    func conversionThrowsOnInvalidZone() throws {
        let mock = MockTimeZoneProvider()
        let naiveDateTime = try #require(sample, "Sample naive date time should valid")

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try naiveDateTime.instant(in: "Invalid/Zone", provider: mock)
        }

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try naiveDateTime.dateTime(timezone: "Invalid/Zone", provider: mock)
        }
    }
}

// MARK: - Helpers

extension IANANaiveDateTimeTests {
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
