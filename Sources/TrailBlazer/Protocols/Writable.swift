import struct Foundation.Data

public protocol WritableReturnable {
    associatedtype WriteReturnType = Void
}

public protocol Writable: WritableReturnable {
    func write(_ buffer: Data) throws -> WriteReturnType
}

public protocol _WritesWithFlags {
    associatedtype WriteFlagsType: OptionSet
    static var emptyWriteFlags: WriteFlagsType { get }
}

public protocol WritableWithFlags: Writable, _WritesWithFlags {
    func write(_ buffer: Data, flags: WriteFlagsType) throws -> WriteReturnType
}

public protocol WritableByOpened: Openable, WritableReturnable {
    static func write(_ buffer: Data, to opened: Open<Self>) throws -> WriteReturnType
}

public protocol WritableByOpenedWithFlags: WritableByOpened, _WritesWithFlags {
    static func write(_ buffer: Data, flags: WriteFlagsType, to opened: Open<Self>) throws -> WriteReturnType
}
