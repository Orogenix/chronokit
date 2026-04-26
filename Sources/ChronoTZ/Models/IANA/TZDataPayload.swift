package struct TZDataPayload: Equatable, Hashable {
    package let transitionCount: UInt32
    package let typeCount: UInt32
    package let transitions: [Transition]
    package let types: [TypeDefinition]
    package let posixRule: String?
    package let compiledPosixRule: POSIXRule?

    package init(
        transitionCount: UInt32,
        typeCount: UInt32,
        transitions: [Transition],
        types: [TypeDefinition],
        posixRule: String? = nil
    ) {
        self.transitionCount = transitionCount
        self.typeCount = typeCount
        self.transitions = transitions
        self.types = types
        self.posixRule = posixRule

        if let posixRule {
            compiledPosixRule = POSIXRule(rawValue: posixRule)
        } else {
            compiledPosixRule = nil
        }
    }
}

extension TZDataPayload {
    func resolve(at timestamp: Int64) -> ResolvedOffset {
        // Resolve from transitions
        if let lastTransition = transitions.last,
           timestamp <= lastTransition.unixTime,
           let index = findTransitionIndex(for: timestamp)
        {
            let typeIndex = transitions[index].typeIndex
            return .unique(types[Int(typeIndex)])
        }

        // Resolve from POSIX rule
        if let rule = compiledPosixRule {
            let state = POSIXRuleResolver.resolveState(at: timestamp, rule: rule)

            let std = TypeDefinition(offset: rule.stdOffset, isDST: 0)
            let dst = TypeDefinition(offset: rule.dstOffset, isDST: 1)

            switch state {
            case .ambiguous:
                return .ambiguous(earlier: dst, later: std)

            case .gap:
                return .gap

            case .standard:
                return .unique(std)

            case .dst:
                return .unique(dst)
            }
        }

        if let lastIndex = transitions.last?.typeIndex {
            return .unique(types[Int(lastIndex)])
        }

        if let firstType = types.first {
            return .unique(firstType)
        }

        return .invalid
    }

    func findTransitionIndex(for timestamp: Int64) -> Int? {
        var low = 0
        var high = transitions.count - 1
        var candidateIndex: Int?

        while low <= high {
            let mid = (low + high) / 2

            if transitions[mid].unixTime <= timestamp {
                candidateIndex = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return candidateIndex
    }
}

package struct Transition: Equatable, Hashable {
    package let unixTime: Int64
    package let typeIndex: UInt8

    package init(
        unixTime: Int64,
        typeIndex: UInt8
    ) {
        self.unixTime = unixTime
        self.typeIndex = typeIndex
    }
}

extension Transition {
    static let size: Int = 8 + 1
}

package struct TypeDefinition: Equatable, Hashable {
    package let offset: Int32 // Second from UTC
    package let isDST: UInt8 // Standard = 0; DST = 1

    package init(
        offset: Int32,
        isDST: UInt8
    ) {
        self.offset = offset
        self.isDST = isDST
    }
}

extension TypeDefinition {
    static let size: Int = 4 + 1
}

package enum ResolvedOffset {
    case unique(TypeDefinition)
    case ambiguous(earlier: TypeDefinition, later: TypeDefinition)
    case gap
    case invalid
}
