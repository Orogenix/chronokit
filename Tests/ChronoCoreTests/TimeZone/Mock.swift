@testable import ChronoCore

struct MockTimeZone: TimeZoneProtocol {
    let offset: Int
    let identifier: String = "MockTZ"

    func offset(for _: Instant) -> Duration {
        .seconds(offset)
    }

    func offset(for _: NaiveDateTime) -> LocalOffset {
        .unique(.seconds(offset))
    }
}

struct MockInvalidTimeZone: TimeZoneProtocol {
    let identifier: String = "MockInvalidTZ"

    func offset(for _: Instant) -> Duration {
        .nanoseconds(-1)
    }

    func offset(for _: NaiveDateTime) -> LocalOffset {
        .invalid // Represents a time that doesn't exist (DST Gap)
    }
}

struct MockGapTimeZone: TimeZoneProtocol {
    let identifier: String = "MockGapTZ"

    func offset(for _: Instant) -> Duration {
        .zero
    }

    func offset(for _: NaiveDateTime) -> LocalOffset {
        .invalid
    }
}

struct MockAmbiguousTimeZone: TimeZoneProtocol {
    let identifier: String = "MockAmbiguousTZ"
    let earlierOffset: Int
    let laterOffset: Int

    init(
        earlierOffset: Int,
        laterOffset: Int,
    ) {
        self.earlierOffset = earlierOffset
        self.laterOffset = laterOffset
    }

    func offset(for _: Instant) -> Duration {
        .seconds(earlierOffset)
    }

    func offset(for _: NaiveDateTime) -> LocalOffset {
        .ambiguous(
            earlier: .seconds(earlierOffset),
            later: .seconds(laterOffset),
        )
    }
}
