import ChronoTZ
@testable import ChronoTZGenCore
import Foundation
import Testing

struct CEmitterTests {
    @Test("CEmitterTests: Generates .h and .c files successfully")
    func cEmitterOutput() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let baseName = "tzdb_test"
        let path = tempDir.appendingPathComponent(baseName).path

        defer {
            try? FileManager.default.removeItem(atPath: path + ".h")
            try? FileManager.default.removeItem(atPath: path + ".c")
        }

        let ctx = Packer.Context(
            blobCache: [[0x01, 0x02]: 0],
            indexTable: [TZIndexEntry(name: [0x41], offset: 0, size: 2)]
        )

        try CEmitter().emit(ctx: ctx, to: path)

        let hExists = FileManager.default.fileExists(atPath: path + ".h")
        let cExists = FileManager.default.fileExists(atPath: path + ".c")

        #expect(hExists, "Header file should be created")
        #expect(cExists, "Source file should be created")

        let cContent = try String(contentsOfFile: path + ".c")
        #expect(cContent.contains("tzdb_data[]"), "Generated C file should contain data array")
    }
}
