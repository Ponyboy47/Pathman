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

extension DefaultReadByteCount where Self: Readable {
    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

extension DefaultReadByteCount where Self: Readable & Seekable {
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}
