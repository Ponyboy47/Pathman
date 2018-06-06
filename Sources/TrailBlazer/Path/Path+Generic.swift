#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A type used to express filesystem paths
public class GenericPath: _Path, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
	public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias ArrayLiteralElement = String

    /// The stored path to use and manipulate
    public internal(set) var path: String

    // This is to protect the info from being set externally
    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init(_ components: [String]) {
        path = components.filter({ !$0.isEmpty && $0 != GenericPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == GenericPath.separator {
            path = first + path
        }
        _info = StatInfo(path)
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
            path = String(str.dropLast())
        } else {
            path = str
        }
        _info = StatInfo(path)
    }

    public required init<PathType: Path>(_ path: PathType) {
        self.path = path.path
        _info = path.info
    }

    /// Initialize from a string literal
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            path = String(value.dropLast())
        } else {
            path = value
        }
        _info = StatInfo(path)
    }

    /// Initialize from a string literal
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            path = String(value.dropLast())
        } else {
            path = value
        }
        _info = StatInfo(path)
    }

    /// Initialize from a string literal
    public required init(stringLiteral value: StringLiteralType) {
        if value.count > 1 && value.hasSuffix(GenericPath.separator) {
            path = String(value.dropLast())
        } else {
            path = value
        }
        _info = StatInfo(path)
    }

    /// Initialize from a string array literal
    public required init(arrayLiteral components: ArrayLiteralElement...) {
        path = components.filter({ !$0.isEmpty && $0 != GenericPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == GenericPath.separator {
            path = first + path
        }
        _info = StatInfo(path)
    }
}
