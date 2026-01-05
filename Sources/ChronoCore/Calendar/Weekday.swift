public enum Weekday: Int, CaseIterable, Equatable, Hashable, Sendable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
}

extension Weekday: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Weekday {
    @inlinable
    func next() -> Self {
        switch self {
        case .monday: .tuesday
        case .tuesday: .wednesday
        case .wednesday: .thursday
        case .thursday: .friday
        case .friday: .saturday
        case .saturday: .sunday
        case .sunday: .monday
        }
    }

    @inlinable
    func prev() -> Self {
        switch self {
        case .monday: .sunday
        case .tuesday: .monday
        case .wednesday: .tuesday
        case .thursday: .wednesday
        case .friday: .thursday
        case .saturday: .friday
        case .sunday: .saturday
        }
    }
}

public extension Weekday {
    @inlinable
    var numberFromMonday: Int {
        daysUntil(.monday) + 1
    }

    @inlinable
    var numberFromSunday: Int {
        daysUntil(.sunday) + 1
    }

    @inlinable
    var numDayFromMonday: Int {
        daysUntil(.monday)
    }

    @inlinable
    var numDayFromSunday: Int {
        daysUntil(.sunday)
    }

    @inlinable
    func daysUntil(_ other: Self) -> Int {
        let lhs = rawValue
        let rhs = other.rawValue

        let diff = rhs - lhs
        return diff < 0 ? diff + 7 : diff
    }
}
