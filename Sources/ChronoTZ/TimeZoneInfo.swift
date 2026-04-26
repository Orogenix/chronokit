import ChronoCore

public struct TimeZoneInfo: Equatable, Hashable, Sendable, TimeZoneProtocol {
    public let identifier: String
    let payload: TZDataPayload
    private let uniqueOffset: Set<Int32>

    package init(identifier: String, payload: TZDataPayload) {
        self.identifier = identifier
        self.payload = payload
        uniqueOffset = Set(payload.types.map(\.offset))
    }

    public func offset(for instant: Instant) -> Duration {
        let unixTime: Int64 = instant.timestamp

        let isPastLastTransition = payload
            .transitions
            .last
            .map { unixTime > $0.unixTime } ?? true

        if isPastLastTransition,
           let rule = payload.compiledPosixRule
        {
            return POSIXRuleResolver.offset(for: rule, at: instant)
        }

        if let index = payload.findTransitionIndex(for: unixTime) {
            let transition = payload.transitions[index]
            let typeIndex = Int(transition.typeIndex)

            if typeIndex < payload.types.count {
                let type = payload.types[typeIndex]
                return .seconds(type.offset)
            }
        }

        return .seconds(payload.types.first?.offset ?? 0)
    }

    public func offset(for local: NaiveDateTime) -> LocalOffset {
        if payload.types.count == 1 {
            let type = payload.types[0]
            return .unique(LocalOffsetMetadata(
                duration: .seconds(type.offset),
                isDST: type.isDST == 1
            ))
        }

        let localNanos = local.timestampNanosecondsChecked() ?? 0
        let localSecs = localNanos / NanoSeconds.perSecond64

        var candidateOffsets: Set<Int32> = uniqueOffset

        if let rule = payload.compiledPosixRule {
            candidateOffsets.insert(rule.stdOffset)
            candidateOffsets.insert(rule.dstOffset)
        }

        var candidates: Set<LocalOffsetMetadata> = []

        for offset in candidateOffsets {
            let candidateUTC = localSecs - Int64(offset)
            let resolved = payload.resolve(at: candidateUTC)

            switch resolved {
            case let .unique(type):
                if type.offset == offset {
                    let metadata = LocalOffsetMetadata(
                        duration: .seconds(offset),
                        isDST: type.isDST == 1
                    )
                    candidates.insert(metadata)
                }

            case let .ambiguous(earlier, later):
                if earlier.offset == offset {
                    let meta = LocalOffsetMetadata(
                        duration: .seconds(offset),
                        isDST: earlier.isDST == 1
                    )
                    candidates.insert(meta)
                }

                if later.offset == offset {
                    let meta = LocalOffsetMetadata(
                        duration: .seconds(offset),
                        isDST: later.isDST == 1
                    )
                    candidates.insert(meta)
                }

            case .gap, .invalid:
                continue
            }
        }

        switch candidates.count {
        case 0:
            return .invalid
        case 1:
            guard let candidate = candidates.first else { return .invalid }
            return .unique(candidate)
        default:
            let sorted = Array(candidates)
                .sorted { $0.duration < $1.duration }
                .sorted { $0.isDST && !$1.isDST }
            return .ambiguous(
                earlier: sorted[0],
                later: sorted[1]
            )
        }
    }
}
