import ChronoCore
import ChronoSystem
import Foundation

public protocol TimeZoneProvider {
    func getTimeZone(named: String) throws -> TimeZoneInfo
    func preloadTimeZone(names: [String]) throws
    func preloadAll() throws
    func clearCache()
}

public final class IANAProvider: @unchecked Sendable {
    private nonisolated(unsafe) static var _shared: IANAProvider?
    private static let _accessLock = Mutex()

    private let registry: TimeZoneRegistry
    private var cache: [String: TimeZoneInfo]
    private let lock: Mutex

    public init(path: String) throws {
        registry = try TimeZoneRegistry(path: path)
        cache = [:]
        lock = Mutex()
    }
}

public extension IANAProvider {
    static var shared: IANAProvider {
        _accessLock.withLock {
            if let existing = _shared { return existing }

            guard let path = Bundle.module.url(forResource: "iana", withExtension: "tzdb")?.path
            else {
                preconditionFailure("ChronoTZ: iana.tzdb not found.")
            }

            do {
                let provider = try IANAProvider(path: path)
                _shared = provider
                return provider
            } catch {
                preconditionFailure("ChronoTZ: Failed to load iana.tzdb at \(path): \(error)")
            }
        }
    }
}

extension IANAProvider: TimeZoneProvider {
    private func _load(named name: String) throws -> TimeZoneInfo {
        guard let entry = registry.getEntry(named: name) else {
            throw TimeZoneError.zoneNotFound(name)
        }

        let buffer = try registry.getPayload(for: entry)
        guard let payload = try? TZDBCodec.decode(from: buffer) else {
            throw CodecError.corruptionError("Failed to decode: \(name)")
        }

        return TimeZoneInfo(identifier: name, payload: payload)
    }

    public func getTimeZone(named name: String) throws -> TimeZoneInfo {
        try lock.withLock {
            if let cached = cache[name] {
                return cached
            }

            let info = try _load(named: name)

            cache[name] = info
            return info
        }
    }

    public func preloadTimeZone(names: [String]) throws {
        try lock.withLock {
            for name in names where cache[name] == nil {
                cache[name] = try _load(named: name)
            }
        }
    }

    public func preloadAll() throws {
        try lock.withLock {
            for name in registry.indexNames where cache[name] == nil {
                cache[name] = try _load(named: name)
            }
        }
    }

    public func clearCache() {
        lock.withLock { cache.removeAll() }
    }
}
