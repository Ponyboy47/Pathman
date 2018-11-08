import struct Foundation.Data

extension Open: Writable where PathType: WritableByOpened {
    public func write(_ buffer: Data) throws {
        try PathType.write(buffer, to: self)
    }
}

extension Open: WritableWithFlags, _WritesWithFlags where PathType: WritableByOpenedWithFlags {
    public typealias WriteFlagsType = PathType.WriteFlagsType
    public static var emptyWriteFlags: WriteFlagsType { return PathType.emptyWriteFlags }

    public func write(_ buffer: Data, flags: WriteFlagsType) throws {
        try PathType.write(buffer, flags: flags, to: self)
    }
}
