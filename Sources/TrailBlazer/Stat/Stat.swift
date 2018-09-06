import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A protocol specification for objects making stat(2) C API calls
protocol Stat {
    /// The underlying stat struct that stores the information from the stat(2) C API calls
    var _buffer: UnsafeMutablePointer<stat> { get set }

    init(buffer: UnsafeMutablePointer<stat>)

    /// Whether or not the path exists (or is accessible)
    var exists: Bool { get }
    /// ID of device containing path
    var id: dev_t { get }
    /// inode number
    var inode: ino_t { get }
    /// The type of the path
    var type: PathType? { get }
    /// The path permissions
    var permissions: FileMode { get }
    /// user ID of owner
    var owner: uid_t { get }
    /// group ID of owner
    var group: gid_t { get }
    /// device ID (if special file)
    var device: dev_t { get }
    /// total size, in bytes
    var size: OSOffsetInt { get }
    /// blocksize for filesystem I/O
    var blockSize: blksize_t { get }
    /// number of 512B blocks allocated
    var blocks: OSOffsetInt { get }

    /// time of last access
    var lastAccess: Date { get }
    /// time of last modification
    var lastModified: Date { get }
    /// time of last status change
    var lastAttributeChange: Date { get }
    #if os(macOS)
    /// time the path was created
    var creation: Date { get }
    #endif
}

extension Stat {
    public var id: dev_t {
        return _buffer.pointee.st_dev
    }
    public var inode: ino_t {
        return _buffer.pointee.st_ino
    }
    public var type: PathType? {
        return PathType(rawValue: _buffer.pointee.st_mode)
    }
    public var permissions: FileMode {
        return FileMode(rawValue: _buffer.pointee.st_mode)
    }
    public var owner: uid_t {
        return _buffer.pointee.st_uid
    }
    public var group: gid_t {
        return _buffer.pointee.st_gid
    }
    public var device: dev_t {
        return _buffer.pointee.st_rdev
    }
    public var size: OSOffsetInt {
        return _buffer.pointee.st_size
    }
    public var blockSize: Int32 {
        return _buffer.pointee.st_blksize
    }
    public var blocks: OSOffsetInt {
        return _buffer.pointee.st_blocks
    }

    public var lastAccess: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_atim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_atimespec))
        #endif
    }
    public var lastModified: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_mtim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_mtimespec))
        #endif
    }
    public var lastAttributeChange: Date {
        #if os(Linux)
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_ctim))
        #else
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_ctimespec))
        #endif
    }
    #if os(macOS)
    public var creation: Date {
        return Date(timeIntervalSince1970: Self.timespecToTimeInterval(_buffer.pointee.st_birthtimespec))
    }
    #endif

    /// Converts a timespec to a Swift TimeInterval (AKA Double)
    private static func timespecToTimeInterval(_ spec: timespec) -> TimeInterval {
        return TimeInterval(spec.tv_sec) + (Double(spec.tv_nsec) * pow(10.0,-9.0))
    }
}
