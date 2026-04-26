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
        let symbol = unsafeBitCast(FileSystem.self, to: UnsafeRawPointer.self)
        guard dladdr(symbol, &info) != 0 else { return nil }

        guard let path = info.dli_fname else { return nil }
        let libPath = String(cString: path)
        let libDir = String(libPath.split(separator: "/").dropLast().joined(separator: "/"))

        if let dir = opendir(libDir) {
            defer { closedir(dir) }

            while let entry = readdir(dir) {
                let namePtr = entry.pointee.d_name
                let fileName = withUnsafePointer(to: namePtr) {
                    $0.withMemoryRebound(to: CChar.self, capacity: Int(MemoryLayout.size(ofValue: namePtr))) {
                        String(cString: $0)
                    }
                }

                if fileName.hasSuffix(".bundle") {
                    let candidate = "\(libDir)/\(fileName)/Resources/\(name)"
                    if access(candidate, F_OK) == 0 {
                        return candidate
                    }

                    let altCandidate = "\(libDir)/\(fileName)/\(name)"
                    if access(altCandidate, F_OK) == 0 {
                        return altCandidate
                    }
                }
            }
        }

        // let bundleName = "ChronoTZ_ChronoTZ.bundle"
        //
        // let candidates = [
        //     "\(libDir)/\(bundleName)/Resources/\(name)",
        //     "\(libDir)/\(bundleName)/\(name)",
        //     "\(libDir)/../Resources/\(name)",
        //     "\(libDir)/../../Resources/\(name)",
        // ]
        //
        // for path in candidates where access(path, F_OK) == 0 {
        //     return path
        // }

        return nil
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
