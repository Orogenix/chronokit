package protocol Emitter {
    func emit(ctx: Packer.Context, to path: String) throws
}

package enum EmitterType: String {
    case bin
    case c
    case swift
}

package extension EmitterType {
    var emitter: any Emitter {
        switch self {
        case .bin:
            return BinaryEmitter()
        case .c:
            return CEmitter()
        case .swift:
            return SwiftEmitter()
        }
    }
}
