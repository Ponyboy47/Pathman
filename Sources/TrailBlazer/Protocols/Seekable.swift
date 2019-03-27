#if os(Linux)
import let Glibc.SEEK_CUR
import let Glibc.SEEK_END
import let Glibc.SEEK_SET
#else
import let Darwin.SEEK_CUR
import let Darwin.SEEK_DATA
import let Darwin.SEEK_END
import let Darwin.SEEK_HOLE
import let Darwin.SEEK_SET
#endif

public protocol SeekableByOpened: Openable {
    static func seek(fromStart bytes: OSOffsetInt, in opened: Open<Self>) throws -> OSOffsetInt
    static func seek(fromEnd bytes: OSOffsetInt, in opened: Open<Self>) throws -> OSOffsetInt
    static func seek(fromCurrent bytes: OSOffsetInt, in opened: Open<Self>) throws -> OSOffsetInt
    // These are available on the following filesystems:
    // Btrfs, OCFS, XFS, ext4, tmpfs, and the macOS filesystem
    // Unfortunately checking the value does not work
    #if os(macOS)
    static func seek(toNextHoleAfter offset: OSOffsetInt, in opened: Open<Self>) throws -> OSOffsetInt
    static func seek(toNextDataAfter offset: OSOffsetInt, in opened: Open<Self>) throws -> OSOffsetInt
    #endif
}

/// Protocol declaration for types that contain an offset which points to a
/// byte location in the file and may be moved around
public protocol Seekable {
    func seek(fromStart bytes: OSOffsetInt) throws -> OSOffsetInt
    func seek(fromEnd bytes: OSOffsetInt) throws -> OSOffsetInt
    func seek(fromCurrent bytes: OSOffsetInt) throws -> OSOffsetInt
    // These are available on the following filesystems:
    // Btrfs, OCFS, XFS, ext4, tmpfs, and the macOS filesystem
    // Unfortunately checking the value does not work
    #if os(macOS)
    func seek(toNextHoleAfter offset: OSOffsetInt) throws -> OSOffsetInt
    func seek(toNextDataAfter offset: OSOffsetInt) throws -> OSOffsetInt
    #endif
}

public extension Seekable {
    /// The location in the path from where reading and writing begin. Measured
    /// in bytes from the beginning of the path
    var offset: OSOffsetInt {
        get { return (try? seek(fromCurrent: 0)) ?? -1 }
        nonmutating set { _ = try? seek(fromStart: newValue) }
    }

    /// Seeks using the specified offset
    @discardableResult
    func seek(_ offset: Offset) throws -> OSOffsetInt {
        let seekFunc: (OSOffsetInt) throws -> OSOffsetInt

        switch offset.type {
        case .beginning: seekFunc = seek(fromStart:)
        case .end: seekFunc = seek(fromEnd:)
        case .current: seekFunc = seek(fromCurrent:)
        #if os(macOS)
        case .hole: seekFunc = seek(toNextHoleAfter:)
        case .data: seekFunc = seek(toNextDataAfter:)
        #endif
        default: throw SeekError.unknownOffsetType
        }

        return try seekFunc(offset.bytes)
    }

    /// Moves the file offset back to the beginning of the file
    @discardableResult
    func rewind() throws -> OSOffsetInt {
        return try seek(fromStart: 0)
    }
}

public extension SeekableByOpened {
    /// Seeks using the specified offset
    @discardableResult
    static func seek(_ offset: Offset, in opened: Open<Self>) throws -> OSOffsetInt {
        let seekFunc: (OSOffsetInt, Open<Self>) throws -> OSOffsetInt

        switch offset.type {
        case .beginning: seekFunc = Self.seek(fromStart:in:)
        case .end: seekFunc = Self.seek(fromEnd:in:)
        case .current: seekFunc = Self.seek(fromCurrent:in:)
        #if os(macOS)
        case .hole: seekFunc = Self.seek(toNextHoleAfter:in:)
        case .data: seekFunc = Self.seek(toNextDataAfter:in:)
        #endif
        default: throw SeekError.unknownOffsetType
        }

        return try seekFunc(offset.bytes, opened)
    }

    /// Moves the file offset back to the beginning of the file
    @discardableResult
    static func rewind(in opened: Open<Self>) throws -> OSOffsetInt {
        return try Self.seek(fromStart: 0, in: opened)
    }
}
