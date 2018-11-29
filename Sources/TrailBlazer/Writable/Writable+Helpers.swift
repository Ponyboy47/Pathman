import struct Foundation.Data

extension WritableByOpened {
    @discardableResult
    public static func write(_ string: String, using encoding: String.Encoding = .utf8, to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, to: opened)
    }
}

extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption {
    @discardableResult
    public func write(_ buffer: Data) throws -> WriteReturnType {
        return try open(options: OpenOptionsType.writableDefault).write(buffer)
    }

    @discardableResult
    public func write(_ string: String, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

extension WritableByOpened where Self: SeekableByOpened {
    @discardableResult
    public static func write(_ buffer: Data, at offset: Offset, to opened: Open<Self>) throws -> WriteReturnType {
        try Self.seek(offset, in: opened)
        return try Self.write(buffer, to: opened)
    }

    @discardableResult
    public static func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8, to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, at: offset, to: opened)
    }
}

extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption, Self: SeekableByOpened {
    @discardableResult
    public func write(_ buffer: Data, at offset: Offset) throws -> WriteReturnType {
        return try open(options: OpenOptionsType.writableDefault).write(buffer, at: offset)
    }

    @discardableResult
    public func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

extension WritableByOpenedWithFlags {
    @discardableResult
    public static func write(_ buffer: Data, to opened: Open<Self>) throws -> WriteReturnType {
        return try Self.write(buffer, flags: Self.emptyWriteFlags, to: opened)
    }

    @discardableResult
    public static func write(_ string: String,
                             flags: WriteFlagsType,
                             using encoding: String.Encoding = .utf8,
                             to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, flags: flags, to: opened)
    }
}
