/// A Path to a file
public class FilePath: _Path {
    public internal(set) var path: String

    // This is to protect the info from being set externally
    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        path = components.filter({ !$0.isEmpty && $0 != FilePath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == FilePath.separator {
            path = first + path
        }
        _info = StatInfo(path)

        if exists {
            guard isFile else { return nil }
        }
    }

    /// Initialize from a variadic array of path elements
    public convenience init?(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public convenience init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init?(_ str: String) {
        if str.count > 1 && str.hasSuffix(FilePath.separator) {
            path = String(str.dropLast())
        } else {
            path = str
        }
        _info = StatInfo(path)

        if exists {
            guard isFile else { return nil }
        }
    }

    public required init?<PathType: Path>(_ path: PathType) {
        // Cannot initialize a file from a directory
        guard PathType.self != DirectoryPath.self else { return nil }

        self.path = path.path
        self._info = path.info

        if exists {
            guard isFile else { return nil }
        }
    }

    @available(*, unavailable, message: "Cannot append to a FilePath")
    public static func + <PathType: Path>(lhs: FilePath, rhs: PathType) -> PathType { fatalError("Cannot append to a FilePath") }
}
