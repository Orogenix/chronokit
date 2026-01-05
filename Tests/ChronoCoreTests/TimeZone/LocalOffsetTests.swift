@testable import ChronoCore
import Testing

@Suite("Local Offset Tests")
struct LocalOffsetTests {
    @Test("LocalOffsetTests: Resolution logic", arguments: [
        (
            LocalOffset.unique(.hours(1)),
            DSTResolutionPolicy.strict,
            Duration.hours(1),
        ),
        (
            LocalOffset.ambiguous(earlier: .hours(2), later: .hours(1)),
            DSTResolutionPolicy.preferEarlier,
            Duration.hours(2),
        ),
        (
            LocalOffset.ambiguous(earlier: .hours(2), later: .hours(1)),
            DSTResolutionPolicy.preferLater,
            Duration.hours(1),
        ),
        (
            LocalOffset.invalid,
            DSTResolutionPolicy.preferEarlier,
            nil,
        ),
    ])
    func localOffsetResolution(offset: LocalOffset, policy: DSTResolutionPolicy, expected: Duration?) {
        #expect(offset.resolve(using: policy) == expected)
    }

    @Test("LocalOffsetTests: Strict policy returns nil for ambiguity")
    func strictAmbiguity() {
        let offset = LocalOffset.ambiguous(earlier: .hours(1), later: .zero)
        #expect(offset.resolve(using: .strict) == nil)
    }
}
