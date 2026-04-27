@testable import ChronoTZ

extension TZDBDataPayload {
    static func makePayload(
        transitions: [TZDBTransition] = [],
        types: [TZDBTypeDefinition] = [],
        posixRule: String? = nil
    ) throws -> Self {
        let typeDefinitions = types.isEmpty ? try [TZDBTypeDefinition(offset: 0, isDST: 0)] : types
        return TZDBDataPayload(
            transitionCount: UInt32(transitions.count),
            typeCount: UInt32(types.count),
            transitions: transitions,
            types: typeDefinitions,
            posixRule: posixRule
        )
    }
}
