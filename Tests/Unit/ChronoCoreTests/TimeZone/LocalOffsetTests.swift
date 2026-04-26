@testable import ChronoCore
import Testing

struct PlainOffsetTests {
    @Test("PlainOffsetTests: Resolution logic", arguments: [
        (
            PlainOffset.unique(.standard(.hours(1))),
            DSTResolutionPolicy.strict,
            Duration.hours(1)
        ),
        (
            PlainOffset.ambiguous(earlier: .standard(.hours(2)), later: .standard(.hours(1))),
            DSTResolutionPolicy.preferEarlier,
            Duration.hours(2)
        ),
        (
            PlainOffset.ambiguous(earlier: .dst(.hours(2)), later: .dst(.hours(1))),
            DSTResolutionPolicy.preferLater,
            Duration.hours(1)
        ),
        (
            PlainOffset.invalid,
            DSTResolutionPolicy.preferEarlier,
            nil
        ),
    ])
    func plainOffsetResolution(
        offset: PlainOffset,
        policy: DSTResolutionPolicy,
        expected: Duration?
    ) {
        #expect(offset.resolve(using: policy)?.duration == expected)
    }

    @Test("PlainOffsetTests: Strict policy returns nil for ambiguity")
    func strictAmbiguity() {
        let offset = PlainOffset.ambiguous(earlier: .standard(.hours(1)), later: .dst(.zero))
        #expect(offset.resolve(using: .strict) == nil)
    }
}
