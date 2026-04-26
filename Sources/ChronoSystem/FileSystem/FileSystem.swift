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

// MARK: - File Operations

package enum FileSystem {
    package static func openFile(_ path: String, mode: FileMode) throws -> Int32 {
        let fd = path.withCString { cPath in
            open(cPath, mode.flags, mode.mode)
        }
        guard fd != -1 else { throw FileSystemError.openFileFailed(errno) }
        return fd
    }

    package static func closeFile(_ fd: Int32) {
        _ = close(fd)
    }

    package static func fsyncFile(_ fd: Int32) throws {
        let result = fsync(fd)
        if result == -1 { throw FileSystemError.syncFailed(errno) }
    }

    package static func renameFile(from: String, to: String) throws {
        let result = from.withCString { cFrom in
            to.withCString { cTo in
                rename(cFrom, cTo)
            }
        }
        if result == -1 { throw FileSystemError.renameFailed(errno) }
    }

    package static func readFile(_ fd: Int32, buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
        let result = read(fd, buffer, count)
        guard result != -1 else { throw FileSystemError.readFileFailed(errno) }
        return result
    }

    package static func writeFile(_ fd: Int32, buffer: UnsafeRawPointer?, count: Int) throws {
        let result = write(fd, buffer, count)
        guard result != -1 else { throw FileSystemError.writeFileFailed(errno) }
    }
}

// MARK: - Metadata

package extension FileSystem {
    static func getFileSize(path: String) throws -> Int {
        var st = stat()

        let result = path.withCString { cPath in
            stat(cPath, &st)
        }

        guard result == 0 else { throw FileSystemError.fileNotFound(errno) }

        return Int(st.st_size)
    }

    static func getFileSize(_ fd: Int32) throws -> Int {
        var st = stat()
        guard fstat(fd, &st) == 0 else { throw FileSystemError.fileNotFound(errno) }
        return Int(st.st_size)
    }
}

// MARK: - Directory Operations

extension FileSystem {
    private static func openDirectory(_ path: String) throws -> UnsafeMutablePointer<DIR> {
        let dir = path.withCString { cPath in
            opendir(cPath)
        }
        guard let dir else { throw FileSystemError.openDirectoryFailed(path: path, code: errno) }
        return dir
    }

    package static func listDirectory(at path: String, body: (String, Bool) throws -> Void) throws {
        let dir = try openDirectory(path)
        defer { closedir(dir) }

        while let ptr = readdir(dir) {
            let name = String(ptr: ptr)

            if name == "." || name == ".." { continue }

            let isDir = ptr.pointee.d_type == UInt8(DT_DIR)
            try body(name, isDir)
        }
    }
}

// MARK: - Memory Mapping

package extension FileSystem {
    static func mapFile(fd: Int32, size: Int) throws -> UnsafeRawPointer {
        let addr = mmap(nil, size, PROT_READ, MAP_PRIVATE, fd, 0)

        guard let ptr = addr,
              ptr != MAP_FAILED
        else {
            throw FileSystemError.mmapFailed(errno)
        }

        return UnsafeRawPointer(ptr)
    }

    static func unmapFile(pointer: UnsafeRawPointer, size: Int) {
        munmap(UnsafeMutableRawPointer(mutating: pointer), size)
    }
}

// MARK: - Helpers

extension String {
    init(ptr: UnsafeMutablePointer<dirent>) {
        let namePtr = withUnsafePointer(to: &ptr.pointee.d_name) {
            $0.withMemoryRebound(
                to: CChar.self,
                capacity: Int(MemoryLayout.size(ofValue: ptr.pointee.d_name))
            ) {
                $0
            }
        }
        self.init(cString: namePtr)
    }
}
