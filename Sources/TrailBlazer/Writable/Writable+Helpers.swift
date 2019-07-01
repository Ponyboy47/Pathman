import struct Foundation.Data

public extension Writable {
    @discardableResult
    func write(_ string: String,
               using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

public extension Writable where Self: Seekable {
    @discardableResult
    func write(_ buffer: Data, at offset: Offset) throws -> Int {
        try seek(offset)
        return try write(buffer)
    }

    @discardableResult
    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

public extension WritableWithFlags {
    @discardableResult
    func write(_ buffer: Data) throws -> Int {
        return try write(buffer, flags: Self.emptyWriteFlags)
    }

    @discardableResult
    func write(_ string: String,
               flags: WriteFlagsType,
               using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags)
    }
}

public extension WritableWithFlags where Self: Seekable {
    @discardableResult
    func write(_ buffer: Data,
               flags: WriteFlagsType,
               at offset: Offset) throws -> Int {
        try seek(offset)
        return try write(buffer, flags: flags)
    }

    @discardableResult
    func write(_ string: String,
               flags: WriteFlagsType,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, flags: flags, at: offset)
    }
}
