import struct Foundation.Data

public extension WritableByOpened {
    static func write(_ string: String,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, to: opened)
    }
}

public extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption {
    func write(_ buffer: Data) throws -> WriteReturnType {
        return try open(options: OpenOptionsType.writableDefault).write(buffer)
    }

    func write(_ string: String, using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

public extension WritableByOpened where Self: SeekableByOpened {
    static func write(_ buffer: Data,
                      at offset: Offset,
                      to opened: Open<Self>) throws -> WriteReturnType {
        try Self.seek(offset, in: opened)
        return try Self.write(buffer, to: opened)
    }

    static func write(_ string: String,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, at: offset, to: opened)
    }
}

public extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption, Self: SeekableByOpened {
    func write(_ buffer: Data, at offset: Offset) throws -> WriteReturnType {
        return try open(options: OpenOptionsType.writableDefault).write(buffer, at: offset)
    }

    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

public extension WritableByOpenedWithFlags {
    static func write(_ buffer: Data, to opened: Open<Self>) throws -> WriteReturnType {
        return try Self.write(buffer, flags: Self.emptyWriteFlags, to: opened)
    }

    static func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> WriteReturnType {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, flags: flags, to: opened)
    }
}

public extension WritableByOpened where WriteReturnType == Void {
    static func write(_ string: String,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, to: opened)
    }
}

public extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption, WriteReturnType == Void {
    func write(_ buffer: Data) throws {
        try open(options: OpenOptionsType.writableDefault).write(buffer)
    }

    func write(_ string: String, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data)
    }
}

public extension WritableByOpened where Self: SeekableByOpened, WriteReturnType == Void {
    static func write(_ buffer: Data, at offset: Offset, to opened: Open<Self>) throws {
        try Self.seek(offset, in: opened)
        try Self.write(buffer, to: opened)
    }

    static func write(_ string: String,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, at: offset, to: opened)
    }
}

public extension WritableByOpened where OpenOptionsType: DefaultWritableOpenOption,
                                        Self: SeekableByOpened,
                                        WriteReturnType == Void {
    func write(_ buffer: Data, at offset: Offset) throws {
        try open(options: OpenOptionsType.writableDefault).write(buffer, at: offset)
    }

    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

public extension WritableByOpenedWithFlags where WriteReturnType == Void {
    static func write(_ buffer: Data, to opened: Open<Self>) throws {
        try Self.write(buffer, flags: Self.emptyWriteFlags, to: opened)
    }

    static func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try Self.write(data, flags: flags, to: opened)
    }
}
