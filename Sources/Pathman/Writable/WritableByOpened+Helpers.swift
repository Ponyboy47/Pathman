import struct Foundation.Data

public extension WritableByOpened {
    @discardableResult
    static func write(_ string: String,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, to: opened)
    }
}

public extension WritableByOpened where OpenOptions: DefaultWritableOpenOption {
    @discardableResult
    func write(_ buffer: Data) throws -> Int {
        return try open(options: OpenOptions.writableDefault).write(buffer)
    }

    @discardableResult
    func write(_ string: String, using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data)
    }
}

public extension WritableByOpened where Self: SeekableByOpened {
    @discardableResult
    static func write(_ buffer: Data,
                      at offset: Offset,
                      to opened: Open<Self>) throws -> Int {
        try Self.seek(offset, in: opened)
        return try Self.write(buffer, to: opened)
    }

    @discardableResult
    static func write(_ string: String,
                      at offset: Offset,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, at: offset, to: opened)
    }
}

public extension WritableByOpened where OpenOptions: DefaultWritableOpenOption, Self: SeekableByOpened {
    @discardableResult
    func write(_ buffer: Data, at offset: Offset) throws -> Int {
        return try open(options: OpenOptions.writableDefault).write(buffer, at: offset)
    }

    @discardableResult
    func write(_ string: String,
               at offset: Offset,
               using encoding: String.Encoding = .utf8) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try write(data, at: offset)
    }
}

public extension WritableByOpenedWithFlags {
    @discardableResult
    static func write(_ buffer: Data, to opened: Open<Self>) throws -> Int {
        return try Self.write(buffer, flags: Self.emptyWriteFlags, to: opened)
    }

    @discardableResult
    static func write(_ string: String,
                      flags: WriteFlagsType,
                      using encoding: String.Encoding = .utf8,
                      to opened: Open<Self>) throws -> Int {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try Self.write(data, flags: flags, to: opened)
    }
}
