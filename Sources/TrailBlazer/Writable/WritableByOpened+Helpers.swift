import struct Foundation.Data

public extension Writable {
    func write(_ string: String,
               using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

public extension Writable where Self: Seekable {
    func write(_ buffer: Data, at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer)
    }

    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

public extension WritableWithFlags {
    func write(_ buffer: Data) throws -> WriteReturnType {
        return try write(buffer, flags: Self.emptyWriteFlags)
    }

    func write(_ string: String,
               flags: WriteFlagsType,
               using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags)
    }
}

public extension WritableWithFlags where Self: Seekable {
    func write(_ buffer: Data,
               flags: WriteFlagsType,
               at offset: Offset) throws -> WriteReturnType {
        try seek(offset)
        return try write(buffer, flags: flags)
    }

    func write(_ string: String,
               flags: WriteFlagsType,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags, at: offset)
    }
}

public extension Writable where WriteReturnType == Void {
    func write(_ string: String, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data)
    }
}

public extension Writable where Self: Seekable, WriteReturnType == Void {
    func write(_ buffer: Data, at offset: Offset) throws {
        try seek(offset)
        try write(buffer)
    }

    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

public extension WritableWithFlags where WriteReturnType == Void {
    func write(_ buffer: Data) throws {
        try write(buffer, flags: Self.emptyWriteFlags)
    }

    func write(_ string: String,
               flags: WriteFlagsType,
               using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, flags: flags)
    }
}

public extension WritableWithFlags where Self: Seekable, WriteReturnType == Void {
    func write(_ buffer: Data, flags: WriteFlagsType, at offset: Offset) throws {
        try seek(offset)
        try write(buffer, flags: flags)
    }

    func write(_ string: String,
               flags: WriteFlagsType,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, flags: flags, at: offset)
    }
}
