@testable import ChronoTZGenCore
import Testing

struct CLITests {
    @Test("CLITests: Successfully parse valid arguments")
    func validArguments() throws {
        let args = ["--input", "/path/in", "--output", "/path/out", "--format", "c"]
        let cli = try CLI(args: args)

        #expect(cli.inputDir == "/path/in")
        #expect(cli.outputPath == "/path/out")
        #expect(cli.format == .c)
    }

    @Test("CLITests: Default format is used when --format is missing")
    func defaultFormat() throws {
        let args = ["--input", "/in", "--output", "/out"]
        let cli = try CLI(args: args)

        #expect(cli.format == .c) // Assuming .c is your default
    }

    @Test("CLITests: Throws error for missing value")
    func missingValue() {
        let args = ["--input"] // Missing the directory path

        #expect(throws: CLIError.missingValue("--input")) {
            try CLI(args: args)
        }
    }

    @Test("CLITests: Throws error for missing required arguments")
    func missingRequiredArgs() {
        let args = ["--input", "/only_input"]

        #expect(throws: CLIError.usage) {
            try CLI(args: args)
        }
    }

    @Test("CLITests: Throws error for invalid format")
    func invalidFormat() {
        let args = ["--input", "/in", "--output", "/out", "--format", "unknown_format"]

        #expect(throws: CLIError.invalidFormat("unknown_format")) {
            try CLI(args: args)
        }
    }
}
