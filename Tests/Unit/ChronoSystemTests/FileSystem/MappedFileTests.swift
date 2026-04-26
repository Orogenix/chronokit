@testable import ChronoSystem
import Foundation
import Testing

struct MappedFileTests {
    @Test("MappedFileTests: Lifecycle - Mapping and Reading")
    func mappedFileLifecycle() throws {
        let path = createTempPath()
        let content = "HighPerformanceData"
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Verify successful init
        let mapped = try MappedFile(path: path)

        // Explicitly check size
        let expectedBytes = Array(content.utf8)
        #expect(mapped.size == expectedBytes.count)

        // Verify memory content matches
        // Binding directly to UInt8 is the most precise way to verify memory
        let ptr = try #require(mapped.pointer)
        let buffer = ptr.bindMemory(to: UInt8.self, capacity: mapped.size)
        let bufferPointer = UnsafeBufferPointer(start: buffer, count: mapped.size)

        // Convert to Array for easy Equatable comparison
        #expect(Array(bufferPointer) == expectedBytes)
    }

    @Test("MappedFileTests: Initialization Failure")
    func mappedFileInitFailure() {
        let badPath = "/tmp/non_existent_file_\(UUID().uuidString)"

        // Verify that attempting to map a non-existent file throws
        // and does NOT leak a file descriptor (though we can't easily check for fd leaks in Swift,
        // we ensure the logic path is correct).
        #expect(throws: FileSystemError.openFileFailed(errno)) {
            _ = try MappedFile(path: badPath)
        }
    }

    @Test("MappedFile: Bounds Checking")
    func testOutOfBounds() throws {
        let path = createTempPath()
        try "Small".write(toFile: path, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mapped = try MappedFile(path: path)

        // Requesting more data than exists should throw
        #expect(throws: FileSystemError.outOfBounds) {
            _ = try mapped.buffer(at: 0, size: 999)
        }
    }

    @Test("MappedFile: Closed State Safety")
    func testMappedFileClosed() throws {
        let path = createTempPath()
        try "data".write(toFile: path, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mapped = try MappedFile(path: path)

        // Assuming you have a close() method that sets pointer = nil
        mapped.close()

        #expect(throws: FileSystemError.mappedFileClosed) {
            _ = try mapped.getPointer()
        }
    }
}

// MARK: - Helpers

extension MappedFileTests {
    struct TestData {
        let id: Int32
        let value: Float
    }

    private func createTempPath() -> String {
        let name = "test_\(UUID().uuidString)"
        return FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(name)
            .path
    }
}
