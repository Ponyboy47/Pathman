#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Protocol declaration for types that contain an offset which points to a
/// byte location in the file and may be moved around
public protocol Seekable: class {
    /// The location in the path from where reading and writing begin. Measured
    /// in bytes from the beginning of the path
    var offset: OSInt { get set }
    /// Whether the offset is at the end of the file
    var eof: Bool { get }

    func seek(_ offset: Offset) throws -> OSInt

    func seek(fromStart bytes: OSInt) throws -> OSInt
    func seek(fromEnd bytes: OSInt) throws -> OSInt
    func seek(fromCurrent bytes: OSInt) throws -> OSInt
    // These are available on the following filesystems:
    // Btrfs, OCFS, XFS, ext4, tmpfs, and the macOS filesystem
    #if SEEK_DATA && SEEK_HOLE
    func seek(toNextHoleAfter offset: OSInt) throws -> OSInt
    func seek(toNextDataAfter offset: OSInt) throws -> OSInt
    #endif

    func rewind() throws -> OSInt
}

public extension Seekable {
    /// Seeks using the specified offset
    @discardableResult
    public func seek(_ offset: Offset) throws -> OSInt {
        let newOffset: OSInt

        switch offset.type {
        case .beginning: newOffset = try seek(fromStart: offset.bytes)
        case .end: newOffset = try seek(fromEnd: offset.bytes)
        case .current: newOffset = try seek(fromCurrent: offset.bytes)
        #if SEEK_DATA && SEEK_HOLE
        case .data: newOffset = try seek(toNextDataAfter: offset.bytes)
        case .hole: newOffset = try seek(toNextHoleAfter: offset.bytes)
        #endif
        default: throw SeekError.unknownOffsetType
        }

        self.offset = newOffset
        return self.offset
    }
}

/// Information needed for seeking within a path
public struct Offset {
    /// The type of seeking to be performed
    public struct OffsetType: RawRepresentable, Equatable {
        public typealias RawValue = OptionInt
        public let rawValue: RawValue

        /// Seek from the beginning of a path
        public static let beginning = OffsetType(rawValue: SEEK_SET)
        /// Seek from the end of a path
        public static let end = OffsetType(rawValue: SEEK_END)
        /// Seek from the current offset of a path
        public static let current = OffsetType(rawValue: SEEK_CUR)
        #if SEEK_DATA && SEEK_HOLE
        /// Seek to the next data section of a path
        public static let data = OffsetType(rawValue: SEEK_DATA)
        /// Seek to the next hole in the data of a path
        public static let hole = OffsetType(rawValue: SEEK_HOLE)
        #endif

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    /// The type of seeking to be performed
    var type: OffsetType
    /// Either the number of bytes to seek or the offset to begin seeking from
    var bytes: OSInt

    init(_ type: OffsetType, _ bytes: OSInt) {
        self.type = type
        self.bytes = bytes
    }

    public init(type: OffsetType, bytes: OSInt) {
        self.type = type
        self.bytes = bytes
    }
}
