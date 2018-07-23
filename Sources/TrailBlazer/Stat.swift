import ErrNo
import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct StatInfo: StatDescriptor, StatPath {
    var _path: String?
    var options: StatOptions
    var fileDescriptor: FileDescriptor?
    var buffer: stat = stat()

    init() {
        _path = nil
        options = []
        fileDescriptor = nil
    }

    init(_ buffer: stat = stat()) {
        self.init()
        self.buffer = buffer
    }

    mutating func getInfo(options: StatOptions = []) throws {
        if let fd = self.fileDescriptor {
            try StatInfo.update(fd, &self.buffer)
        } else if let path = _path {
            try StatInfo.update(path, options: options, &self.buffer)
        }
    }
}

protocol Stat {
    var buffer: stat { get set }

    init(_ buffer: stat)

    /// ID of device containing file
    var id: dev_t { get }
    /// inode number
    var inode: ino_t { get }
    /// The type of the file
    var type: FileType? { get }
    /// The file permissions
    var permissions: FileMode { get }
    /// user ID of owner
    var owner: uid_t { get }
    /// group ID of owner
    var group: gid_t { get }
    /// device ID (if special file)
    var device: dev_t { get }
    /// total size, in bytes
    var size: OSInt { get }
    /// blocksize for filesystem I/O
    var blockSize: OSInt { get }
    /// number of 512B blocks allocated
    var blocks: OSInt { get }

    /// time of last access
    var lastAccess: Date { get }
    /// time of last modification
    var lastModified: Date { get }
    /// time of last status change
    var lastAttributeChange: Date { get }
    #if os(macOS)
    /// time the file was created
    var creation: Date { get }
    #endif
}

extension Stat {
    public var id: dev_t {
        return buffer.st_dev
    }
    public var inode: ino_t {
        return buffer.st_ino
    }
    public var type: FileType? {
        return FileType(rawValue: buffer.st_mode)
    }
    public var permissions: FileMode {
        return FileMode(rawValue: buffer.st_mode)
    }
    public var owner: uid_t {
        return buffer.st_uid
    }
    public var group: gid_t {
        return buffer.st_gid
    }
    public var device: dev_t {
        return buffer.st_rdev
    }
    public var size: OSInt {
        return OSInt(buffer.st_size)
    }
    public var blockSize: OSInt {
        return OSInt(buffer.st_blksize)
    }
    public var blocks: OSInt {
        return OSInt(buffer.st_blocks)
    }

    public var lastAccess: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_atim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_atimespec))
        #endif
    }
    public var lastModified: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_mtim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_mtimespec))
        #endif
    }
    public var lastAttributeChange: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_ctim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_ctimespec))
        #endif
    }
    #if os(macOS)
    public var creation: Date {
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(buffer.st_birthtimespec))
    }
    #endif

    private static func timespecToTimeInterval(_ spec: timespec) -> TimeInterval {
        return TimeInterval(spec.tv_sec) + (Double(spec.tv_nsec) * pow(10.0,-9.0))
    }
}

protocol StatDescriptor: Stat {
    var fileDescriptor: FileDescriptor? { get set }
    init(_ fileDescriptor: FileDescriptor, buffer: stat)
    mutating func update() throws
    static func update(_ fileDescriptor: FileDescriptor, _ buffer: inout stat) throws
}

extension StatDescriptor {
    /**
    Get information about a file

    - Throws:
        - StatError.permissionDenied: (Shouldn't occur) Search permission is denied for one of the directories in the path prefix of pathname.
        - StatError.badFileDescriptor: fileDescriptor is bad.
        - StatError.badAddress: Bad address.
        - StatError.tooManySymlinks: Too many symbolic links encountered while traversing the path.
        - StatError.pathnameTooLong: (Shouldn't occur) pathname is too long.
        - StatError.noRouteToPathname: (Shouldn't occur) A component of pathname does not exist, or pathname is an empty string.
        - StatError.outOfMemory: Out of memory (i.e., kernel memory).
        - StatError.notADirectory: (Shouldn't occur) A component of the path prefix of pathname is not a directory.
        - StatError.fileTooLarge: fileDescriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t.
    */
    public static func update(_ fileDescriptor: FileDescriptor, _ buffer: inout stat) throws {
        guard fstat(fileDescriptor, &buffer) == 0 else { throw StatError.getError() }
    }

