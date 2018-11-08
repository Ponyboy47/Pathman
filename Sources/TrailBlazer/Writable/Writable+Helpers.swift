import struct Foundation.Data

extension WritableByOpened {
    public static func write(_ string: String, using encoding: String.Encoding = .utf8, to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, to: opened)
    }
}

extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption {
    public func write(_ buffer: Data) throws {
        try open(options: OpenOptionsType.writableDefault).write(buffer)
    }

    public func write(_ string: String, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data)
    }
}

extension WritableByOpened where Self: SeekableByOpened {
    public static func write(_ buffer: Data, at offset: Offset, to opened: Open<Self>) throws {
        try Self.seek(offset, in: opened)
        try Self.write(buffer, to: opened)
    }

    public static func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8, to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, at: offset, to: opened)
    }
}

extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption, Self: SeekableByOpened {
    public func write(_ buffer: Data, at offset: Offset) throws {
        try open(options: OpenOptionsType.writableDefault).write(buffer, at: offset)
    }

    public func write(_ string: String, at offset: Offset, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

extension WritableByOpenedWithFlags {
    public static func write(_ buffer: Data, to opened: Open<Self>) throws {
        try Self.write(buffer, flags: Self.emptyWriteFlags, to: opened)
    }

    public static func write(_ string: String,
                             flags: WriteFlagsType,
                             using encoding: String.Encoding = .utf8,
                             to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, flags: flags, to: opened)
    }
}
