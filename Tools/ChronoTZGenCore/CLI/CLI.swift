package struct CLI {
    package let inputDir: String
    package let outputPath: String
    package let format: EmitterType
}

package extension CLI {
    init() throws {
        let args = CommandLine.arguments.dropFirst()
        try self.init(args: Array(args))
    }

    init(args: [String]) throws {
        var argMap: [String: String] = [:]

        var iterator = args.makeIterator()
        while let key = iterator.next() {
            guard let value = iterator.next() else {
                throw CLIError.missingValue(key)
            }
            argMap[key] = value
        }

        guard let inputDir = argMap["--input"],
              let outputPath = argMap["--output"]
        else {
            throw CLIError.usage
        }

        let formatStr = argMap["--format"] ?? "c"
        guard let format = EmitterType(rawValue: formatStr) else {
            throw CLIError.invalidFormat(formatStr)
        }

        self.inputDir = inputDir
        self.outputPath = outputPath
        self.format = format
    }
}
