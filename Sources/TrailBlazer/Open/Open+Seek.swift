#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Protocol declaration for types that contain an offset which points to a
/// byte location in the file and may be moved around
public protocol Seekable: Opened {
    func seek(fromStart bytes: OSOffsetInt) throws -> OSOffsetInt
    func seek(fromEnd bytes: OSOffsetInt) throws -> OSOffsetInt
    func seek(fromCurrent bytes: OSOffsetInt) throws -> OSOffsetInt
    // These are available on the following filesystems:
    // Btrfs, OCFS, XFS, ext4, tmpfs, and the macOS filesystem
    #if SEEK_HOLE
    func seek(toNextHoleAfter offset: OSOffsetInt) throws -> OSOffsetInt
    #endif
    #if SEEK_DATA
    func seek(toNextDataAfter offset: OSOffsetInt) throws -> OSOffsetInt
    #endif

    /// Moves the file offset back to the beginning of the file
    func rewind() throws -> OSOffsetInt
}

public extension Seekable {
    /// The location in the path from where reading and writing begin. Measured
    /// in bytes from the beginning of the path
    public var offset: OSOffsetInt {
        get { return (try? seek(fromCurrent: 0)) ?? -1 }
        nonmutating set { _ = try? seek(fromStart: newValue) }
    }

    /// Seeks using the specified offset
    @discardableResult
    public func seek(_ offset: Offset) throws -> OSOffsetInt {
        let seekFunc: (OSOffsetInt) throws -> OSOffsetInt

        switch offset.type {
        case .beginning: seekFunc = seek(fromStart:)
        case .end: seekFunc = seek(fromEnd:)
        case .current: seekFunc = seek(fromCurrent:)
        #if SEEK_HOLE
        case .hole: seekFunc = seek(toNextHoleAfter:)
        #endif
        #if SEEK_DATA
        case .data: seekFunc = seek(toNextDataAfter:)
        #endif
        default: throw SeekError.unknownOffsetType
        }

        return try seekFunc(offset.bytes)
    }

    @discardableResult
    public func rewind() throws -> OSOffsetInt {
        return try seek(fromStart: 0)
    }
}

/// Information needed for seeking within a path
public struct Offset {
    /// The type of seeking to be performed
    public struct OffsetType: RawRepresentable, Equatable {
        public let rawValue: OptionInt

        /// Seek from the beginning of a path
        public static let beginning = OffsetType(rawValue: SEEK_SET)
        /// Seek from the end of a path
        public static let end = OffsetType(rawValue: SEEK_END)
        /// Seek from the current offset of a path
        public static let current = OffsetType(rawValue: SEEK_CUR)
        #if SEEK_HOLE
        /// Seek to the next hole in the data of a path
        public static let hole = OffsetType(rawValue: SEEK_HOLE)
        #endif
        #if SEEK_DATA
        /// Seek to the next data section of a path
        public static let data = OffsetType(rawValue: SEEK_DATA)
        #endif

        public init(rawValue: OptionInt) {
            self.rawValue = rawValue
        }
    }

    /// An Offset pointing to the beginning of a path
    public static let beginning = Offset(.beginning, 0)
    /// An Offset pointing to the end of a path
    public static let end = Offset(.end, 0)
    /// An Offset pointing to the current offset of a path
    public static let current = Offset(.current, 0)

    /// The type of seeking to be performed
    var type: OffsetType
    /// Either the number of bytes to seek or the offset to begin seeking from
    var bytes: OSOffsetInt

    init(_ type: OffsetType, _ bytes: OSOffsetInt) {
        self.init(type: type, bytes: bytes)
    }

    public init(type: OffsetType, bytes: OSOffsetInt) {
        self.type = type
        self.bytes = bytes
    }
}
