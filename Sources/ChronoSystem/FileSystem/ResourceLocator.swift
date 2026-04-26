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
        // var info = Dl_info()
        // let symbol = unsafeBitCast(FileSystem.self, to: UnsafeRawPointer.self)
        // guard dladdr(symbol, &info) != 0 else { return nil }
        //
        // guard let path = info.dli_fname else { return nil }
        // let libPath = String(cString: path)
        // let libDir = String(libPath.split(separator: "/").dropLast().joined(separator: "/"))

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

        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard getcwd(&buffer, buffer.count) != nil else { return nil }
        let root = String(cString: buffer)
        return search(in: root, for: name)
    }

    private static func search(in directory: String, for fileName: String) -> String? {
        guard let dir = opendir(directory) else { return nil }
        defer { closedir(dir) }

        while let entry = readdir(dir) {
            let namePtr = entry.pointee.d_name
            let entryName = withUnsafePointer(to: namePtr) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MemoryLayout.size(ofValue: namePtr))) {
                    String(cString: $0)
                }
            }

            // Skip self and parent
            if entryName == "." || entryName == ".." { continue }

            let fullPath = "\(directory)/\(entryName)"

            // Check if it's the file we want
            if entryName == fileName {
                // Verify it's a file
                var st = stat()
                if stat(fullPath, &st) == 0, st.st_mode & S_IFMT == S_IFREG {
                    return fullPath
                }
            }

            // If it's a directory, recurse (don't go into hidden folders to save time)
            if entryName.first != "." {
                var st = stat()
                if stat(fullPath, &st) == 0, st.st_mode & S_IFMT == S_IFDIR {
                    if let found = search(in: fullPath, for: fileName) {
                        return found
                    }
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
