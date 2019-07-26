import struct Foundation.Data

// Also mimicks some of the Readable conformance, but uses the defaultByteCount.
public extension ReadableByOpened where OpenOptions: DefaultReadableOpenOption, Self: DefaultReadByteCount {
    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        return try open(options: OpenOptions.readableDefault).read(bytes: bytesToRead)
    }

    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Allows seeking in the path prior to reading
public extension ReadableByOpened where Self: SeekableByOpened, Self: DefaultReadByteCount {
    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    static func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8,
                     from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This extension mimicks the Readable & Seekable extension
public extension ReadableByOpened where Self: SeekableByOpened,
    OpenOptions: DefaultReadableOpenOption,
    Self: DefaultReadByteCount {
    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}

public extension CharacterReadableByOpened where OpenOptions: DefaultReadableOpenOption {
    func nextCharacter() throws -> Character {
        return try open(options: OpenOptions.readableDefault).nextCharacter()
    }
}

public extension CharacterReadableByOpened where Self: SeekableByOpened {
    static func nextCharacter(from offset: Offset,
                              from opened: Open<Self>) throws -> Character {
        try Self.seek(offset, in: opened)
        return try Self.nextCharacter(from: opened)
    }
}

public extension CharacterReadableByOpened where Self: SeekableByOpened,
    OpenOptions: DefaultReadableOpenOption {
    func nextCharacter(from offset: Offset) throws -> Character {
        return try open(options: OpenOptions.readableDefault).nextCharacter(from: offset)
    }
}

public extension LineReadableByOpened where OpenOptions: DefaultReadableOpenOption {
    func nextLine(strippingNewline: Bool = true) throws -> Data {
        return try open(options: OpenOptions.readableDefault).nextLine(strippingNewline: strippingNewline)
    }

    func nextLine(strippingNewline: Bool = true,
                  encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: nextLine(strippingNewline: strippingNewline), encoding: encoding)
    }
}

public extension LineReadableByOpened where Self: SeekableByOpened {
    static func nextLine(from offset: Offset,
                         strippingNewline: Bool = true,
                         from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.nextLine(strippingNewline: strippingNewline, from: opened)
    }

    static func nextLine(from offset: Offset,
                         strippingNewline: Bool = true,
                         encoding: String.Encoding = .utf8,
                         from opened: Open<Self>) throws -> String? {
        return try String(data: Self.nextLine(from: offset, strippingNewline: strippingNewline, from: opened),
                          encoding: encoding)
    }
}

public extension LineReadableByOpened where Self: SeekableByOpened,
    OpenOptions: DefaultReadableOpenOption {
    func nextLine(from offset: Offset,
                  strippingNewline: Bool = true) throws -> Data {
        return try open(options: OpenOptions.readableDefault).nextLine(from: offset,
                                                                       strippingNewline: strippingNewline)
    }

    func nextLine(from offset: Offset,
                  strippingNewline: Bool = true,
                  encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: nextLine(from: offset, strippingNewline: strippingNewline), encoding: encoding)
    }
}
