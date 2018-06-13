#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Seekable: class {
    var offset: Int { get set }

    func seek(_ offset: Offset) throws -> Int

    func seek(fromStart bytes: Int) throws -> Int
    func seek(fromEnd bytes: Int) throws -> Int
    func seek(fromCurrent bytes: Int) throws -> Int

    func rewind() throws -> Int
}

public extension Seekable {
    @discardableResult
    public func seek(_ offset: Offset) throws -> Int {
        let newOffset: Int

        switch offset.from {
        case .beginning: newOffset = try seek(fromStart: offset.bytes)
        case .end: newOffset = try seek(fromEnd: offset.bytes)
        case .current: newOffset = try seek(fromCurrent: offset.bytes)
        // case .data: newOffset = try seek(toNextDataFrom: offset.bytes)
        // case .hole: newOffset = try seek(toNextHoleFrom: offset.bytes)
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
        // public static let data = OffsetType(rawValue: SEEK_DATA)
        // public static let hole = OffsetType(rawValue: SEEK_HOLE)

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    var from: OffsetType
    var bytes: Int

    init(_ type: OffsetType, _ bytes: Int) {
        self.from = type
        self.bytes = bytes
    }

    public init(from type: OffsetType, bytes: Int) {
        self.from = type
        self.bytes = bytes
    }
}
