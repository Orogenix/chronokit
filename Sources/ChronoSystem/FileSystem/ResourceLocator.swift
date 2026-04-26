#if canImport(Darwin)
    import Darwin
    import MachO
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

package enum ResourceLocator {
    package static func find(named name: String) -> String? {
        var info = Dl_info()
        let symbol = unsafeBitCast(ResourceLocator.self, to: UnsafeRawPointer.self)
        dladdr(symbol, &info)

        let path = String(cString: info.dli_fname)
        let baseDir = String(path.split(separator: "/").dropLast().joined(separator: "/"))
        let bundleName = "chronokit_ChronoTZ.bundle"
        let candidate = "/\(baseDir)/\(bundleName)/\(name)"

        print("✅ Found \(name) at: \(candidate)")
        return access(candidate, F_OK) == 0 ? candidate : nil
    }

    /// Development/Testing: Fallback to the CWD (Project Root).
    package static func findInProject(named name: String) -> String? {
        #if DEBUG
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
            guard getcwd(&buffer, buffer.count) != nil else { return nil }

            let bytes = buffer.prefix { $0 != 0 }.map { UInt8($0) }
            let root = String(decoding: bytes, as: UTF8.self)
            let candidate = "\(root)/Sources/ChronoTZ/Resources/\(name)"

            return access(candidate, F_OK) == 0 ? candidate : nil
        #else
            return nil
        #endif
    }
}
