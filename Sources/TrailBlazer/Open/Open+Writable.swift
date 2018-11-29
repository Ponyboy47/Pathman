import struct Foundation.Data

extension Open: WritableReturnable where PathType: WritableReturnable {
    public typealias WriteReturnType = PathType.WriteReturnType
}

extension Open where PathType: WritableByOpened, PathType.WriteReturnType == Void {
    public func write(_ buffer: Data) throws {
        try PathType.write(buffer, to: self)
    }
}

extension Open: Writable where PathType: WritableByOpened {
    public func write(_ buffer: Data) throws -> WriteReturnType {
        return try PathType.write(buffer, to: self)
    }
}

extension Open: WritableWithFlags, _WritesWithFlags where PathType: WritableByOpenedWithFlags {
    public typealias WriteFlagsType = PathType.WriteFlagsType
    public static var emptyWriteFlags: WriteFlagsType { return PathType.emptyWriteFlags }

    public func write(_ buffer: Data, flags: WriteFlagsType) throws -> WriteReturnType {
        return try PathType.write(buffer, flags: flags, to: self)
    }
}

extension Open where PathType: WritableByOpenedWithFlags, PathType.WriteReturnType == Void {
    public func write(_ buffer: Data, flags: WriteFlagsType) throws {
        try PathType.write(buffer, flags: flags, to: self)
    }
}
