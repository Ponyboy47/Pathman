import struct Foundation.Data

// Extends Readable to be able to conveniently return a string when reading a path
public extension Readable {
    func read(bytes bytesToRead: ByteRepresentable,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Extends Readable to be able to seek in a path before reading from it
public extension Readable where Self: Seekable {
    func read(from offset: Offset, bytes bytesToRead: ByteRepresentable) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}

// Extends ReadableWithFlags for automatic Readable conformance and the
// convenience of reading a string straight from the path
public extension ReadableWithFlags {
    func read(bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try read(bytes: bytesToRead, flags: Self.emptyReadFlags)
    }

    func read(bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

// Extends ReadableWithFlags to be able to seek in a path before reading from it
public extension ReadableWithFlags where Self: Seekable {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead, flags: flags)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

public extension ReadableWithFlags where Self: DefaultReadByteCount {
    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

public extension ReadableWithFlags where Self: Seekable & DefaultReadByteCount {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead, flags: flags)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

// This extension allows reading a string from a path
public extension ReadableByOpened {
    static func read(bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This gets you the same functionality as if your type conformed to Readable.
// Warning: If you do conform to Readable then you will have ambiguity issues
// when calling these functions
public extension ReadableByOpened where OpenOptionsType: DefaultReadableOpenOption {
    func read(bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead)
    }

    func read(bytes bytesToRead: ByteRepresentable,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Allows seeking in the path prior to reading
public extension ReadableByOpened where Self: SeekableByOpened {
    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This extension mimicks the Readable & Seekable extension
public extension ReadableByOpened where Self: SeekableByOpened, OpenOptionsType: DefaultReadableOpenOption {
    func read(from offset: Offset, bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(from: offset, bytes: bytesToRead)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: open(options: OpenOptionsType.readableDefault).read(from: offset,
                                                                                    bytes: bytesToRead),
                          encoding: encoding)
    }
}

// This extension automatically conforms ReadableByOpenedWithFlags to ReadableByOpened
public extension ReadableByOpenedWithFlags {
    static func read(bytes bytesToRead: ByteRepresentable, from opened: Open<Self>) throws -> Data {
        return try Self.read(bytes: bytesToRead, flags: Self.emptyReadFlags, from: opened)
    }

    static func read(bytes bytesToRead: ByteRepresentable,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}

// This allows for automatic ReadableWithFlags conformance. Must still be
// explicitly stated in the type
public extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption {
    func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead, flags: flags)
    }

    func read(bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where Self: SeekableByOpened {
    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags _: ReadFlagsType,
                     from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable,
                     flags _: ReadFlagsType,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption, Self: SeekableByOpened {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(from: offset, bytes: bytesToRead, flags: flags)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where Self: DefaultReadByteCount {
    static func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption,
    Self: DefaultReadByteCount {
    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead, flags: flags)
    }

    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead, flags: flags), encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where Self: SeekableByOpened & DefaultReadByteCount {
    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, flags: flags, from: opened)
    }

    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     flags: ReadFlagsType,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, flags: flags, from: opened),
                          encoding: encoding)
    }
}

public extension ReadableByOpenedWithFlags where OpenOptionsType: DefaultReadableOpenOption,
    Self: SeekableByOpened & DefaultReadByteCount {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType,
              from opened: Open<Self>) throws -> Data {
        return try Self.read(from: offset, bytes: bytesToRead, flags: flags, from: opened)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              flags: ReadFlagsType,
              encoding: String.Encoding = .utf8,
              from opened: Open<Self>) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead, flags: flags, from: opened), encoding: encoding)
    }
}

// This extension mimicks the Readable & Seekable extension
public extension ReadableByOpened where Self: SeekableByOpened,
    OpenOptionsType: DefaultReadableOpenOption,
    Self: DefaultReadByteCount {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(from: offset, bytes: bytesToRead)
    }
}

public extension CharacterReadable where Self: Seekable {
    func nextCharacter(from offset: Offset) throws -> Character {
        try seek(offset)
        return try nextCharacter()
    }
}
