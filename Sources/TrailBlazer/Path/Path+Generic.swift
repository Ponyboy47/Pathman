/// A type used to express filesystem paths
open class GenericPath: Path, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias ArrayLiteralElement = String

    /// The stored path to use and manipulate
    public var _path: String

    // This is to protect the info from being set externally
    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init(_ components: [String]) {
        _path = components.filter({ !$0.isEmpty && $0 != GenericPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == GenericPath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)
    }

    /// Initialize from a variadic array of path elements
    public convenience init(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public convenience init(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init(_ str: String) {
        if str.count > 1 && str.hasSuffix(GenericPath.separator) {
            _path = String(str.dropLast())
        } else {
            _path = str
        }
        _info = StatInfo(_path)
    }

    public required init<PathType: Path>(_ path: PathType) {
        _path = path._path
        _info = path.info
    }

    /// Initialize from a string literal
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            _path = String(value.dropLast())
        } else {
            _path = value
        }
        _info = StatInfo(_path)
    }

    /// Initialize from a string literal
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            _path = String(value.dropLast())
        } else {
            _path = value
        }
        _info = StatInfo(_path)
    }

    /// Initialize from a string literal
    public required init(stringLiteral value: StringLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            _path = String(value.dropLast())
        } else {
            _path = value
        }
        _info = StatInfo(_path)
    }

    /// Initialize from a string array literal
    public required init(arrayLiteral components: ArrayLiteralElement...) {
        _path = components.filter({ !$0.isEmpty && $0 != GenericPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == GenericPath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)
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
