import ChronoCore
import ChronoSystem
@testable import ChronoTZ
import Testing

struct IANARegistryTests {
    static var allZoneNames: [String] {
        let testFilePath = #filePath.split(separator: "/").dropLast().joined(separator: "/")
        let tzdbPath = "/\(testFilePath)/../Resources/iana.tzdb"

        do {
            let registry = try TimeZoneRegistry(path: tzdbPath)
            return registry.indexNames
        } catch {
            print("DEBUG: Could not load tzdb: \(error)")
            return []
        }
    }

    @Test("IANARegistryTests: Registry integrity", arguments: allZoneNames)
    func allZones(zoneName: String) throws {
        let tz = try IANAProvider.shared.getTimeZone(named: zoneName)
        #expect(tz.identifier == zoneName)
        #expect(!tz.payload.types.isEmpty)

        let now = Instant.now()
        let offset = tz.offset(for: now)

        let maxReasonableOffset: Int64 = 14 * Seconds.perHour64

        #expect(
            abs(offset.seconds) <= maxReasonableOffset,
            "Offset for \(zoneName) is suspiciously large: \(offset.seconds)"
        )
    }

    @Test("IANARegistryTests: Registry completeness check")
    func registryCompleteness() {
        let zones = IANARegistryTests.allZoneNames

        print("DEBUG: Verified \(zones.count) time zones in registry.")

        // Ensure we haven't lost a significant chunk of the database
        // (590 is a safe lower bound for modern IANA releases)
        #expect(
            zones.count >= 590,
            "Registry count dropped significantly: found \(zones.count)"
        )
    }
}
