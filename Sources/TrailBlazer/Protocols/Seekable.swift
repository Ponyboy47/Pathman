#if os(Linux)
import let Glibc.SEEK_CUR
import let Glibc.SEEK_END
import let Glibc.SEEK_SET
#else
import let Darwin.SEEK_CUR
import let Darwin.SEEK_END
import let Darwin.SEEK_SET
#endif

public protocol SeekableByOpened: Openable {
    static func seek(fromStart bytes: OSOffsetInt, in opened: Open<Self>) throws
    static func seek(fromEnd bytes: OSOffsetInt, in opened: Open<Self>) throws
    static func seek(fromCurrent bytes: OSOffsetInt, in opened: Open<Self>) throws
    static func getCurrentOffset(in opened: Open<Self>) throws -> OSOffsetInt
    static func rewind(in opened: Open<Self>) throws
}

/// Protocol declaration for types that contain an offset which points to a
/// byte location in the file and may be moved around
public protocol Seekable {
    func seek(fromStart bytes: OSOffsetInt) throws
    func seek(fromEnd bytes: OSOffsetInt) throws
    func seek(fromCurrent bytes: OSOffsetInt) throws
    func getCurrentOffset() throws -> OSOffsetInt
    func rewind() throws
}

public extension Seekable {
    /// The location in the path from where reading and writing begin. Measured
    /// in bytes from the beginning of the path
    var offset: OSOffsetInt {
        get { return (try? getCurrentOffset()) ?? -1 }
        nonmutating set { _ = try? seek(fromStart: newValue) }
    }

    /// Seeks using the specified offset
    func seek(_ offset: Offset) throws {
        let seekFunc: (OSOffsetInt) throws -> Void

        switch offset.type {
        case .beginning: seekFunc = seek(fromStart:)
        case .end: seekFunc = seek(fromEnd:)
        case .current: seekFunc = seek(fromCurrent:)
        default: throw SeekError.unknownOffsetType
        }

        try seekFunc(offset.bytes)
    }

    /// Moves the file offset back to the beginning of the file
    func rewind() throws {
        try seek(fromStart: 0)
    }
}

public extension SeekableByOpened {
    /// Seeks using the specified offset
    static func seek(_ offset: Offset, in opened: Open<Self>) throws {
        let seekFunc: (OSOffsetInt, Open<Self>) throws -> Void

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

        try seekFunc(offset.bytes, opened)
    }

    /// Moves the file offset back to the beginning of the file
    static func rewind(in opened: Open<Self>) throws {
        try Self.seek(fromStart: 0, in: opened)
    }
}
