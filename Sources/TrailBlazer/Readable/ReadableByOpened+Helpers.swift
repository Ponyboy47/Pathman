import struct Foundation.Data

// Also mimicks some of the Readable conformance, but uses the defaultByteCount.
extension ReadableByOpened where OpenOptionsType: DefaultReadableOpenOption, Self: DefaultReadByteCount {
    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        return try open(options: OpenOptionsType.readableDefault).read(bytes: bytesToRead)
    }

    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

// Allows seeking in the path prior to reading
extension ReadableByOpened where Self: SeekableByOpened, Self: DefaultReadByteCount {
    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                            from opened: Open<Self>) throws -> Data {
        try Self.seek(offset, in: opened)
        return try Self.read(bytes: bytesToRead, from: opened)
    }

    public static func read(from offset: Offset,
                            bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                            encoding: String.Encoding = .utf8,
                            from opened: Open<Self>) throws -> String? {
        return try String(data: Self.read(from: offset, bytes: bytesToRead, from: opened), encoding: encoding)
    }
}

// This extension mimicks the Readable & Seekable extension
extension ReadableByOpened where Self: SeekableByOpened,
                                 OpenOptionsType: DefaultReadableOpenOption,
                                 Self: DefaultReadByteCount {
    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: open(options: OpenOptionsType.readableDefault).read(from: offset,
                                                                                    bytes: bytesToRead),
                          encoding: encoding)
    }
}
