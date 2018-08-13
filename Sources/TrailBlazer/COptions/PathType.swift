#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A swift enum that wraps the C stat mode_t into a path type (see stat(2))
public enum PathType: OSUInt {
    /// Socket path
    case socket
    /// Symbolic link
    case link
    /// Regular file
    case regular
    /// Block device
    case block
    /// Directory path
    case directory
    /// Character device
    case character
    /// FIFO path
    case fifo
    /// Regular file
    public static let file: PathType = .regular

    public init?(rawValue: OSUInt) {
        switch rawValue & S_IFMT {
        case S_IFSOCK: self = .socket
        case S_IFLNK: self = .link
        case S_IFREG: self = .regular
        case S_IFBLK: self = .block
        case S_IFDIR: self = .directory
        case S_IFCHR: self = .character
        case S_IFIFO: self = .fifo
        default: return nil
        }
    }

    public init?(mode: FileMode) {
        self.init(rawValue: mode.rawValue)
    }
}
