public struct DirectoryChildren: Equatable, CustomStringConvertible {
    public internal(set) var files: [FilePath]
    public internal(set) var directories: [DirectoryPath]
    public internal(set) var other: [GenericPath]

    public var description: String {
        var str: [String] = []
        if !files.isEmpty {
            str.append("files:\n\t\(files.map { $0.string } )")
        }
        if !directories.isEmpty {
            str.append("directories:\n\t\(directories.map { $0.string } )")
        }
        if !other.isEmpty {
            str.append("other:\n\t\(other.map { $0.string } )")
        }
        return str.joined(separator: "\n\n")
    }

    public var prettyPrint: String {
        var str: [String] = []
        if !files.isEmpty {
            str.append("files:\n\t\(files.map({ $0.string }).joined(separator: "\n\t"))")
        }
        if !directories.isEmpty {
            str.append("directories:\n\t\(directories.map({ $0.string }).joined(separator: "\n\t"))")
        }
        if !other.isEmpty {
            str.append("other:\n\t\(other.map({ $0.string }).joined(separator: "\n\t"))")
        }
        return str.joined(separator: "\n\n")
    }

    init(files: [FilePath] = [], directories: [DirectoryPath] = [], other: [GenericPath] = []) {
        self.files = files
        self.directories = directories
        self.other = other
    }

    public static func += (lhs: inout DirectoryChildren, rhs: DirectoryChildren) {
        lhs.files += rhs.files
        lhs.directories += rhs.directories
        lhs.other += rhs.other
    }

    public static func == (lhs: DirectoryChildren, rhs: DirectoryChildren) -> Bool {
        return lhs.files == rhs.files && lhs.directories == rhs.directories && lhs.other == rhs.other
    }
}

