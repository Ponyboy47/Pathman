import struct Foundation.Data

extension Writable {
    public func write(_ string: String, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

extension Writable where Self: Seekable {
    public func write(_ buffer: Data, at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer)
    }

    public func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

extension WritableWithFlags {
    public func write(_ buffer: Data) throws -> WriteReturnType {
        return try write(buffer, flags: Self.emptyWriteFlags)
    }

    public func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags)
    }
}

extension WritableWithFlags where Self: Seekable {
    public func write(_ buffer: Data, flags: WriteFlagsType, at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer, flags: flags)
    }

    public func write(_ string: String,
                      flags: WriteFlagsType,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags, at: offset)
    }
}

extension Writable where WriteReturnType == Void {
    public func write(_ string: String, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data)
    }
}

extension Writable where Self: Seekable, WriteReturnType == Void {
    public func write(_ buffer: Data, at offset: Offset) throws {
        try seek(offset)
        try write(buffer)
    }

    public func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

extension WritableWithFlags where WriteReturnType == Void {
    public func write(_ buffer: Data) throws {
        try write(buffer, flags: Self.emptyWriteFlags)
    }

    public func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, flags: flags)
    }
}

extension WritableWithFlags where Self: Seekable, WriteReturnType == Void {
    public func write(_ buffer: Data, flags: WriteFlagsType, at offset: Offset) throws {
        try seek(offset)
        try write(buffer, flags: flags)
    }

    public func write(_ string: String,
                      flags: WriteFlagsType,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, flags: flags, at: offset)
    }
}
