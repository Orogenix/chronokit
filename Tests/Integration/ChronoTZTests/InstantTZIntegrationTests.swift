import ChronoCore
import ChronoMath
import ChronoSystem
import ChronoTZ
import Testing

struct InstantTZIntegrationTests {
    @Test("InstantTZIntegrationTests: naiveDateTime(in:) works with valid zone")
    func naiveDateTimeConversion() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)

        let zone = "UTC"

        let naive = try instant.naiveDateTime(in: zone)

        // Ensure conversion didn't return an empty/error state
        // You might add specific property checks here depending on NaiveDateTime's API
        #expect(naive.year == 2023)
        #expect(naive.month == 11)
        #expect(naive.day == 14)
        #expect(naive.hour == 22)
        #expect(naive.minute == 13)
        #expect(naive.second == 20)
    }

    @Test("InstantTZIntegrationTests: dateTime(in:) assigns correct timezone")
    func dateTimeConversion() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)
        let zone = "Asia/Jakarta"

        let dt = try instant.dateTime(in: zone)

        #expect(dt.timezone.identifier == "Asia/Jakarta")
        #expect(dt.instant == instant)
    }

    @Test("InstantTZIntegrationTests: Injection of custom provider works")
    func customProviderInjection() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)

        #expect(throws: FileSystemError.openFileFailed(2)) {
            let provider = try IANAProvider(path: "/some/path/to/mock/db")
            _ = try instant.dateTime(in: "UTC", provider: provider)
        }
    }

    @Test("InstantTZIntegrationTests: Throws error for invalid zone name")
    func initThrowsForUnknownZone() throws {
        let instant = Instant(seconds: 0, nanoseconds: 0)

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            _ = try instant.dateTime(in: "Invalid/Zone")
        }
    }
}
