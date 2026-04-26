@testable import ChronoCore

struct MockTimeZone: TimeZoneProtocol {
    let offset: Int
    let identifier: String = "MockTZ"

    func offset(for _: Instant) -> Duration {
        .seconds(offset)
    }

    func offset(for _: PlainDateTime) -> PlainOffset {
        .unique(.standard(.seconds(offset)))
    }
}

struct MockInvalidTimeZone: TimeZoneProtocol {
    let identifier: String = "MockInvalidTZ"

    func offset(for _: Instant) -> Duration {
        .nanoseconds(-1)
    }

    func offset(for _: PlainDateTime) -> PlainOffset {
        .invalid // Represents a time that doesn't exist (DST Gap)
    }
}

struct MockGapTimeZone: TimeZoneProtocol {
    let identifier: String = "MockGapTZ"

    func offset(for _: Instant) -> Duration {
        .zero
    }

    func offset(for _: PlainDateTime) -> PlainOffset {
        .invalid
    }
}

struct MockAmbiguousTimeZone: TimeZoneProtocol {
    let identifier: String = "MockAmbiguousTZ"
    let earlierOffset: Int
    let laterOffset: Int

    func offset(for _: Instant) -> Duration {
        .seconds(earlierOffset)
    }

    func offset(for _: PlainDateTime) -> PlainOffset {
        .ambiguous(
            earlier: .dst(.seconds(earlierOffset)),
            later: .dst(.seconds(laterOffset))
        )
    }
}
