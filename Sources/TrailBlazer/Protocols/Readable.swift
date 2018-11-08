import struct Foundation.Data

public protocol Readable {
    func read(bytes bytesToRead: ByteRepresentable) throws -> Data
}

public protocol _ReadsWithFlags {
    associatedtype ReadFlagsType: OptionSet
    static var emptyReadFlags: ReadFlagsType { get }
}

public protocol ReadableWithFlags: Readable, _ReadsWithFlags {
    func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType) throws -> Data
}

public protocol DefaultReadByteCount {
    static var defaultByteCount: ByteRepresentable { get }
}

public protocol ReadableByOpened: Openable {
    static func read(bytes: ByteRepresentable, from opened: Open<Self>) throws -> Data
}

public protocol ReadableByOpenedWithFlags: ReadableByOpened, _ReadsWithFlags {
    static func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType, from opened: Open<Self>) throws -> Data
}