    public mutating func update() throws {
        guard let descriptor = fileDescriptor else {
            throw StatError.badFileDescriptor
        }
        try Self.update(descriptor, &buffer)
    }

    public init(_ fileDescriptor: FileDescriptor, buffer: stat = stat()) {
        self.init(buffer)
        self.fileDescriptor = fileDescriptor
    }
}

protocol StatPath: Stat {
    var _path: String? { get set }
    var options: StatOptions { get set }
    init<PathType: Path>(_ path: PathType, options: StatOptions, buffer: stat)
    init(_ path: String, options: StatOptions, buffer: stat)
    mutating func update(options: StatOptions) throws
    static func update(_ path: String, options: StatOptions, _ buffer: inout stat) throws
}

extension StatPath {
    /**
    Get information about a file

    - Throws:
        - StatError.permissionDenied: Search permission is denied for one of the directories in the path prefix of pathname.
        - StatError.badAddress: Bad address.
        - StatError.tooManySymlinks: Too many symbolic links encountered while traversing the path.
        - StatError.pathnameTooLong: pathname is too long.
        - StatError.noRouteToPathname: A component of pathname does not exist, or pathname is an empty string.
        - StatError.outOfMemory: Out of memory (i.e., kernel memory).
        - StatError.notADirectory: A component of the path prefix of pathname is not a directory.
        - StatError.fileTooLarge: fileDescriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t.
    */
    public static func update(_ path: String, options: StatOptions = [], _ buffer: inout stat) throws {
        let statResponse: OptionInt
        if options.contains(.getLinkInfo) {
            statResponse = lstat(path, &buffer)
        } else {
            statResponse = stat(path, &buffer)
        }
        guard statResponse == 0 else { throw StatError.getError() }
    }

    public mutating func update(options: StatOptions = []) throws {
        var options = options
        options.insert(self.options)
        guard let path = _path else {
            throw PathError.emptyPath
        }
        try Self.update(path, options: options, &self.buffer)
    }

    public init(_ path: String, options: StatOptions = [], buffer: stat = stat()) {
        self.init(buffer)
        _path = path
        self.options = options
    }

    public init<PathType: Path>(_ path: PathType, options: StatOptions = [], buffer: stat = stat()) {
        self.init(path._path, options: options, buffer: buffer)
    }
}

public struct StatOptions: OptionSet {
    public let rawValue: Int

    public static let getLinkInfo = StatOptions(rawValue: 1 << 0)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

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

public protocol StatDelegate {
    var info: StatInfo { get }
}

public extension StatDelegate {
    public var id: dev_t {
        return info.id
    }
    public var inode: ino_t {
        return info.inode
    }
    public var type: FileType? {
        return info.type
    }
    public var permissions: FileMode {
        return info.permissions
    }
    public var owner: uid_t {
        return info.owner
    }
    public var group: gid_t {
        return info.group
    }
    public var device: dev_t {
        return info.device
    }
    public var size: OSInt {
        return OSInt(info.size)
    }
    public var blockSize: OSInt {
        return OSInt(info.blockSize)
    }
    public var blocks: OSInt {
        return OSInt(info.blocks)
    }

    public var lastAccess: Date {
        return info.lastAccess
    }
    public var lastModified: Date {
        return info.lastModified
    }
    public var lastAttributeChange: Date {
        return info.lastAttributeChange
    }
    #if os(macOS)
    public var creation: Date {
        return info.creation
    }
    #endif
}
