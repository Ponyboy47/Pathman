import struct Foundation.Data

extension Open: Writable where PathType: WritableByOpened {
    @discardableResult
    public func write(_ buffer: Data) throws -> Int {
        return try PathType.write(buffer, to: self)
    }
}

extension Open: WritableWithFlags, _WritesWithFlags where PathType: WritableByOpenedWithFlags {
    public typealias WriteFlagsType = PathType.WriteFlagsType

    public static var emptyWriteFlags: WriteFlagsType { return PathType.emptyWriteFlags }

    @discardableResult
    public func write(_ buffer: Data, flags: WriteFlagsType) throws -> Int {
        return try PathType.write(buffer, flags: flags, to: self)
    }
}

extension Open: BufferedWritable where PathType: BufferedWritableByOpened {
    public func setBuffer(mode: BufferMode) throws {
        try PathType.setBuffer(mode: mode, to: self)
    }

    public func flush() throws {
        try PathType.flush(stream: self)
    }

    public func sync() throws {
        try PathType.sync(from: self)
    }
}
