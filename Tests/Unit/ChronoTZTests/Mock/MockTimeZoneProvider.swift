@testable import ChronoTZ

final class MockTimeZoneProvider: TimeZoneProvider {
    private var mockZones: [String: TimeZoneInfo] = [:]

    func insertZones(_ name: String, tz: TimeZoneInfo) {
        mockZones[name] = tz
    }

    func getTimeZone(named name: String) throws -> TimeZoneInfo {
        if let zone = mockZones[name] {
            return zone
        }
        throw TimeZoneError.zoneNotFound(name)
    }

    func preloadTimeZone(names _: [String]) throws {}

    func preloadAll() throws {}

    func clearCache() {
        mockZones.removeAll()
    }
}
