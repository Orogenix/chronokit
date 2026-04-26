import ChronoSystem
@testable import ChronoTZGenCore
import Foundation
import Testing

struct IOUtilsTests {
    @Test("IOUtilsTests: readFileBytes reads correct data")
    func testReadFileBytes() throws {
        try withSandbox { sandbox in
            let path = sandbox.appendingPathComponent("test.bin").path
            let content: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
            try Data(content).write(to: URL(fileURLWithPath: path))

            let result = try readFileBytes(path: path)
            #expect(result == content)
        }
    }

    @Test("IOUtilsTests: writeBytes writes raw memory correctly")
    func testWriteBytes() throws {
        try withSandbox { sandbox in
            let path = sandbox.appendingPathComponent("bytes.bin").path
            let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
            defer { FileSystem.closeFile(fd) }

            let value: UInt32 = 0x1234_5678
            try writeBytes(value.bigEndian, to: fd)
            FileSystem.closeFile(fd) // Close to flush

            let readBack = try Data(contentsOf: URL(fileURLWithPath: path))
            #expect(readBack == Data([0x12, 0x34, 0x56, 0x78]))
        }
    }

    @Test("IOUtilsTests: writeString writes UTF8 data")
    func testWriteString() throws {
        try withSandbox { sandbox in
            let path = sandbox.appendingPathComponent("string.txt").path
            let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
            defer { FileSystem.closeFile(fd) }

            let text = "Hello"
            try writeString(text, to: fd)
            FileSystem.closeFile(fd)

            let readBack = try String(contentsOfFile: path, encoding: .utf8)
            #expect(readBack == text)
        }
    }

    @Test("IOUtilsTests: writeFixedString handles padding and truncation")
    func testWriteFixedString() throws {
        try withSandbox { sandbox in
            let path = sandbox.appendingPathComponent("fixed.bin").path
            let fd = try FileSystem.openFile(path, mode: .writeCreateTruncate)
            defer { FileSystem.closeFile(fd) }

            // Test 1: Short string (expect padding)
            try writeFixedString("abc", to: fd, length: 10)

            // Test 2: Truncation
            try writeFixedString("123456789012345678901234567890123", to: fd, length: 32)

            FileSystem.closeFile(fd)
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            // Verify Padded string
            let firstSegment = data.prefix(10)
            #expect(firstSegment.prefix(3) == Data("abc".utf8))
            #expect(firstSegment.suffix(7).allSatisfy { $0 == 0 }, "Trailing bytes should be null padding")

            // Verify Truncated string
            let secondSegment = data.suffix(32)
            #expect(secondSegment.count == 32)
            #expect(secondSegment == Data("12345678901234567890123456789012".utf8))
        }
    }
}

extension IOUtilsTests {
    private func withSandbox(block: (URL) throws -> Void) throws {
        let sandbox = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: sandbox, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: sandbox) }
        try block(sandbox)
    }
}
