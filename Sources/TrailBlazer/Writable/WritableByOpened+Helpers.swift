import struct Foundation.Data

extension Writable {
    @discardableResult
    public func write(_ string: String, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

extension Writable where Self: Seekable {
    @discardableResult
    public func write(_ buffer: Data, at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer)
    }

    @discardableResult
    public func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

extension WritableWithFlags {
    @discardableResult
    public func write(_ buffer: Data) throws -> WriteReturnType {
        return try write(buffer, flags: Self.emptyWriteFlags)
    }

    @discardableResult
    public func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags)
    }
}

extension WritableWithFlags where Self: Seekable {
    @discardableResult
    public func write(_ buffer: Data, flags: WriteFlagsType, at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer, flags: flags)
    }

    @discardableResult
    public func write(_ string: String,
                      flags: WriteFlagsType,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags, at: offset)
    }
}
