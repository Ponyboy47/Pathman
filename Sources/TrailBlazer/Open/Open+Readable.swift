import struct Foundation.Data

extension Open: Readable where PathType: ReadableByOpened {
    public func read(bytes bytesToRead: ByteRepresentable) throws -> Data {
        return try PathType.read(bytes: bytesToRead, from: self)
    }
}

extension Open: DefaultReadByteCount where PathType: ReadableByOpened & DefaultReadByteCount {
    public static var defaultByteCount: ByteRepresentable { return PathType.defaultByteCount }

    public func read(bytes bytesToRead: ByteRepresentable = Open<PathType>.defaultByteCount) throws -> Data {
        return try PathType.read(bytes: bytesToRead, from: self)
    }
}

extension Open: ReadableWithFlags, _ReadsWithFlags where PathType: ReadableByOpenedWithFlags {
    public typealias ReadFlagsType = PathType.ReadFlagsType
    public static var emptyReadFlags: ReadFlagsType { return PathType.emptyReadFlags }

    public func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType) throws -> Data {
        return try PathType.read(bytes: bytesToRead, flags: flags, from: self)
    }
}

extension Open: CharacterReadable where PathType: CharacterReadableByOpened {
    public func nextCharacter() throws -> Character {
        return try PathType.nextCharacter(from: self)
    }

    public func ungetCharacter(_ character: Character) throws {
        try PathType.ungetCharacter(character, to: self)
    }
}
