package final class MappedFile {
    package private(set) var pointer: UnsafeRawPointer?
    package private(set) var size: Int
    package private(set) var fd: Int32

    package init(path: String) throws {
        let fd = try FileSystem.openFile(path, mode: .read)
        self.fd = fd

        size = try FileSystem.getFileSize(fd)

        do {
            pointer = try FileSystem.mapFile(fd: fd, size: size)
        } catch {
            FileSystem.closeFile(fd)
            throw error
        }
    }

    package func getPointer() throws -> UnsafeRawPointer {
        guard let pointer else {
            throw FileSystemError.mappedFileClosed
        }
        return pointer
    }

    package func buffer(at offset: Int, size: Int) throws -> UnsafeRawBufferPointer {
        let ptr = try getPointer().advanced(by: offset)

        guard offset + size <= self.size else {
            throw FileSystemError.outOfBounds
        }

        return UnsafeRawBufferPointer(start: ptr, count: size)
    }

    package func close() {
        guard fd != -1 else { return }

        if let ptr = pointer {
            FileSystem.unmapFile(pointer: ptr, size: size)
            pointer = nil
        }

        FileSystem.closeFile(fd)
        fd = -1
    }

    deinit {
        close()
    }
}
