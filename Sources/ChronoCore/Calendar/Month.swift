public enum Month: Int, CaseIterable, Equatable, Hashable, Sendable {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
}

extension Month: Comparable {
    public static func < (lhs: Month, rhs: Month) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Month {
    @inlinable
    func next() -> Month {
        switch self {
        case .january: .february
        case .february: .march
        case .march: .april
        case .april: .may
        case .may: .june
        case .june: .july
        case .july: .august
        case .august: .september
        case .september: .october
        case .october: .november
        case .november: .december
        case .december: .january
        }
    }

    @inlinable
    func prev() -> Month {
        switch self {
        case .january: .december
        case .february: .january
        case .march: .february
        case .april: .march
        case .may: .april
        case .june: .may
        case .july: .june
        case .august: .july
        case .september: .august
        case .october: .september
        case .november: .october
        case .december: .november
        }
    }
}
