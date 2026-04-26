@testable import ChronoSystem
import Foundation
import Testing

struct ResourceLocatorTests {
    @Test("ResourceLocatorTests: findInProject successfully locates resources in development structure")
    func testFindInProject() throws {
        #if DEBUG
            // Setup the specific path structure expected by the locator
            let cwd = FileManager.default.currentDirectoryPath
            let resourcePath = "\(cwd)/Sources/ChronoTZ/Resources"
            try FileManager.default.createDirectory(atPath: resourcePath, withIntermediateDirectories: true)

            let testFileName = "test_resource.txt"
            let fullPath = "\(resourcePath)/\(testFileName)"

            // Create a dummy file
            try "content".write(toFile: fullPath, atomically: true, encoding: .utf8)
            defer { try? FileManager.default.removeItem(atPath: fullPath) }

            // Test the locator
            let foundPath = ResourceLocator.findInProject(named: testFileName)

            #expect(foundPath != nil, "Should find the resource in the project structure")
            #expect(foundPath == fullPath, "Should return the correct full path")
        #else
            print("Skipping findInProject test: Not a DEBUG build.")
        #endif
    }

    @Test("ResourceLocatorTests: find returns nil for non-existent resource")
    func findNonExistent() {
        let foundPath = ResourceLocator.find(named: "this_file_does_not_exist_12345.xyz")
        #expect(foundPath == nil, "Should return nil when file does not exist")
    }
}
