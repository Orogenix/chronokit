import ChronoCore
import ChronoTZ
import Testing

struct DateTimeTZIntegrationTests {
    @Test("DateTimeTZIntegrationTests: Initializes with Instant and valid Zone")
    func initFromInstantAndZone() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)
        let zoneName = "UTC" // Assuming "UTC" is in your shared DB

        let dt = try DateTime(instant: instant, timezone: zoneName)

        #expect(dt.timezone.identifier == "UTC")
        #expect(dt.instant == instant)
    }

    @Test("DateTimeTZIntegrationTests: Throws error for invalid zone name")
    func initThrowsForUnknownZone() throws {
        let instant = Instant(seconds: 0, nanoseconds: 0)

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try DateTime(instant: instant, timezone: "Invalid/Zone")
        }
    }

    @Test("DateTimeTZIntegrationTests: now(in:) creates valid object")
    func nowInZone() throws {
        let dt = try DateTime.now(in: "UTC")

        #expect(dt.timezone.identifier == "UTC", "Timezone should match")

        // We verify the instant is "recent" (within a 1-second margin of error)
        let now = Instant.now()
        let diff = abs(dt.instant.seconds - now.seconds)
        #expect(diff < 1, "Expected time to be roughly 'now', got difference of \(diff)s")
    }

    @Test("DateTimeTZIntegrationTests: now in WIB")
    func nowInJakarta() throws {
        let dt = try DateTime.now(in: "Asia/Jakarta")

        #expect(dt.timezone.identifier == "Asia/Jakarta", "Timezone should match")

        // We verify the instant is "recent" (within a 1-second margin of error)
        let now = Instant.now()
        let diff = abs(dt.instant.seconds - now.seconds)
        #expect(diff < 1, "Expected time to be roughly 'now', got difference of \(diff)s")
    }
}
