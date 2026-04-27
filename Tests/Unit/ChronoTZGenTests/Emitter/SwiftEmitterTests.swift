import ChronoTZ
@testable import ChronoTZGenCore
import Foundation
import Testing

struct SwiftEmitterTests {
    @Test("SwiftEmitterTests: Generates syntactically valid Swift source")
    func swiftEmitterOutput() throws {
        // Setup temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let outputPath = tempDir.appendingPathComponent("TZDatabase.swift").path
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        // Prepare Mock Context
        let ctx = Packer.Context(
            blobCache: [[0xDE, 0xAD]: 0],
            indexTable: [
                TZDBIndexEntry(name: [0x41], offset: 0, size: 2),
            ]
        )

        // Act
        let emitter = SwiftEmitter()
        try emitter.emit(ctx: ctx, to: outputPath)

        // Verify Output
        let content = try String(contentsOfFile: outputPath)

        // Check for required boilerplate and syntax
        #expect(content.contains("internal struct TZDatabase"), "Should generate valid struct declaration")
        #expect(content.contains("internal static let bytes: [UInt8] = ["), "Should generate valid static byte array")

        // Verify formatting
        #expect(content.contains("0xDE, 0xAD"), "Bytes should be formatted as hex strings")

        // Ensure it doesn't leave dangling brackets
        #expect(content.hasSuffix("]\n}"), "Should close the array and struct correctly")
    }
}
