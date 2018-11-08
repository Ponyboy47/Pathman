import struct Foundation.Data

public protocol Writable {
    func write(_ buffer: Data) throws
}

public protocol _WritesWithFlags {
    associatedtype WriteFlagsType: OptionSet
    static var emptyWriteFlags: WriteFlagsType { get }
}

public protocol WritableWithFlags: Writable, _WritesWithFlags {
    func write(_ buffer: Data, flags: WriteFlagsType) throws
}

public protocol WritableByOpened: Openable {
    static func write(_ buffer: Data, to opened: Open<Self>) throws
}

public protocol WritableByOpenedWithFlags: WritableByOpened, _WritesWithFlags {
    static func write(_ buffer: Data, flags: WriteFlagsType, to opened: Open<Self>) throws
}
