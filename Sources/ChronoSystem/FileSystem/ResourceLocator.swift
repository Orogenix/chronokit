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
        let bundleName = "ChronoTZ_ChronoTZ.bundle"
        let candidate = "/\(baseDir)/\(bundleName)/\(name)"

        print("✅ Found \(name) at: \(candidate)")
        return access(candidate, F_OK) == 0 ? candidate : nil

        // var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        // guard getcwd(&buffer, buffer.count) != nil else { return nil }
        // let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        // let root = String(decoding: bytes, as: UTF8.self)
        // return search(in: root, for: name)
    }

    private static func search(in directory: String, for fileName: String) -> String? {
        guard let dir = opendir(directory) else { return nil }
        defer { closedir(dir) }

        while let entry = readdir(dir) {
            let namePtr = entry.pointee.d_name
            let entryName = withUnsafePointer(to: namePtr) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MemoryLayout.size(ofValue: namePtr))
                ) {
                    String(cString: $0)
                }
            }

            if entryName == "." || entryName == ".." { continue }

            let fullPath = "\(directory)/\(entryName)"

            // Check if it's the file we want
            if entryName == fileName {
                var st = stat()
                if stat(fullPath, &st) == 0, st.st_mode & S_IFMT == S_IFREG {
                    return fullPath
                }
            }

            // If it's a directory, recurse (don't go into hidden folders to save time)
            var st = stat()
            if stat(fullPath, &st) == 0, st.st_mode & S_IFMT == S_IFDIR {
                // OPTIONAL: Skip .git to make it faster
                if entryName == ".git" { continue }

                if let found = search(in: fullPath, for: fileName) {
                    return found
                }
            }
        }

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
