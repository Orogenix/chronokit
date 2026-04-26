import ChronoTZ
@testable import ChronoTZGenCore
import Foundation
import Testing

struct BinaryEmitterTests {
    @Test("BinaryEmitterTests: Produces valid binary file structure")
    func binaryEmitterOutput() throws {
        // Setup temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let outputPath = tempDir.appendingPathComponent("test_tz.bin").path
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        // Prepare Mock Context
        let ctx = Packer.Context(
            blobCache: [[0xDE, 0xAD]: 0],
            indexTable: [
                TZIndexEntry(name: [0x41, 0x42], offset: 0, size: 10), // Mock entries
            ]
        )

        let emitter = BinaryEmitter()
        try emitter.emit(ctx: ctx, to: outputPath)

        // Verify Output
        let fileData = try Data(contentsOf: URL(fileURLWithPath: outputPath))

        let magic = fileData.prefix(4)
        #expect(magic == Data([0x54, 0x5A, 0x44, 0x42]), "Magic bytes should match")
        #expect(fileData.count > 0)
    }
}
