@testable import ChronoTZ

extension TZDataPayload {
    static func makePayload(
        transitions: [Transition] = [],
        types: [TypeDefinition] = [],
        posixRule: String? = nil
    ) throws -> Self {
        let typeDefinitions = types.isEmpty ? try [TypeDefinition(offset: 0, isDST: 0)] : types
        return TZDataPayload(
            transitionCount: UInt32(transitions.count),
            typeCount: UInt32(types.count),
            transitions: transitions,
            types: typeDefinitions,
            posixRule: posixRule
        )
    }
}
