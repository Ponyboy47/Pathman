import struct Foundation.Date
import typealias Foundation.TimeInterval

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A protocol specification for objects making stat(2) C API calls
protocol Stat {
    // swiftlint:disable identifier_name
    /// The underlying stat struct that stores the information from the stat(2) C API calls
    var _buffer: stat { get set }
    // swiftlint:enable identifier_name

    init()
}

extension Stat {
    // swiftlint:disable identifier_name
    /// ID of device containing path
    public var id: dev_t { return _buffer.st_dev }
    // swiftlint:enable identifier_name
    /// inode number
    public var inode: ino_t { return _buffer.st_ino }
    /// The type of the path
    public var type: PathType { return PathType(rawValue: _buffer.st_mode) }
    /// The path permissions
    public var permissions: FileMode { return FileMode(rawValue: _buffer.st_mode) }
    /// user ID of owner
    public var owner: uid_t { return _buffer.st_uid }
    /// group ID of owner
    public var group: gid_t { return _buffer.st_gid }
    /// device ID (if special file)
    public var device: dev_t { return _buffer.st_rdev }
    /// total size, in bytes
    public var size: OSOffsetInt { return _buffer.st_size }
    /// blocksize for filesystem I/O
    public var blockSize: blksize_t { return _buffer.st_blksize }
    /// number of 512B blocks allocated
    public var blocks: OSOffsetInt { return _buffer.st_blocks }

    /// time of last access
    public var lastAccess: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_atim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_atimespec))
        #endif
    }
    /// time of last modification
    public var lastModified: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_mtim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_mtimespec))
        #endif
    }
    /// time of last status change
    public var lastAttributeChange: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_ctim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_ctimespec))
        #endif
    }
    /// time the path was created
    #if os(macOS)
    public var creation: Date {
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.st_birthtimespec))
    }
    #endif

    /// Converts a timespec to a Swift TimeInterval (AKA Double)
    private static func timespecToTimeInterval(_ spec: timespec) -> TimeInterval {
        return TimeInterval(spec.tv_sec) + (Double(spec.tv_nsec) * pow(10.0, -9.0))
    }
}
