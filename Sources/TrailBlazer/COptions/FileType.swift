#if os(Linux)
import Glibc
#else
import Darwin
#endif

public enum FileType: OSUInt {
    case socket
    case link
    case regular
    case block
    case directory
    case character
    case fifo
    public static let file: FileType = .regular

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
}
