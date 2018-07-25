public class PathCollection: Equatable, CustomStringConvertible {
    public internal(set) var files: [FilePath]
    public internal(set) var directories: [DirectoryPath]
    public internal(set) var other: [GenericPath]

    public var isEmpty: Bool { return files.isEmpty && directories.isEmpty && other.isEmpty }
    public var count: Int { return files.count + directories.count + other.count }

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

    init(files: [FilePath] = [], directories: [DirectoryPath] = [], other: [GenericPath] = []) {
        self.files = files
        self.directories = directories
        self.other = other
    }

    public static func += (lhs: inout PathCollection, rhs: PathCollection) {
        lhs.files += rhs.files
        lhs.directories += rhs.directories
        lhs.other += rhs.other
    }

    public static func == (lhs: PathCollection, rhs: PathCollection) -> Bool {
        return lhs.files == rhs.files && lhs.directories == rhs.directories && lhs.other == rhs.other
    }
}
