/// A type used to express filesystem paths
public struct GenericPath: Path, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    /// The stored path to use and manipulate
    public var _path: String

    // This is to protect the info from being set externally
    public let _info: StatInfo

    public init(_ str: String) {
        if str.count > 1 && str.hasSuffix(GenericPath.separator) {
            _path = String(str.dropLast())
        } else {
            _path = str
        }
        _info = StatInfo(_path)
        try? _info.getInfo()
    }

    /// Initialize from an array of path elements
    public init(_ components: [String]) {
        _path = components.filter({ !$0.isEmpty && $0 != GenericPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == GenericPath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)
        try? _info.getInfo()
    }

    /// Initialize from a variadic array of path elements
    public init(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public init(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public init<PathType: Path>(_ path: PathType) {
        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    /// Initialize from a string literal
    public init(stringLiteral value: String) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            _path = String(value.dropLast())
        } else {
            _path = value
        }
        _info = StatInfo(_path)
        try? _info.getInfo()
    }

    /// Initialize from a string array literal
    public init(arrayLiteral components: String...) {
        self.init(components)
    }

    public static func + (lhs: GenericPath, rhs: GenericPath) -> GenericPath {
        var newPath = lhs.string
        let right = rhs.string

        if !newPath.hasSuffix(GenericPath.separator) {
            newPath += GenericPath.separator
        }

        if right.hasPrefix(GenericPath.separator) {
            newPath += right.dropFirst()
        } else {
            newPath += right
        }

        return GenericPath(newPath)
    }

    public static func + (lhs: GenericPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    public static func + (lhs: String, rhs: GenericPath) -> GenericPath {
        return GenericPath(lhs) + rhs
    }

    public static func += (lhs: inout GenericPath, rhs: GenericPath) {
        lhs = lhs + rhs
    }

    public static func += (lhs: inout GenericPath, rhs: String) {
        lhs = lhs + rhs
    }
}
