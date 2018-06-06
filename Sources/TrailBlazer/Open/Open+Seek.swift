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
        case .beginning: newOffset = try seek(fromStart: offset.size)
        case .end: newOffset = try seek(fromEnd: offset.size)
        case .current: newOffset = try seek(fromCurrent: offset.size)
        // case .data: newOffset = try seek(toNextDataFrom: offset.size)
        // case .hole: newOffset = try seek(toNextHoleFrom: offset.size)
        default: throw SeekError.unknownOffsetType
        }

        self.offset = newOffset
        return self.offset
    }
}

public extension Seekable where Self: OpenFile {
    @discardableResult
    public func seek(fromStart bytes: Int) throws -> Int {
        guard offset != 0 && bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromEnd bytes: Int) throws -> Int {
        let newOffset = lseek(fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromCurrent bytes: Int) throws -> Int {
        guard bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func rewind() throws -> Int {
        return try seek(fromStart: 0)
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
    var size: Int

    init(_ from: OffsetType, _ size: Int) {
        self.from = from
        self.size = size
    }

    public init(from offset: OffsetType, size bytes: Int) {
        from = offset
        size = bytes
    }
}
