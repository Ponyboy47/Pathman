#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A swift enum that wraps the C stat mode_t into a path type (see stat(2))
public struct PathType: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CodingKey {
    public let rawValue: OSUInt
    public var intValue: Int? { return Int(rawValue) }
    public var stringValue: String {
        switch self {
        case .socket: return "socket"
        case .link: return "link"
        case .regular: return "file"
        case .block: return "block"
        case .directory: return "directory"
        case .character: return "character"
        case .fifo: return "fifo"
        default: return "unknown"
        }
    }

    /// Socket path
    public static let socket = PathType(integerLiteral: S_IFSOCK)
    /// Symbolic link
    public static let link = PathType(integerLiteral: S_IFLNK)
    /// Regular file
    public static let regular = PathType(integerLiteral: S_IFREG)
    /// Block device
    public static let block = PathType(integerLiteral: S_IFBLK)
    /// Directory path
    public static let directory = PathType(integerLiteral: S_IFDIR)
    /// Character device
    public static let character = PathType(integerLiteral: S_IFCHR)
    /// FIFO path
    public static let fifo = PathType(integerLiteral: S_IFIFO)
    /// Regular file
    public static let file: PathType = .regular

    public static let unknown = PathType(rawValue: 0)

    public init(rawValue: OSUInt) {
        self.rawValue = rawValue & S_IFMT
    }

    public init(integerLiteral value: OSUInt) {
        self.init(rawValue: value)
    }

    public init(stringLiteral value: String) {
        switch value.lowercased() {
        case "sock", "socket": self = .socket
        case "file", "reg", "regular": self = .file
        case "lnk", "link", "symlink", "softlink", "hardlink": self = .link
        case "blk", "block": self = .block
        case "dir", "directory": self = .directory
        case "character", "char", "chr": self = .character
        case "fifo": self = .fifo
        default: self = .unknown
        }
    }

    public init?(mode: FileMode) {
        self.init(rawValue: mode.rawValue)
        if rawValue == PathType.unknown.rawValue {
            return nil
        }
    }

    public init?(stringValue value: String) {
        self.init(stringLiteral: value)
        guard rawValue != PathType.unknown.rawValue else { return nil }
    }

    public init?(intValue value: Int) {
        if value < 0 {
            return nil
        }
        self.init(integerLiteral: OSUInt(value))
        guard stringValue != "unknown" else { return nil }
    }
}
