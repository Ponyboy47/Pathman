#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Seekable: class {
    var offset: Int64 { get set }

    func seek(_ offset: Offset) throws -> Int64

    func seek(fromStart bytes: Int64) throws -> Int64
    func seek(fromEnd bytes: Int64) throws -> Int64
    func seek(fromCurrent bytes: Int64) throws -> Int64
    // These are available on macOS, but aren't in all Linux distros yet
    #if os(macOS)
    func seek(toNextHoleFrom offset: Int64) throws -> Int64
    func seek(toNextDataFrom offset: Int64) throws -> Int64
    #endif

    func rewind() throws -> Int64
}

public extension Seekable {
    @discardableResult
    public func seek(_ offset: Offset) throws -> Int64 {
        let newOffset: Int64

        switch offset.from {
        case .beginning: newOffset = try seek(fromStart: offset.bytes)
        case .end: newOffset = try seek(fromEnd: offset.bytes)
        case .current: newOffset = try seek(fromCurrent: offset.bytes)
        #if os(macOS)
        case .data: newOffset = try seek(toNextDataFrom: offset.bytes)
        case .hole: newOffset = try seek(toNextHoleFrom: offset.bytes)
        #endif
        default: throw SeekError.unknownOffsetType
        }

        self.offset = newOffset
        return self.offset
    }
}

public struct Offset {
    public struct OffsetType: RawRepresentable, Equatable {
        public typealias RawValue = Int32
        public let rawValue: RawValue

        public static let beginning = OffsetType(rawValue: SEEK_SET)
        public static let end = OffsetType(rawValue: SEEK_END)
        public static let current = OffsetType(rawValue: SEEK_CUR)
        #if os(macOS)
        public static let data = OffsetType(rawValue: SEEK_DATA)
        public static let hole = OffsetType(rawValue: SEEK_HOLE)
        #endif

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    var from: OffsetType
    var bytes: Int64

    init(_ type: OffsetType, _ bytes: Int64) {
        self.from = type
        self.bytes = bytes
    }

    public init(from type: OffsetType, bytes: Int64) {
        self.from = type
        self.bytes = bytes
    }
}
