import struct Foundation.Data

// Extends Readable to be able to conveniently return a string when reading a path
extension Readable {
    public func read(bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Extends Readable to be able to seek in a path before reading from it
extension Readable where Self: Seekable {
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}

// Extends ReadableWithFlags for automatic Readable conformance and the
// convenience of reading a string straight from the path
extension ReadableWithFlags {
    public func read(bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try read(bytes: bytesToRead, flags: Self.emptyReadFlags)
    }

    public func read(bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

// Extends ReadableWithFlags to be able to seek in a path before reading from it
extension ReadableWithFlags where Self: Seekable {
    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead, flags: flags)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

extension ReadableWithFlags where Self: DefaultReadByteCount {
    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

extension ReadableWithFlags where Self: Seekable & DefaultReadByteCount {
    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead, flags: flags)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

// This extension allows reading a string from a path
extension ReadableByOpened {
    public static func read(bytes bytesToRead: ByteRepresentable,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This gets you the same functionality as if your type conformed to Readable.
// Warning: If you do conform to Readable then you will have ambiguity issues
// when calling these functions
extension ReadableByOpened where OpenOptionsType: DefaultReadableOpenOption {
    public func read(bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead)
    }

    public func read(bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Allows seeking in the path prior to reading
extension ReadableByOpened where Self: SeekableByOpened {
    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable,
                            from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This extension mimicks the Readable & Seekable extension
extension ReadableByOpened where Self: SeekableByOpened, OpenOptionsType: DefaultReadableOpenOption {
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(from: offset, bytes: bytesToRead)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: open(options: OpenOptionsType.readableDefault).read(from: offset,
                                                                                    bytes: bytesToRead),
                          encoding: encoding)
    }
}

// This extension automatically conforms ReadableByOpenedWithFlags to ReadableByOpened
extension ReadableByOpenedWithFlags {
    public static func read(bytes bytesToRead: ByteRepresentable, from opened: Open<Self>) throws -> Data {
        return try Self.read(bytes: bytesToRead, flags: Self.emptyReadFlags, from: opened)
    }

    public static func read(bytes bytesToRead: ByteRepresentable,
                            flags: ReadFlagsType,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}

// This allows for automatic ReadableWithFlags conformance. Must still be
// explicitly stated in the type
extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption {
    public func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead, flags: flags)
    }

    public func read(bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where Self: SeekableByOpened {
    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable,
                            flags: ReadFlagsType,
                            from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable,
                            flags: ReadFlagsType,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption, Self: SeekableByOpened {
    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(from: offset, bytes: bytesToRead, flags: flags)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where Self: DefaultReadByteCount {
    public static func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                            flags: ReadFlagsType,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption,
                                          Self: DefaultReadByteCount {
    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead, flags: flags)
    }

    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where Self: SeekableByOpened & DefaultReadByteCount {
    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                            flags: ReadFlagsType,
                            from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, flags: flags, from: opened)
    }

    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                            flags: ReadFlagsType,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, flags: flags, from: opened),
                          encoding: encoding)
    }
}

extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption,
                                          Self: SeekableByOpened & DefaultReadByteCount {
    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     from opened: Open<Self>) throws -> Data {
        return try Self.read(from: offset, bytes: bytesToRead, flags: flags, from: opened)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}
