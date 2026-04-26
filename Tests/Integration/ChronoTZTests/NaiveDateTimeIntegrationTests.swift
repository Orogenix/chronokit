import ChronoCore
import ChronoMath
import ChronoTZ
import Testing

struct PlainDateTimeTZIntegrationTests {
    @Test("PlainDateTimeTZIntegrationTests: instant(in:resolving:) converts to valid Instant")
    func convertToInstant() throws {
        let plain = try #require(PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 12, minute: 0, second: 0
        ))
        let zone = "UTC"

        let instant = try plain.instant(in: zone)

        #expect(instant.seconds > 0, "Verify the conversion happened without error")
    }

    @Test("PlainDateTimeTZIntegrationTests: DST Transition - Ambiguity Resolution")
    func dstAmbiguityResolution() throws {
        // Example: Europe/London transition (Autumn fall-back)
        // At 01:00 UTC+1, clocks go back to 00:00 UTC+0.
        // 01:30 happens twice.
        // We verify that the policy (preferEarlier/preferLater) changes the resulting instant.
        let plain = try #require(PlainDateTime(
            year: 2025, month: 10, day: 26,
            hour: 1, minute: 30, second: 0
        ))
        let zone = "Europe/London"

        let instantEarlier = try plain.instant(in: zone, resolving: .preferEarlier)
        let instantLater = try plain.instant(in: zone, resolving: .preferLater)

        // The two instants should be exactly 1 hour apart
        #expect(instantLater.seconds - instantEarlier.seconds == 3600)
    }

    @Test("PlainDateTimeTZIntegrationTests: dateTime(timezone:) bridges to DateTime type")
    func convertToDateTime() throws {
        let plain = try #require(PlainDateTime(
            year: 2025, month: 5, day: 20,
            hour: 10, minute: 30, second: 0
        ))
        let zone = "Asia/Jakarta"

        let dt = try plain.dateTime(timezone: zone)

        #expect(dt.timezone.identifier == "Asia/Jakarta")
        #expect(dt.plain.year == 2025)
    }

    @Test("PlainDateTimeTZIntegrationTests: Throws error for non-existent zone")
    func throwsForUnknownZone() throws {
        let plain = try #require(PlainDateTime(
            year: 2025, month: 1, day: 1,
            hour: 0, minute: 0, second: 0
        ))

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            _ = try plain.instant(in: "Invalid/Zone")
        }
    }
}
