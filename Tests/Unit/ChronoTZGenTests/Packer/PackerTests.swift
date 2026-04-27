import ChronoTZ
@testable import ChronoTZGenCore
import Foundation
import Testing

struct PackerTests {
    @Test("PackerTests: Processes directory and deduplicates data")
    func packerDeduplication() throws {
        // Setup sandbox
        let sandbox = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: sandbox, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: sandbox) }

        // Create dummy files with identical content
        // We don't need valid TZ data anymore because we will mock the decoder
        let fileA = sandbox.appendingPathComponent("zoneA")
        let fileB = sandbox.appendingPathComponent("zoneB")
        let data: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        try Data(data).write(to: fileA)
        try Data(data).write(to: fileB)

        // Initialize Packer with injected mock closures
        // We "mock" the codec by returning a dummy payload and returning the input bytes as the encoded output
        let packer = Packer(
            sourceDir: sandbox.path,
            parse: { _ in TZDBDataPayload(transitionCount: 0, typeCount: 0, transitions: [], types: []) },
            encode: { _ in data }
        )

        let ctx = try packer.process()

        #expect(ctx.blobCache.count == 1, "Should have deduplicated identical files")
        #expect(ctx.indexTable.count == 2, "Should have indexed both files")

        let firstOffset = ctx.indexTable.first?.offset
        let secondOffset = ctx.indexTable.last?.offset
        #expect(firstOffset == secondOffset, "Both files should point to the same offset")
    }
}
