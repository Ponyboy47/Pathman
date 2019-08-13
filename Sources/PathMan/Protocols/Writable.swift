import struct Foundation.Data

public protocol Writable {
    @discardableResult
    func write(_ buffer: Data) throws -> Int
}

public protocol _WritesWithFlags {
    associatedtype WriteFlagsType: OptionSet
    static var emptyWriteFlags: WriteFlagsType { get }
}

public protocol WritableWithFlags: Writable, _WritesWithFlags {
    @discardableResult
    func write(_ buffer: Data, flags: WriteFlagsType) throws -> Int
}

public protocol WritableByOpened: Openable {
    @discardableResult
    static func write(_ buffer: Data, to opened: Open<Self>) throws -> Int
}

public protocol WritableByOpenedWithFlags: WritableByOpened, _WritesWithFlags {
    @discardableResult
    static func write(_ buffer: Data, flags: WriteFlagsType, to opened: Open<Self>) throws -> Int
}

public protocol BufferedWritable: Writable {
    func setBuffer(mode: BufferMode) throws
    func flush() throws
    func sync() throws
}

public protocol BufferedWritableByOpened: WritableByOpened {
    static func setBuffer(mode: BufferMode, to opened: Open<Self>) throws
    static func flush(stream opened: Open<Self>) throws
    static func sync(from opened: Open<Self>) throws
}
