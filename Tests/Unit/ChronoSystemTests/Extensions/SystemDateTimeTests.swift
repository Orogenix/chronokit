import ChronoCore
@testable import ChronoSystem
import Testing

struct SystemDateTimeTests {
    // MARK: - Initialization

    @Test("SystemDateTimeTests: Verifies that nowUTC always yields a zero offset")
    func nowUTC() {
        let utc = DateTime<FixedOffset>.nowUTC
        let offset = utc.timezone.offset(for: utc.instant)
        #expect(offset.seconds == 0)
        #expect(utc.timezone == .utc)
    }

    @Test("SystemDateTimeTests: Verifies generic now(in:) works with various timezone types")
    func genericNow() {
        // Test with FixedOffset
        let jakartaOffset = FixedOffset.hours(7)
        let dtFixed = DateTime.now(in: jakartaOffset)
        #expect(dtFixed.timezone == jakartaOffset)

        // Test with System
        let dtSystem = DateTime.now(in: SystemTimeZone())
        #expect(!dtSystem.timezone.identifier.isEmpty)
    }

    @Test("SystemDateTimeTests: System vs Fixed")
    func typeSafety() {
        let systemDT = DateTime<SystemTimeZone>.now()
        let fixedDT = DateTime<FixedOffset>.nowUTC

        // Verifying type identities
        #expect(type(of: systemDT.timezone) == SystemTimeZone.self)
        #expect(type(of: fixedDT.timezone) == FixedOffset.self)
    }

    @Test("SystemDateTimeTests: Precision consistency")
    func highPrecisionConsistency() {
        let instant1 = Instant.now()
        let dt = DateTime<SystemTimeZone>.now()
        let instant2 = Instant.now()

        // The datetime's instant must be bounded by the two snapshots
        #expect(dt.instant >= instant1)
        #expect(dt.instant <= instant2)
    }

    @Test("SystemDateTimeTests: Gap Initialization Clock")
    func highPrecisionGap() {
        let now = DateTime<SystemTimeZone>.now()
        let manualNow = DateTime.now(in: SystemTimeZone())

        // Ensure they captured roughly the same time
        let diff = abs(now.instant.seconds - manualNow.instant.seconds)
        #expect(diff < 1)

        let fixed = DateTime<FixedOffset>.now(in: .hours(7))
        #expect(fixed.timezone.offset(for: fixed.instant) == .hours(7))
    }

    @Test("SystemDateTimeTests: System to Fixed Snapshot")
    func fixedOffsetSnapshot() {
        let systemTime = DateTime<SystemTimeZone>.now()

        // Capture a snapshot
        let fixedSnapshot = systemTime.fixedOffset()

        // The Instant must remain identical
        #expect(systemTime.instant == fixedSnapshot.instant)

        // The type must be FixedOffset
        #expect(type(of: fixedSnapshot.timezone) == FixedOffset.self)

        // The value must match the system's offset at that moment
        let currentSystemOffset = systemTime.timezone.offset(for: systemTime.instant)
        let fixedSnapshotOffset = fixedSnapshot.timezone.offset(for: fixedSnapshot.instant)
        #expect(fixedSnapshotOffset == currentSystemOffset)
    }

    @Test("SystemDateTimeTests: Timezone Identifier consistency")
    func identifierConsistency() {
        let sys = SystemTimeZone()
        let dt = DateTime<SystemTimeZone>.now()

        #expect(dt.timezone.identifier == sys.identifier)
        #expect(!dt.timezone.identifier.isEmpty)
    }

    @Test("SystemDateTimeTests: Parameterized Fixed Offsets", arguments: [
        0, 3600, -3600, 18000, -18000
    ])
    func parameterizedOffsets(seconds: Int) {
        let offset = FixedOffset(.seconds(Int64(seconds)))
        let dt: DateTime = .now(in: offset)
        #expect(dt.timezone.offset(for: dt.instant) == .seconds(seconds))
    }

    @Test("SystemDateTimeTests: Extreme Offsets", arguments: [
        14 * 3600, // Max East
        -12 * 3600 // Max West
    ])
    func extremeOffsets(seconds: Int) {
        let offset = FixedOffset(.seconds(Int64(seconds)))
        let dt = DateTime<FixedOffset>.now(in: offset)
        #expect(dt.timezone.offset(for: dt.instant) == .seconds(seconds))
    }

    @Test("SystemDateTimeTests: FixedOffset immutability")
    func fixedOffsetImmutability() {
        let systemDT = DateTime<SystemTimeZone>.now()
        let fixedSnapshot = systemDT.fixedOffset()

        // Even if we query it later, it should return the same offset
        let initialOffset = fixedSnapshot.timezone.offset(for: fixedSnapshot.instant)

        // Simulate passage of time
        let laterInstant = fixedSnapshot.instant.advanced(bySeconds: 3600)
        let laterOffset = fixedSnapshot.timezone.offset(for: laterInstant)

        #expect(initialOffset == laterOffset, "FixedOffset should be static and not change over time")
    }
}
