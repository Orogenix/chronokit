@testable import ChronoCore
import Testing

struct LocalOffsetTests {
    @Test("LocalOffsetTests: Resolution logic", arguments: [
        (
            LocalOffset.unique(.standard(.hours(1))),
            DSTResolutionPolicy.strict,
            Duration.hours(1)
        ),
        (
            LocalOffset.ambiguous(earlier: .standard(.hours(2)), later: .standard(.hours(1))),
            DSTResolutionPolicy.preferEarlier,
            Duration.hours(2)
        ),
        (
            LocalOffset.ambiguous(earlier: .dst(.hours(2)), later: .dst(.hours(1))),
            DSTResolutionPolicy.preferLater,
            Duration.hours(1)
        ),
        (
            LocalOffset.invalid,
            DSTResolutionPolicy.preferEarlier,
            nil
        ),
    ])
    func localOffsetResolution(
        offset: LocalOffset,
        policy: DSTResolutionPolicy,
        expected: Duration?
    ) {
        #expect(offset.resolve(using: policy)?.duration == expected)
    }

    @Test("LocalOffsetTests: Strict policy returns nil for ambiguity")
    func strictAmbiguity() {
        let offset = LocalOffset.ambiguous(earlier: .standard(.hours(1)), later: .dst(.zero))
        #expect(offset.resolve(using: .strict) == nil)
    }
}
