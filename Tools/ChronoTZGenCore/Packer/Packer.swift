import ChronoSystem
import ChronoTZ

package struct Packer {
    package struct Context {
        var blobCache: [[UInt8]: UInt32] = [:]
        var indexTable: [TZIndexEntry] = []
    }

    private static let ignoreList: Set<String> = [
        ".git", ".gitignore", "README", "CONTRIBUTING", "LICENSE",
        "Makefile", "asctime.c", "date.c", "difftime.c", "localtime.c",
        "strftime.c", "zdump.c", "zic.c", "private.h", "tzfile.h",
    ]

    let sourceDir: String
    let parse: ([UInt8]) throws -> TZDataPayload
    let encode: (TZDataPayload) throws -> [UInt8]

    package init(
        sourceDir: String,
        parse: @escaping ([UInt8]) throws -> TZDataPayload = TZifParser.parse(from:),
        encode: @escaping (TZDataPayload) throws -> [UInt8] = TZDBCodec.encode(_:)
    ) {
        self.sourceDir = sourceDir
        self.parse = parse
        self.encode = encode
    }
}

extension Packer {
    private func scanRecursive(
        at path: String,
        root: String,
        entries: inout [(name: String, path: String)]
    ) throws {
        try FileSystem.listDirectory(at: path) { name, isDir in
            if name.hasPrefix(".") { return }

            let fullPath = "\(path)/\(name)"

            if isDir {
                try scanRecursive(at: fullPath, root: root, entries: &entries)
            } else {
                if Self.ignoreList.contains(name)
                    || name.hasSuffix(".awk")
                    || name.hasSuffix(".html")
                    || name.hasSuffix(".c")
                {
                    return
                }

                let relativeName = fullPath.replacingOccurrences(of: root + "/", with: "")
                entries.append((name: relativeName, path: fullPath))
            }
        }
    }

    private func scanDirectory(at path: String) throws -> [(name: String, path: String)] {
        var entries: [(name: String, path: String)] = []
        try scanRecursive(at: path, root: path, entries: &entries)
        return entries.sorted { $0.name < $1.name }
    }
}

package extension Packer {
    func process() throws -> Context {
        let entries = try scanDirectory(at: sourceDir)
        var ctx = Context()

        let dataStartOffset = UInt32(TZHeader.ianaSize + (entries.count * TZIndexEntry.fixedSize))
        var currentOffset = dataStartOffset

        for entry in entries {
            let rawBytes = try readFileBytes(path: entry.path)

            let payload: TZDataPayload
            do {
                payload = try parse(rawBytes)
            } catch {
                print("Failed to decode: \(entry.path). Error: \(error)")
                throw PackerError.invalidPayload(path: entry.path)
            }

            let serialized: [UInt8]
            do {
                serialized = try encode(payload)
            } catch {
                print("Failed to encode: \(entry.path). Error: \(error)")
                throw PackerError.bufferOverflow(path: entry.path)
            }

            let size = UInt32(serialized.count)

            if let existingOffset = ctx.blobCache[serialized] {
                ctx.indexTable.append(TZIndexEntry(name: entry.name, offset: existingOffset, size: size))
            } else {
                ctx.blobCache[serialized] = currentOffset
                ctx.indexTable.append(TZIndexEntry(name: entry.name, offset: currentOffset, size: size))
                currentOffset += size
            }
        }

        return ctx
    }
}
