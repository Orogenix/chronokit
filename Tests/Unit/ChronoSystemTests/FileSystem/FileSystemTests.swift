@testable import ChronoSystem
import Foundation
import Testing

// MARK: - File Operations Tests

struct FileSystemTests {
    @Test("FileSystemTests: Lifecycle. Open, Write, Read, Close")
    func fileLifecycle() throws {
        let path = createTempPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(fd) }

        let content = "Hello World"
        try content.withCString { buffer in
            try FileSystem.writeFile(fd, buffer: buffer, count: content.count)
        }

        FileSystem.closeFile(fd)

        let fdRead = try FileSystem.openFile(path, mode: .read)
        defer { FileSystem.closeFile(fdRead) }

        var buffer = [UInt8](repeating: 0, count: content.count)
        try buffer.withUnsafeMutableBytes { ptr in
            let buffer = try #require(ptr.baseAddress)
            let bytesRead = try FileSystem.readFile(
                fdRead,
                buffer: buffer,
                count: content.count
            )
            #expect(bytesRead == content.count)
        }
    }

    @Test("FileSystemTests: fsync durability")
    func fsync() throws {
        let path = createTempPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(fd) }

        let content = "Critical Data"
        try content.withCString { ptr in
            try FileSystem.writeFile(fd, buffer: ptr, count: content.count)
        }

        // Verify fsync works (this should not throw)
        try FileSystem.fsyncFile(fd)
    }

    @Test("FileSystemTests: Atomic Rename")
    func rename() throws {
        let sourcePath = createTempPath()
        let destPath = createTempPath()

        // Ensure cleanup of potential left-overs
        defer {
            try? FileManager.default.removeItem(atPath: sourcePath)
            try? FileManager.default.removeItem(atPath: destPath)
        }

        // 1. Create file A
        let fd = try FileSystem.openFile(sourcePath, mode: .writeCreateTruncate)
        FileSystem.closeFile(fd)

        // 2. Rename A to B
        try FileSystem.renameFile(from: sourcePath, to: destPath)

        // 3. Verify A is gone and B exists
        let sourceExists = FileManager.default.fileExists(atPath: sourcePath)
        let destExists = FileManager.default.fileExists(atPath: destPath)

        #expect(!sourceExists, "Source file should no longer exist after rename")
        #expect(destExists, "Destination file should exist after rename")
    }

    @Test("FileSystemTests: Non-existent file")
    func testFileNotFound() {
        let badPath = "/tmp/this_file_does_not_exist_\(UUID().uuidString)"

        #expect(throws: FileSystemError.fileNotFound(errno)) {
            try FileSystem.getFileSize(path: badPath)
        }
    }
}

// MARK: - Metadata Tests

extension FileSystemTests {
    @Test("FileSystemTests: Get File Size (Path and FD)")
    func fileSize() throws {
        let path = createTempPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Create a dummy file with 5 bytes
        let content = "12345"
        let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
        defer { FileSystem.closeFile(fd) }

        try content.withCString { ptr in
            try FileSystem.writeFile(fd, buffer: ptr, count: content.count)
        }

        // Test Path-based stat
        let sizeByPath = try FileSystem.getFileSize(path: path)
        #expect(sizeByPath == 5)

        // Test FD-based fstat
        let sizeByFd = try FileSystem.getFileSize(fd)
        #expect(sizeByFd == 5)
    }
}

// MARK: - Directory Operations Tests

extension FileSystemTests {
    @Test("FileSystemTests: List Directory")
    func listDirectory() throws {
        let dirPath = try createTempDir()
        defer { try? FileManager.default.removeItem(atPath: dirPath) }

        // Create dummy file inside
        let filePath = "\(dirPath)/testfile.txt"
        try "data".write(toFile: filePath, atomically: true, encoding: .utf8)

        var found = false
        try FileSystem.listDirectory(at: dirPath) { name, isDir in
            if name == "testfile.txt" {
                found = true
                #expect(!isDir)
            }
        }

        #expect(found, "Should have found the file created in the directory")
    }
}

// MARK: - Memory Mapping Tests

extension FileSystemTests {
    @Test("FileSystemTests: MMap and Read")
    func testMapFile() throws {
        let path = createTempPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let content = "MMap_Test_Data"
        let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
        try content.withCString { ptr in
            try FileSystem.writeFile(fd, buffer: ptr, count: content.count)
        }
        FileSystem.closeFile(fd)

        // Re-open for reading
        let fdRead = try FileSystem.openFile(path, mode: .read)
        defer { FileSystem.closeFile(fdRead) }

        let ptr = try FileSystem.mapFile(fd: fdRead, size: content.count)
        defer { FileSystem.unmapFile(pointer: ptr, size: content.count) }

        // Verify content in memory
        let bound = ptr.bindMemory(to: CChar.self, capacity: content.count)
        let string = String(cString: bound) // Note: ensure null-termination or use buffer
        #expect(string.hasPrefix("MMap_Test_Data"))
    }

    @Test("FileSystemTests: Invalid MMap")
    func mmapFailure() {
        // Attempting to mmap -1 fd
        // 9 is EBADF (Bad File Descriptor)
        #expect(throws: FileSystemError.mmapFailed(errno)) {
            try FileSystem.mapFile(fd: -1, size: 4096)
        }
    }
}

// MARK: - Helpers

extension FileSystemTests {
    private func createTempPath() -> String {
        let name = "test_\(UUID().uuidString)"
        return FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(name)
            .path
    }

    private func createTempDir() throws -> String {
        let dirPath = FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent("test_dir_\(UUID().uuidString)")
            .path
        try FileManager
            .default
            .createDirectory(atPath: dirPath, withIntermediateDirectories: true)
        return dirPath
    }
}
