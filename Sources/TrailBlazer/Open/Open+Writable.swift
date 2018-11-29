import struct Foundation.Data

extension Open: WritableReturnable where PathType: WritableReturnable {
    public typealias WriteReturnType = PathType.WriteReturnType
}

extension Open: Writable where PathType: WritableByOpened {
    @discardableResult
    public func write(_ buffer: Data) throws -> WriteReturnType {
        return try PathType.write(buffer, to: self)
    }
}

extension Open: WritableWithFlags, _WritesWithFlags where PathType: WritableByOpenedWithFlags {
    public typealias WriteFlagsType = PathType.WriteFlagsType
    public static var emptyWriteFlags: WriteFlagsType { return PathType.emptyWriteFlags }

    @discardableResult
    public func write(_ buffer: Data, flags: WriteFlagsType) throws -> WriteReturnType {
        return try PathType.write(buffer, flags: flags, to: self)
    }
}
