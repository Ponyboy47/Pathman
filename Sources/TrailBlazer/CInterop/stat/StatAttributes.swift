#if os(Linux)
import struct Glibc.timespec
import func Glibc.pow
#else
import struct Darwin.timespec
import func Darwin.pow
#endif

import struct Foundation.Date
import typealias Foundation.TimeInterval

extension Stat {
    // swiftlint:disable identifier_name
    /// ID of device containing path
    public var id: DeviceID { return _buffer.st_dev }
    // swiftlint:enable identifier_name
    /// inode number
    public var inode: Inode { return _buffer.st_ino }
    /// The type of the path
    public var type: PathType { return PathType(rawValue: _buffer.st_mode) }
    /// The path permissions
    public var permissions: FileMode { return FileMode(rawValue: _buffer.st_mode) }
    /// user ID of owner
    public var owner: UID { return _buffer.st_uid }
    /// group ID of owner
    public var group: GID { return _buffer.st_gid }
    /// device ID (if special file)
    public var device: DeviceID { return _buffer.st_rdev }
    /// total size, in bytes
    public var size: OSOffsetInt { return _buffer.st_size }
    /// blocksize for filesystem I/O
    public var blockSize: BlockSize { return _buffer.st_blksize }
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
